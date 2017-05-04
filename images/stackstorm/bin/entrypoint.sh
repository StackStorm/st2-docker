#!/bin/bash

ST2_USER=${ST2_USER:-st2admin}
ST2_PASSWORD=${ST2_PASSWORD:-Ch@ngeMe}
RMQ_USER=${RABBITMQ_DEFAULT_USER:-admin}
RMQ_PASS=${RABBITMQ_DEFAULT_PASS:-pwd123}

# Create htpasswd file and login to st2 using specified username/password
htpasswd -b /etc/st2/htpasswd ${ST2_USER} ${ST2_PASSWORD}

mkdir -p /root/.st2

ROOT_CONF=/root/.st2/config

touch ${ROOT_CONF}

crudini --set ${ROOT_CONF} credentials username ${ST2_USER}
crudini --set ${ROOT_CONF} credentials password ${ST2_PASSWORD}

ST2_CONF=/etc/st2/st2.conf

crudini --set ${ST2_CONF} mistral api_url http://127.0.0.1:9101
crudini --set ${ST2_CONF} mistral v2_base_url http://127.0.0.1:8989/v2
crudini --set ${ST2_CONF} messaging url amqp://${RMQ_USER}:${RMQ_PASS}@rabbitmq:5672

# NOTE: Only certain distros of MongoDB support SSL/TLS
#  1) enterprise versions
#  2) those built from source (https://github.com/mongodb/mongo/wiki/Build-Mongodb-From-Source)
#
#crudini --set ${ST2_CONF} database ssl True
#crudini --set ${ST2_CONF} database ssl_keyfile None
#crudini --set ${ST2_CONF} database ssl_certfile None
#crudini --set ${ST2_CONF} database ssl_cert_reqs None
#crudini --set ${ST2_CONF} database ssl_ca_certs None
#crudini --set ${ST2_CONF} database ssl_match_hostname True

MISTRAL_CONF=/etc/mistral/mistral.conf

crudini --set ${MISTRAL_CONF} DEFAULT transport_url rabbit://${RMQ_USER}:${RMQ_PASS}@rabbitmq:5672
crudini --set ${MISTRAL_CONF} database connection postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres/${POSTGRES_DB}

exec /sbin/init
