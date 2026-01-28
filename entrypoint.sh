#!/bin/sh
APP_NAME=argo-decoder
BASEDIR=/app

################################################################################
# CHECKS
################################################################################

# checks that the container is not running as root
USER_UID=$(id -u)
if [ "${USER_UID}" -eq 0 ]; then
    echo "[ERROR] The container cannot be run as root  (UID =0) ! Did you forget to launch the container with '-u <user>' or '-u <uid>' option ?" >&2
    exit 3
fi

# checks that mounts exists
if [ ! -d ${DATA_DIR} ]; then
    echo "[ERROR] Data directory not found: '${DATA_DIR}'" >&2
    exit 3
fi
if [ ! -d ${RUNTIME_DIR} ]; then
    echo "[ERROR] Runtime directory not found: '${RUNTIME_DIR}'" >&2
    exit 3
fi
if [ ! -d ${REF_DIR} ]; then
    echo "[ERROR] References directory not found: '${REF_DIR}'" >&2
    exit 3
fi

# Comment this code as exclusionlist no longer being available publicly, need to be mount on the container directly
# wget -O /tmp/ar_exclusionlist.txt https://data-argo.ifremer.fr/ar_exclusionlist.txt || rm -f /tmp/ar_exclusionlist.txt
# if [ ! -f /tmp/ar_exclusionlist.txt ]; then
#     echo "[ERROR] TEST015_GREY_LIST_FILE file not found: file should had have downloaded here 'https://data-argo.ifremer.fr/ar_exclusionlist.txt', please check if that this URL is reachable" >&2
#     exit 3
# fi

# JAVA_OPTS="-D${APP_NAME}.basedir=${BASEDIR}"
echo "*** Starting ${APP_NAME} batch ***"
${APP_HOME}/${APP_RUN_FILE} $@