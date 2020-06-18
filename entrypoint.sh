#!/usr/bin/env sh

TOOLBOX_COMMAND=${@:-/bin/sleep 24h}

echo $TOOLBOX_COMMAND
$TOOLBOX_COMMAND