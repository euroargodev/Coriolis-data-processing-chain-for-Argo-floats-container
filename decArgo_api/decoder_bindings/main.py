"""API Entrypoint."""

import logging
import os
import tempfile

from fastapi import FastAPI, Form, HTTPException, UploadFile
from fastapi.responses import StreamingResponse

from decoder_bindings.decoder import Decoder, DecoderError
from decoder_bindings.file_manager import FileManager, FileManagerError
from decoder_bindings.prepare_float_metadata import FloatMetadataManager, MissingFloatInfoError, MissingFloatMetaError
from decoder_bindings.zip_nc_files import ZipNCFiles, ZipNCFilesError

logging.basicConfig(level=logging.INFO)

ROOT_PATH = os.getenv("API_ROOT_PATH", "")
app = FastAPI(root_path=ROOT_PATH)


@app.post("/decode_float/{wmonum}")
async def decode_float(
    wmonum: str, files: list[UploadFile], float_metadata: str = Form(...), configuration_override: str = Form(None)
):
    """Invoke the decoder and return a ZIP file of the decoded NC files.

    Args:
        wmonum: The WMONUM of the raw files to be decoded.
        files: A list of files to be decoded.
        float_metadata: The meta & info payloads for a specific float.
        configuration_override: Any additional configuration to run the decoder with.

    Returns: A zipfile, or a dict containing an error message.
    """
    logging.info("Running for WMONUM: %s", wmonum)
    logging.info("Running for Files: %s", files)

    # Write the metadata JSON files to file, and simultaneously provide the IMEI for use further down the chain.
    # If any errors are raised at this stage we will exit early and log an appropriate message back as a response.
    try:
        float_metadata = FloatMetadataManager(wmonum=wmonum, float_metadata=float_metadata)
    except (MissingFloatMetaError, MissingFloatInfoError) as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from None

    float_metadata.write_all_float_metadata_to_file()
    imei = float_metadata.imei

    # Given that the metadata is now in place, the main processing can now begin.
    try:
        # Copy the input files to their required location, and produce the 'rsync' file to pass to the decoder.
        rsync_file_name = FileManager(files=files, imei=imei).run()

        # Prepare a temporary directory, and pass its name to the decoder, the decoded files will be placed here.
        with tempfile.TemporaryDirectory(dir="/tmp") as temporary_output_directory:
            decoder = Decoder(
                input_files_directory=None,
                output_files_directory=temporary_output_directory,
                decoder_conf_file="/mnt/data/config/api.decoder_conf.json",
                extra_configuration=configuration_override,
            )
            # Run the decoder.
            decoder.decode(wmonum=wmonum, rsync_file=rsync_file_name)

            # The newly decoded files are now picked from the temp directory and zipped.
            zipfile, zip_filename = ZipNCFiles(wmonum=wmonum).zip_all_nc_files()

    except (FileManagerError, ZipNCFilesError, DecoderError):
        return {"Message": "Zip file not generated. Check the logs for more information."}
    else:
        return StreamingResponse(
            zipfile,
            media_type="application/zip",
            headers={"Content-Disposition": f"attachment; filename={zip_filename}"},
        )
