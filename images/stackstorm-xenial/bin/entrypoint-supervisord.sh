#!/bin/bash
set -e

# set default path
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# set number of st2actionrunners to start
ST2ACTIONRUNNER_WORKERS=$(/usr/bin/nproc 2>/dev/null)
ST2ACTIONRUNNER_WORKERS=${ST2ACTIONRUNNER_WORKERS:-10}
export ST2ACTIONRUNNER_WORKERS

# Read configuration variable file if it is present
set -o allexport
[ -r /etc/default/supervisord ] && . /etc/default/supervisord
set +o allexport

# launch supervisord
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
