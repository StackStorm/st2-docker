#!/bin/bash

ST2_USER=${1:-st2admin}
ST2_PASSWORD=${2:-Ch@ngeMe}

# Create htpasswd file and login to st2 using specified username/password
htpasswd -b /etc/st2/htpasswd ${ST2_USER} ${ST2_PASSWORD}

exec /sbin/init
