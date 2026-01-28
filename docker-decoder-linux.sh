#!/bin/bash

DECODER_IMAGE=ghcr.io/euroargodev/coriolis-data-processing-chain-for-argo-floats-container # decoder image path
DECODER_IMAGE_TAG=082m

DECODER_RUNTIME_VOLUME=/path-to-matlab-runtime/R2022b
DECODER_DATA_INPUT_VOLUME=./decArgo_demo/input
DECODER_DATA_CONF_VOLUME=./decArgo_demo/config
DECODER_DATA_OUTPUT_VOLUME=./decArgo_demo/output
# DECODER_REF_GEBCO_FILE=/path-to-gebco-file # optionnal
# DECODER_REF_EXCLUSION_FILE=/path-to-exclusion-file # optionnal

USER_ID=$UID
GROUP_ID=$(id -g $UID)

# Define float to decode
FLOAT_WMO=$1
if [[ -z "${FLOAT_WMO}" ]]; then
    echo "[ERROR] FLOAT_WMO required ! please execute script with FLOAT_WMO as parameter." >&2
    exit 1
fi
# Define the decoder configuration file
# DECODER_CONFIG_FILE=${2:-"/mnt/data/config/decoder_conf.json"}
# if [[ ! -f "${DECODER_CONFIG_FILE}" ]]; then
#     DECODER_CONFIG_FILE="/app/config/_argo_decoder_conf_ir_sbd.json"
#     echo "[WARN] no specific configuration file defined - Using the default configuration file  ${DECODER_CONFIG_FILE} !" >&2
#     exit 2
# fi


# Remove output directories (use rmdir for directories)
rm -rf $DECODER_DATA_OUTPUT_VOLUME/iridium/*$FLOAT_WMO 
rm -rf $DECODER_DATA_OUTPUT_VOLUME/nc/$FLOAT_WMO

# Run Docker command
docker run -it --rm \
--name "argo-decoder-container" \
--user $USER_ID:$GROUP_ID \
--group-add gbatch \
-v $DECODER_RUNTIME_VOLUME:/mnt/runtime:ro \
-v $DECODER_DATA_INPUT_VOLUME:/mnt/data/rsync:rw \
-v $DECODER_DATA_CONF_VOLUME:/mnt/data/config:ro \
-v $DECODER_DATA_OUTPUT_VOLUME:/mnt/data/output:rw \
$DECODER_IMAGE:$DECODER_IMAGE_TAG /mnt/runtime 'rsynclog' 'all' 'configfile' '/mnt/data/config/decoder_conf.json' 'xmlreport' 'co041404_'$(date +"%Y%m%dT%H%M%SZ")'_'$FLOAT_WMO'.xml' 'floatwmo' ''$FLOAT_WMO'' 'PROCESS_REMAINING_BUFFERS' '1'
