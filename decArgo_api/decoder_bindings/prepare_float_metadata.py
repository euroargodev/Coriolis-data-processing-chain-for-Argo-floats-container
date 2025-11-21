"""Code to move the float metadata to its correct location ready for the decoder."""

import json
from pathlib import Path


class MissingFloatInfoError(KeyError):
    """Raised when 'float_info' is missing from the metadata."""


class MissingFloatMetaError(KeyError):
    """Raised when 'float_meta' is missing from the metadata."""


class FloatMetadataManager:
    """Code to manage float metadata."""

    # These two directories will stay constant!
    float_info_directory = Path("/mnt/data/config/json_float_info/")
    float_meta_directory = Path("/mnt/data/config/json_float_meta/")

    def __init__(self, wmonum: str, float_metadata: str):
        """Initialise the instance, validate directories and incoming metadata."""
        self.wmonum = wmonum
        self.validate_metadata_directories()
        self.float_metadata = self._validate_incoming_metadata(float_metadata)

    @staticmethod
    def _validate_incoming_metadata(float_metadata: str) -> dict:
        """Utility method to validate the float metadata and return as a dict."""
        float_metadata = json.loads(float_metadata)
        if "float_info" not in float_metadata:
            raise MissingFloatInfoError("The 'float_info' is missing from the float metadata!") from None

        if "float_meta_info" not in float_metadata:
            raise MissingFloatMetaError("The 'float_meta_info' is missing from the float metadata!") from None

        return float_metadata

    @classmethod
    def validate_metadata_directories(cls) -> None:
        """Check the directories are present before writing to them."""
        cls.float_info_directory.mkdir(parents=True, exist_ok=True)
        cls.float_meta_directory.mkdir(parents=True, exist_ok=True)

    @property
    def imei(self) -> str:
        """Parse the float metadata for its IMEI.

        Returns:
            The IMEI number for the float being decoded.
        """
        return self.float_metadata["float_info"]["PTT"]

    def _write_json_float_info_file(self) -> None:
        """Write the JSON float info to its correct location."""
        with open(self.float_info_directory / f"{self.wmonum}_{self.imei}_info.json", mode="w") as json_float_info:
            json.dump(self.float_metadata["float_info"], json_float_info, indent=4)

    def _write_json_float_meta_file(self) -> None:
        """Write the JSON float meta to its correct location."""
        with open(self.float_meta_directory / f"{self.wmonum}_meta.json", mode="w") as json_float_meta:
            json.dump(self.float_metadata["float_meta_info"], json_float_meta, indent=4)

    def write_all_float_metadata_to_file(self) -> None:
        """Driver method to orchestrate the writing of float meta & info files to their correct location."""
        self._write_json_float_info_file()
        self._write_json_float_meta_file()
