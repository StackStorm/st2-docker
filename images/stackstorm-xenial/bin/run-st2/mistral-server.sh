#!/bin/bash
set -e

NAME=mistral
COMPONENTS="api,engine,executor,notifier"
SERVER_ARGS="--config-file /etc/mistral/mistral.conf --log-file /var/log/mistral/mistral-server.log"

# Read configuration variable file if it is present
set -o allexport
[ -r /etc/default/$NAME ] && . /etc/default/$NAME
set +o allexport

# Exit if server components are disabled, otherwise inject them into args.
. /opt/stackstorm/mistral/share/sysvinit/helpers
enabled_list -q server || exit 0

exec /opt/stackstorm/mistral/bin/mistral-server --server $(enabled_list server) ${SERVER_ARGS}
