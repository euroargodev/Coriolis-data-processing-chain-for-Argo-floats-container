#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# 🐚 Argo Decoder Runner
#
# Usage:
#   ./run-decoder.sh FLOAT_WMO [MATLAB_RUNTIME_DIR]
#
# Parameters:
#   FLOAT_WMO           (required) WMO identifier of the float to decode.
#                       Example: 6902892
#
#   MATLAB_RUNTIME_DIR  (optional) Absolute path to MATLAB Runtime directory.
#                       If not provided, defaults to using the Docker volume
#                       "runtime-matlab-volume".
#
# Description:
#   This script runs the Argo float decoder inside a Docker container.
#   - FLOAT_WMO defines which float will be decoded.
#   - MATLAB runtime can be provided explicitly (host directory) or defaults
#     to the docker-managed runtime volume.
#
# Example:
#   ./run-decoder.sh 6902892
#   ./run-decoder.sh 6902892 /opt/matlab/runtime/R2024a
#
# Options:
#   -h, --help          Show this help message and exit.
###############################################################################

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  grep '^#' "$0" | sed -E 's/^# ?//'
  exit 0
fi

FLOAT_WMO=$1
if [[ -z "${FLOAT_WMO}" ]]; then
    echo "[ERROR] FLOAT_WMO required ! please execute script with FLOAT_WMO as parameter." >&2
    exit 1
fi

DECODER_IMAGE=ghcr.io/euroargodev/coriolis-data-processing-chain-for-argo-floats-container # decoder image path
DECODER_IMAGE_TAG=066a

DEFAULT_DECODER_RUNTIME_VOLUME="./path-to-be-define/matlab/runtime/R202XX"
DECODER_RUNTIME_VOLUME="${2:-$DEFAULT_DECODER_RUNTIME_VOLUME}"
DECODER_DATA_INPUT_VOLUME=./decArgo_demo/input
DECODER_DATA_CONF_VOLUME=./decArgo_demo/config
DECODER_DATA_OUTPUT_VOLUME=./decArgo_demo/output
# DECODER_REF_GEBCO_FILE=/path-to-gebco-file # optionnal
# DECODER_REF_GREYLIST_FILE=./decArgo_demo/config # optionnal

USER_ID=$UID
GROUP_ID=$(id -g $UID)

if [[ ! -d "$DECODER_RUNTIME_VOLUME" ]]; then
    echo "❌ You called script with external MATLAB runtime but directory '$DECODER_RUNTIME_VOLUME' does not exist."
    exit 1
fi

rm -rf $DECODER_DATA_OUTPUT_VOLUME/iridium/*$FLOAT_WMO 
rm -rf $DECODER_DATA_OUTPUT_VOLUME/nc/$FLOAT_WMO

export DECODER_COMMAND=$(
  echo \
    /mnt/runtime \
    rsynclog all \
    configfile /mnt/data/config/decoder_conf.json \
    xmlreport "co041404_$(date -u +"%Y%m%dT%H%M%SZ")_${FLOAT_WMO}.xml" \
    floatwmo "$FLOAT_WMO" \
    PROCESS_REMAINING_BUFFERS 1
)

docker run -it --rm \
--name "argo-decoder-container" \
--user $USER_ID:$GROUP_ID \
--group-add gbatch \
-v $DECODER_RUNTIME_VOLUME:/mnt/runtime:ro \
-v $DECODER_DATA_INPUT_VOLUME:/mnt/data/rsync:rw \
-v $DECODER_DATA_CONF_VOLUME:/mnt/data/config:ro \
-v $DECODER_DATA_OUTPUT_VOLUME:/mnt/data/output:rw \
$DECODER_IMAGE:$DECODER_IMAGE_TAG "$DECODER_COMMAND"
