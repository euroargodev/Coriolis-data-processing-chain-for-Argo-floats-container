"""Code to prepare the input files to be decoded."""

import os
import shutil
from datetime import datetime
from pathlib import Path

from fastapi import UploadFile


class FileManagerError(Exception):
    """Raised when any error is encountered during the file management process."""


class FileManager:
    """Methods to prepare raw files for delivery to the Coriolis Decoder."""

    def __init__(self, files: list[UploadFile], imei: str):
        """Initialise the instance with the given files."""
        self.files = files
        self.imei = imei
        self.base_archive_cycle_location = Path(
            os.getenv("ARCHIVE_CYCLE_LOCATION", "/mnt/data/rsync/archive/cycle")
        ).resolve(strict=True)
        self.base_archive_rsync_location = Path(
            os.getenv("ARCHIVE_RSYNC_LOCATION", "/mnt/data/rsync/rsync_list/")
        ).resolve(strict=True)

    def copy_file_to_input_directory(self, file) -> None:
        """Copy the file to a directory where the decoder can pick it up.

        The purpose of returning True/False is for the next step in the chain which is to
        produce the 'rsync' file.

        If a copy is successful, the function returns True meaning the name will be written to the rsync file and
        is therefore given to the decoder. If False, then the copy has failed, and will be logged accordingly.

        Args:
            file: The file to be copied.

        Returns:
            True if copy was successful, otherwise False.
        """
        float_directory = self.base_archive_cycle_location / self.imei
        float_directory.mkdir(parents=True, exist_ok=True)  # Ensure the directory exists.
        new_float_filename = float_directory / file.filename

        with new_float_filename.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

    def construct_rsync_file(self, filenames: list[str]) -> str:
        """Construct the rsync file required by the decoder.

        Args:
            filenames: The list of filenames passed in via the API.

        Returns:
            The name of the rsync file.
        """
        file_name = f"rsync_{datetime.now().strftime(format='%Y%m%dT%H%M%SZ')}.txt"
        full_file_path = self.base_archive_rsync_location / self.imei / file_name
        full_file_path.parent.mkdir(parents=True, exist_ok=True)

        with open(full_file_path, mode="w") as rsync_file:
            for filename in filenames:
                rsync_file.write(f"{self.imei}/{filename}\n")

        return file_name

    def run(self) -> str:
        """Driver method to orchestrate the copying of files ready for decoding.

        Returns:
            The name of the rsync file to be passed to the decoder.
        """
        try:
            # Copy each posted file to it's directory ready to be picked up by the decoder.
            for file in self.files:
                self.copy_file_to_input_directory(file)

            # Then use all the files to build the rsync file, also required by the decoder.
            return self.construct_rsync_file([file.filename for file in self.files])

        except Exception as exc:
            raise FileManagerError(exc) from None
