#!/bin/bash
set -e

NAME=st2api
DAEMON_ARGS="-k eventlet -b 127.0.0.1:9101 --workers 1 --threads 1 --graceful-timeout 10 --timeout 30 --log-config /etc/st2/logging.api.gunicorn.conf"

# Read configuration variable file if it is present
set -o allexport
[ -r /etc/default/$NAME ] && . /etc/default/$NAME
set +o allexport

exec /opt/stackstorm/st2/bin/gunicorn st2api.wsgi:application $DAEMON_ARGS
