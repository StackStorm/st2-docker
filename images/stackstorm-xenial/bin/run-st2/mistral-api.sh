#!/bin/bash
set -e

NAME=mistral
COMPONENTS="api,engine,executor,notifier"
API_ARGS="--log-file /var/log/mistral/mistral-api.log -b 127.0.0.1:8989 -w 2 mistral.api.wsgi --graceful-timeout 10"

# Read configuration variable file if it is present
set -o allexport
[ -r /etc/default/$NAME ] && . /etc/default/$NAME
set +o allexport

# NB! Exit if mistral-api is disabled
. /opt/stackstorm/mistral/share/sysvinit/helpers
enabled_list -q api || exit 0

exec /opt/stackstorm/mistral/bin/gunicorn $API_ARGS
