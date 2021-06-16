#!/bin/bash

TARGET="${1:-${PWD}}"
PERM_UID="${PERM_UID:-$(id -u)}"
PERM_GID="${PERM_GID:-$(id -g)}"
PERM_DIR="${PERM_DIR:-0755}"
PERM_FILE="${PERM_FILE:-0644}"

chown -Rv ${PERM_UID}.${PERM_GID} "${TARGET}"
chmod -Rv ${PERM_DIR} "${TARGET}"
find "${TARGET}" -type f -print0 | xargs -0 chmod -v ${PERM_FILE}
