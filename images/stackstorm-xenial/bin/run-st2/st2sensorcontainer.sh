#!/bin/bash
set -e

NAME=st2sensorcontainer
DAEMON_ARGS="--config-file /etc/st2/st2.conf"

# Read configuration variable file if it is present
set -o allexport
[ -r /etc/default/$NAME ] && . /etc/default/$NAME
set +o allexport

exec /opt/stackstorm/st2/bin/$NAME ${DAEMON_ARGS}
