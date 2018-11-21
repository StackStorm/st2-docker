#!/bin/bash
set -e

NAME=st2chatops
DAEMON_ARGS=""

# Read configuration variable file if it is present
set -o allexport
[ -r /etc/default/$NAME ] && . /etc/default/$NAME
set +o allexport

cd /opt/stackstorm/chatops

exec bin/hubot $DAEMON_ARGS >> /var/log/st2/st2chatops.log 2>&1
