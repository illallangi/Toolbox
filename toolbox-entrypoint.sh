#!/usr/bin/env sh

SLEEP=$(which sleep)
if [[ ! -x $SLEEP ]]; then
  echo "sleep binary not found"
  exit 1
fi

$SLEEP 24h