#!/bin/bash

ST2_USER=${ST2_USER:-st2admin}
ST2_PASSWORD=${ST2_PASSWORD:-Ch@ngeMe}
RMQ_USER=${RABBITMQ_DEFAULT_USER:-admin}
RMQ_PASS=${RABBITMQ_DEFAULT_PASS:-pwd123}

# Create htpasswd file and login to st2 using specified username/password
htpasswd -b /etc/st2/htpasswd ${ST2_USER} ${ST2_PASSWORD}

crudini --set /etc/st2/st2.conf messaging url amqp://${RMQ_USER}:${RMQ_PASS}@rabbitmq:5672

# After init is running:
#  $ st2 login -p ${ST2_PASSWORD} -w ${ST2_USER}
#  $ export ST2_AUTH_TOKEN=`st2 auth -t -p Ch@ngeMe st2admin`
#  $ st2 run packs.setup_virtualenv packs=examples

exec /sbin/init
