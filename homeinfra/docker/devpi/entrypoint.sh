#!/bin/sh
set -eu

SERVERDIR="/data"

if [ ! -f "${SERVERDIR}/.serverversion" ]; then
    echo "Initializing devpi..."

    devpi-init \
        --serverdir "${SERVERDIR}"
fi

exec devpi-server \
    --serverdir "${SERVERDIR}" \
    --indexer-backend null \
    --request-timeout 60 \
    --host 0.0.0.0 \
    --port 3141
