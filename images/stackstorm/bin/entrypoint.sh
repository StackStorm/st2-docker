#!/bin/bash

file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	unset "$fileVar"
	echo  $val
}

st2_user_var=$(file_env 'ST2_USER')
st2_pass_var=$(file_env 'ST2_PASSWORD')
rabbitmq_user_var=$(file_env 'RABBITMQ_DEFAULT_USER')
rabbitmq_pass_var=$(file_env 'RABBITMQ_DEFAULT_PASS')
redis_pass_var=$(file_env 'REDIS_PASSWORD')
mongo_user_var=$(file_env 'MONGO_USER')
mongo_pass_var=$(file_env 'MONGO_PASS')
postgres_user_var=$(file_env 'POSTGRES_USER')
postgres_pass_var=$(file_env 'POSTGRES_PASSWORD')

# Create htpasswd file and login to st2 using specified username/password
htpasswd -b /etc/st2/htpasswd ${st2_user_var} ${st2_pass_var}

mkdir -p /root/.st2

ROOT_CONF=/root/.st2/config

touch ${ROOT_CONF}

crudini --set ${ROOT_CONF} credentials username ${st2_user_var}
crudini --set ${ROOT_CONF} credentials password ${st2_pass_var}

ST2_CONF=/etc/st2/st2.conf

crudini --set ${ST2_CONF} mistral api_url http://127.0.0.1:9101
crudini --set ${ST2_CONF} mistral v2_base_url http://127.0.0.1:8989/v2
crudini --set ${ST2_CONF} messaging url \
  amqp://${rabbitmq_user_var}:${rabbitmq_pass_var}@${RABBITMQ_HOST}:${RABBITMQ_PORT}
crudini --set ${ST2_CONF} coordination url \
  redis://${redis_pass_var}@${REDIS_HOST}:${REDIS_PORT}
crudini --set ${ST2_CONF} database host ${MONGO_HOST}
crudini --set ${ST2_CONF} database port ${MONGO_PORT}


if [ ! -z ${MONGO_DB} ]; then
  crudini --set ${ST2_CONF} database db_name ${MONGO_DB}
fi
if [ ! -z ${mongo_user_var} ]; then
  crudini --set ${ST2_CONF} database username ${mongo_user_var}
fi
if [ ! -z ${mongo_pass_var} ]; then
  crudini --set ${ST2_CONF} database password ${mongo_pass_var}
fi

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

crudini --set ${MISTRAL_CONF} DEFAULT transport_url \
  rabbit://${rabbitmq_user_var}:${rabbitmq_pass_var}@${RABBITMQ_HOST}:${RABBITMQ_PORT}
crudini --set ${MISTRAL_CONF} database connection \
  postgresql://${postgres_user_var}:${postgres_pass_var}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}

# Run custom init scripts
for f in /entrypoint.d/*; do
  case "$f" in
    *.sh) echo "$0: running $f"; . "$f" ;;
    *)    echo "$0: ignoring $f" ;;
  esac
  echo
done

exec /sbin/init
