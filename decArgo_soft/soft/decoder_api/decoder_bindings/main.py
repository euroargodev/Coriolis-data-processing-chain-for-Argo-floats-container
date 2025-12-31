"""Decoder Bindings."""

import os
import subprocess
from pathlib import Path

from pydantic import BaseModel, field_validator
from utilities.dict2json import save_info_meta_conf
from mock_data import info_dict, meta_dict, conf_dict  # Used for testing purposes only.


class EmptyInputDirectoryError(Exception):
    """Raised when the input directory is empty."""


class ExecutionError(Exception):
    """Raised when no wmonum is passed."""


class DecoderConfiguration(BaseModel):
    """Configuration used to pass to the decoder, with validation applied."""

    input_files_directory: Path | None
    output_files_directory: Path | None
    decoder_conf_file: Path

    @field_validator("input_files_directory", mode="before")
    def check_input_files_directory(cls, input_directory: Path):
        """Validate then resolve the input files directory if not None."""
        if input_directory is None:
            return input_directory
        if not input_directory.is_dir():
            raise ValueError(f"{input_directory} is not a valid input directory!")

        if not any(input_directory.iterdir()):
            raise EmptyInputDirectoryError(f"{input_directory} is empty!")
        return input_directory.resolve()

    @field_validator("output_files_directory", mode="before")
    def check_output_files_directory(cls, output_directory: Path):
        """Validate then resolve the output files directory if not None"""
        if output_directory is None:
            return output_directory
        if not output_directory.is_dir():
            raise ValueError(f"{output_directory} is not a valid output directory!")
        return output_directory.resolve()


class Decoder:
    """Decoder Bindings."""

    def __init__(
        self,
        input_files_directory: str | None,
        output_files_directory: str | None,
        decoder_conf_file: str,
    ):
        """Initialise the bindings instance."""
        self.config = DecoderConfiguration(
            input_files_directory=(
                Path(input_files_directory)
                if isinstance(input_files_directory, str)
                else None
            ),
            output_files_directory=(
                Path(output_files_directory)
                if isinstance(output_files_directory, str)
                else None
            ),
            decoder_conf_file=Path(decoder_conf_file),
        )

    def decode(self, wmonum: str) -> None:
        """Run the Coriolis Decoder."""
        cmd = [
            "/app/run_decode_argo_2_nc_rt.sh",
            "rsynclog",
            "all",
            "configfile",
            str(self.config.decoder_conf_file),
            "xmlreport",
            "logfilexml.xml",
            "floatwmo",
            wmonum,
            "PROCESS_REMAINING_BUFFERS",
            "1",
        ]
        # IF passed, extend the command to include the new input/output arguments to the decoder.
        if self.config.input_files_directory is not None:
            cmd.extend(
                [
                    "DIR_INPUT_RSYNC_DATA",
                    str(self.config.input_files_directory),
                    "DIR_OUTPUT_NETCDF_FILE",
                    str(self.config.output_files_directory),
                ]
            )

        # Regarding the 'except' clauses, these will return various non 200 status codes when integrated into the API.
        try:
            result = subprocess.run(cmd, env=os.environ.copy(), check=True)
        except subprocess.CalledProcessError as e:
            print("Command failed with return code:", e.returncode)
            print("STDERR:", e.stderr)
        except FileNotFoundError:
            print("Invalid command")
        else:
            print("Decoding ran:", result)
        while True:
            pass


if __name__ == "__main__":  # pragma: no cover
    print("Running...")

    # This is commented out for now, but we'll want to raise an error if no WMONUM is passed.
    # wmo = sys.argv
    # if len(sys.argv) < 2:
    #     raise ExecutionError("Usage: main.py <WMONUM>")

    # These are hardcoded for now, but will likely be passed by the calling code.
    try:
        float_info = save_info_meta_conf(
            config_dir="./decArgo_demo/config",
            float_info_dir="./decArgo_demo/config/decArgo_config_floats2/json_float_info",
            float_meta_dir="./decArgo_demo/config/decArgo_config_floats2/json_float_meta_ir_sbd",
            info=info_dict,
            meta=meta_dict,
            decoder_conf=conf_dict,
        )
        for key, value in float_info.items():
            print(f"  {key}: {value}")
    except Exception as e:
        print(f"Error saving float info : {e}")

    decoder = Decoder(
        input_files_directory=None,
        output_files_directory=None,
        decoder_conf_file="/home/airflow/decoder_project/config_files/decoder_conf.json",
    )
    decoder.decode("6902892")
