#!/bin/bash

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd -P )"
SCRIPT_DIRNAME="$(basename "${SCRIPT_PATH}")"

# Running in the installation or dist directory
LDPATH="$(dirname "${SCRIPT_PATH}")/lib"
CONFIG_FILE="$(dirname "${SCRIPT_PATH}")/etc/carrier/tests.conf"

if [ ! -e ${CONFIG_FILE} ]; then
    echo "Error: Carrier api tests config file not available"
    exit 1
fi

if [ ! -e ${SCRIPT_PATH}/elatests ]; then
    echo "Error: Carrier api tests program not available."
    exit 1
fi

HOST="$(uname -s)"

case "${HOST}" in
    "Darwin")
        DSO_ENV=DYLD_LIBRARY_PATH
        ;;
    "Linux")
        DSO_ENV=LD_LIBRARY_PATH
        ;;
    *)
        echo "Error: Unsupported platform"
        exit 1;;
esac

export ${DSO_ENV}=${LDPATH}

if [ "$1" != "" ]; then
    ${SCRIPT_PATH}/elatests $*
else
    EXIT_CODE=0
    loop=1
    while [ $EXIT_CODE -eq 0 ]; do
        sleep 2
        echo "Start loop test :"$loop
        let loop+=1
        ${SCRIPT_PATH}/elatests --robot -c ${CONFIG_FILE} $* &
        ${SCRIPT_PATH}/elatests --cases -c ${CONFIG_FILE} -r 3 $*
        EXIT_CODE=$?
    done
    echo "total loop test :"$loop
    echo "EXIT_CODE:" $EXIT_CODE
fi
