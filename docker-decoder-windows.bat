@echo off
setlocal enabledelayedexpansion

set "DECODER_IMAGE=ghcr.io/euroargodev/coriolis-data-processing-chain-for-argo-floats-container"
set "DECODER_IMAGE_TAG=066a"

set "DECODER_RUNTIME_VOLUME=C:\path-to-matlab-runtime\R2022b"
set "DECODER_DATA_INPUT_VOLUME=.\decArgo_demo\input"
set "DECODER_DATA_CONF_VOLUME=.\decArgo_demo\config"
set "DECODER_DATA_OUTPUT_VOLUME=.\decArgo_demo\output"
REM" set DECODER_REF_GEBCO_FILE=C:\path-to-gebco-file" # optionnal
REM "set DECODER_REF_EXCLUSION_FILE=C:\path-to-exclusion-file" # optionnal

REM Define float to decode
set "FLOAT_WMO=%~1"
if not defined FLOAT_WMO (
    echo [ERROR] FLOAT_WMO required ! please execute script with FLOAT_WMO as parameter. >&2
    pause
    exit /b 1
)
REM Define the decoder configuration file
REM set "DECODER_CONFIG_FILE=%~2"
REM if not defined DECODER_CONFIG_FILE set "DECODER_CONFIG_FILE=/mnt/data/config/decoder_conf.json"

REM if not exist "!DECODER_CONFIG_FILE!" (
REM    set "DECODER_CONFIG_FILE=/app/config/_argo_decoder_conf_ir_sbd.json"
REM    echo [WARN] no specific configuration file defined - Using the default configuration file !DECODER_CONFIG_FILE! ! >&2
REM    exit /b 2
REM )

REM Remove output directories (use rmdir for directories)
rmdir /s /q "%DECODER_DATA_OUTPUT_VOLUME%\iridium\*%FLOAT_WMO%" 2>nul
rmdir /s /q "%DECODER_DATA_OUTPUT_VOLUME%\nc\%FLOAT_WMO%" 2>nul

REM Get current date and time in the required format
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "formattedDateTime=%datetime:~0,4%%datetime:~4,2%%datetime:~6,2%T%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%Z"


REM Run Docker command
docker run -it --rm ^
--name "argo-decoder-container" ^
--user 1000:1000 ^
--group-add gbatch ^
-v "%DECODER_RUNTIME_VOLUME%:/mnt/runtime:ro" ^
-v "%DECODER_DATA_INPUT_VOLUME%:/mnt/data/rsync:rw" ^
-v "%DECODER_DATA_CONF_VOLUME%:/mnt/data/config:ro" ^
-v "%DECODER_DATA_OUTPUT_VOLUME%:/mnt/data/output:rw" ^
%DECODER_IMAGE%:%DECODER_IMAGE_TAG% /mnt/runtime "rsynclog" "all" "configfile" "/mnt/data/config/decoder_conf.json" "xmlreport" "co041404_%formattedDateTime%_%FLOAT_WMO%.xml" "floatwmo" "%FLOAT_WMO%" "PROCESS_REMAINING_BUFFERS" "1"

pause
