#!/bin/bash
set -e

NAME=st2actionrunner
DAEMON_ARGS="--config-file /etc/st2/st2.conf"

# Read configuration variable file if it is present
set -o allexport
[ -r /etc/default/$NAME ] && . /etc/default/$NAME
set +o allexport

# Load global locale settings
test -f /etc/default/locale && . /etc/default/locale || true

# 
LANG=$LANG LC_ALL=$LANG exec /sbin/start-stop-daemon --start \
  --pidfile /dev/null \
  --group st2packs \
  --umask 002 \
  --exec /opt/stackstorm/st2/bin/$NAME -- ${DAEMON_ARGS}
