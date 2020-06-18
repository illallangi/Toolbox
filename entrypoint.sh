#!/usr/bin/env sh

TOOLBX_COMMAND=${@:-/bin/sleep 24h}

echo $TOOLBX_COMMAND
$TOOLBX_COMMAND