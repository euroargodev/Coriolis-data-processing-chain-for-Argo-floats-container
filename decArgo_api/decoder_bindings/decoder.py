"""Decoder Bindings."""

import json
import logging
import os
import subprocess
from pathlib import Path

from pydantic import BaseModel, Field, field_validator


class EmptyInputDirectoryError(FileNotFoundError):
    """Raised when the input directory is empty."""


class ExecutionError(ValueError):
    """Raised when no wmonum is passed to the decoder which is required to run the decode process."""


class DecoderError(RuntimeError):
    """Raised when an error is detected during the decoding stage."""


class DecoderConfiguration(BaseModel):
    """Configuration used to pass to the decoder, with validation applied."""

    input_files_directory: Path | None = Field(
        default=None, description="Directory containing the input files for the decoder."
    )
    output_files_directory: Path | None = Field(
        default=None, description="Directory where the decoded files will be written to"
    )
    decoder_conf_file: Path = Field(description="Path to the decoder configuration file.")

    @field_validator("input_files_directory", mode="before")
    def check_input_files_directory(cls, input_directory: Path):
        """Validate then resolve the input files directory if not None."""
        if input_directory is None:
            return input_directory
        if not input_directory.is_dir():
            raise NotADirectoryError(f"{input_directory} is not a valid input directory!")

        if not any(input_directory.iterdir()):
            raise EmptyInputDirectoryError(f"{input_directory} is empty!")
        return input_directory.resolve()

    @field_validator("output_files_directory", mode="before")
    def check_output_files_directory(cls, output_directory: Path):
        """Validate then resolve the output files directory if not None."""
        if output_directory is None:
            return output_directory
        if not output_directory.is_dir():
            raise NotADirectoryError(f"{output_directory} is not a valid output directory!")
        return output_directory.resolve()


class Decoder:
    """A simple representation of the Coriolis Decoder for API entrypoints."""

    def __init__(
        self,
        decoder_conf_file: str,
        input_files_directory: str | Path | None = None,
        output_files_directory: str | Path | None = None,
        extra_configuration: dict | None = None,
    ):
        """Initialise the bindings instance."""
        self.config = DecoderConfiguration(
            input_files_directory=Path(input_files_directory) if input_files_directory else None,
            output_files_directory=Path(output_files_directory) if output_files_directory else None,
            decoder_conf_file=Path(decoder_conf_file),
        )
        self.extra_configuration = json.loads(extra_configuration) if extra_configuration is not None else None

    def decode(self, wmonum: str, rsync_file: str) -> None:
        """Run the Coriolis Decoder."""
        cmd = [
            "/app/api.run_decode_argo_2_nc_rt.sh",
            "rsynclog",
            rsync_file,
            "configfile",
            str(self.config.decoder_conf_file),
            "xmlreport",
            "logfilexml.xml",
            "floatwmo",
            wmonum,
            "PROCESS_REMAINING_BUFFERS",
            "1",
        ]
        # If passed, extend the command to include the new input/out arguments to the decoder.
        if self.config.output_files_directory is not None:
            cmd.extend(
                [
                    "DIR_OUTPUT_NETCDF_FILE",
                    str(self.config.output_files_directory),
                    "DIR_OUTPUT_NETCDF_TRAJ_3_2_FILE",
                    str(self.config.output_files_directory),
                    "DIR_OUTPUT_NETCDF_TRAJ_3_1_FILE",
                    str(self.config.output_files_directory),
                    "IRIDIUM_DATA_DIRECTORY",
                    str(self.config.output_files_directory / "iridium"),
                ]
            )
        if self.config.input_files_directory is not None:
            cmd.extend(["DIR_INPUT_RSYNC_DATA", str(self.config.input_files_directory)])

        if self.extra_configuration is not None:
            for key, value in self.extra_configuration.items():
                cmd.extend([key, value])
        try:
            logging.info("Starting decode process.")
            result = subprocess.run(cmd, env=os.environ.copy(), check=True, capture_output=True, text=True)
        except (subprocess.CalledProcessError, FileNotFoundError) as exc:
            raise DecoderError(exc) from None
        else:
            # Check the decoder output for any issues.
            if "ERROR:" in result.stdout:
                raise DecoderError(result.stdout)

        logging.info("Decoding finished succesfully.")
