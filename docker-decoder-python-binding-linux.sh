#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# 🐚 Argo Decoder Runner (Docker Compose)
#
# Usage:
#   ./run-decoder-compose.sh FLOAT_WMO [DECODER_IMAGE_TAG]
#
# Parameters:
#   FLOAT_WMO          (required) WMO identifier of the float to decode.
#                      Example: 6902892
#
#   DECODER_IMAGE_TAG  (optional) Tag of the decoder image to use.
#                      Default: "066a"
#
# Description:
#   This script prepares environment variables and runs the Argo float decoder
#   using Docker Compose.
#   - FLOAT_WMO defines which float will be decoded.
#   - DECODER_IMAGE_TAG allows to select a specific decoder container version.
#
# Example:
#   ./run-decoder-compose.sh 6902892
#   ./run-decoder-compose.sh 6902892 066b
#
# Options:
#   -h, --help         Show this help message and exit.
###############################################################################

# Show help if requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  grep '^#' "$0" | sed -E 's/^# ?//'
  exit 0
fi

export FLOAT_WMO=$1
if [[ -z "${FLOAT_WMO}" ]]; then
    echo "[ERROR] FLOAT_WMO required ! please execute script with FLOAT_WMO as parameter." >&2
    exit 1
fi


# Define Decoder image to use
export DECODER_IMAGE_TAG=${2:-"066a"}

# User uid and gid from the current user
export USER_ID=$UID
export GROUP_ID=$(id -g $UID)

export DECODER_COMMAND=$(
  echo \
    /mnt/runtime \
    rsynclog all \
    configfile /mnt/data/config/decoder_conf.json \
    xmlreport "co041404_$(date -u +"%Y%m%dT%H%M%SZ")_${FLOAT_WMO}.xml" \
    floatwmo "$FLOAT_WMO" \
    PROCESS_REMAINING_BUFFERS 1
)

docker compose --profile default --profile matlab down
docker compose --profile default --profile matlab up --build