#!/bin/bash
set -e

NAME=st2auth
DAEMON_ARGS="-k eventlet -b 127.0.0.1:9100 --workers 1 --threads 1 --graceful-timeout 10 --timeout 30 --log-config /etc/st2/logging.auth.gunicorn.conf"

# Read configuration variable file if it is present
set -o allexport
[ -r /etc/default/$NAME ] && . /etc/default/$NAME
set +o allexport

exec /opt/stackstorm/st2/bin/gunicorn st2auth.wsgi:application $DAEMON_ARGS
