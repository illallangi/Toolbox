#!/bin/bash

TARGET="${1:-${PWD}}"
PERM_UID="${PERM_UID:-$(id -u)}"
PERM_GID="${PERM_GID:-$(id -g)}"
PERM_DIR="${PERM_DIR:-0755}"
PERM_FILE="${PERM_FILE:-0644}"

find "${TARGET}" ! -group ${PERM_GID}  -exec chown ${PERM_UID}.${PERM_GID} {} \;
find "${TARGET}" ! -user  ${PERM_UID}  -exec chown ${PERM_UID} {} \;

find "${TARGET}" -type d ! -perm ${PERM_DIR}  -exec chmod ${PERM_DIR} {} \;
find "${TARGET}" -type f ! -perm ${PERM_FILE} -exec chmod ${PERM_FILE} {} \;