#!/bin/bash

GOSU=$(which gosu)

if [ "${UID}" != "${PUID}" ]; then

  echo UID ${UID}
  echo GID ${GID}
  
  echo PUID ${PUID}
  echo PGID ${PGID}
  
  echo usermod -u ${PUID} abc
  usermod -u ${PUID} abc || exit 1
  echo groupmod -g ${PGID} abc
  groupmod -g ${PGID} abc || exit 1
  echo usermod -g ${PUID} abc
  usermod -g ${PUID} abc || exit 1

  echo ${GOSU} abc $0 $*
  ${GOSU} abc $0 $* || exit 1

else

  TOOLBX_COMMAND=${@:-/bin/sleep 24h}

  echo $TOOLBX_COMMAND
  $TOOLBX_COMMAND

fi