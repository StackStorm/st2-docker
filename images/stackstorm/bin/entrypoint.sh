#!/bin/bash

ST2_USER=${ST2_USER:-st2admin}
ST2_PASSWORD=${ST2_PASSWORD:-Ch@ngeMe}
RMQ_USER=${RABBITMQ_DEFAULT_USER:-admin}
RMQ_PASS=${RABBITMQ_DEFAULT_PASS:-pwd123}

# Create htpasswd file and login to st2 using specified username/password
htpasswd -b /etc/st2/htpasswd ${ST2_USER} ${ST2_PASSWORD}

mkdir -p /root/.st2
touch /root/.st2/config

crudini --set /etc/st2/st2.conf messaging url amqp://${RMQ_USER}:${RMQ_PASS}@rabbitmq:5672
crudini --set /root/.st2/config credentials username ${ST2_USER}
crudini --set /root/.st2/config credentials password ${ST2_PASSWORD}

crudini --set /etc/st2/st2.conf mistral api_url http://127.0.0.1:9101
crudini --set /etc/st2/st2.conf mistral v2_base_url http://127.0.0.1:8989/v2

exec /sbin/init
