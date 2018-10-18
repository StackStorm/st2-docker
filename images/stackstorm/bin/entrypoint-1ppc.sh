#!/bin/bash

ST2_CONF=/etc/st2/st2.conf
crudini --set ${ST2_CONF} auth    api_url     ${ST2_API_URL}
crudini --set ${ST2_CONF} mistral api_url     ${ST2_API_URL}
crudini --set ${ST2_CONF} mistral v2_base_url ${ST2_MISTRAL_API_URL}

# Configure CORS to accept any source
# st2api gunicorn process is directly exposed to clients in 1ppc mode
crudini --set ${ST2_CONF} api allow_origin '*'

# Generate nginx config for st2web to support load balancing to st2api, st2auth and st2stream
/st2-docker/bin/inject_env.py \
  < /etc/nginx/conf.d/st2-1ppc.conf.tpl \
  > /etc/nginx/conf.d/st2.conf

case "$ST2_SERVICE" in
  "nop" )
    exec tail -f /dev/null
    ;;
  "st2api" )
    DAEMON_ARGS="-k eventlet -b 0.0.0.0:9101 --workers 1 --threads 1 --graceful-timeout 10 --timeout 30"
    exec /opt/stackstorm/st2/bin/gunicorn st2api.wsgi:application $DAEMON_ARGS
    ;;
  "st2auth" )
    DAEMON_ARGS="-k eventlet -b 0.0.0.0:9100 --workers 1 --threads 1 --graceful-timeout 10 --timeout 30"
    exec /opt/stackstorm/st2/bin/gunicorn st2auth.wsgi:application $DAEMON_ARGS
    ;;
  "st2stream" )
    DAEMON_ARGS="-k eventlet -b 0.0.0.0:9102 --workers 1 --threads 10 --graceful-timeout 10 --timeout 30"
    exec /opt/stackstorm/st2/bin/gunicorn st2stream.wsgi:application $DAEMON_ARGS
    ;;
  "st2sensorcontainer" )
    DAEMON_ARGS="--config-file /etc/st2/st2.conf"
    exec /opt/stackstorm/st2/bin/st2sensorcontainer ${DAEMON_ARGS}
    ;;
  "st2rulesengine" )
    DAEMON_ARGS="--config-file /etc/st2/st2.conf"
    exec /opt/stackstorm/st2/bin/st2rulesengine ${DAEMON_ARGS}
    ;;
  "st2workflowengine" )
    DAEMON_ARGS="--config-file /etc/st2/st2.conf"
    exec /opt/stackstorm/st2/bin/st2workflowengine ${DAEMON_ARGS}
    ;;
  "st2actionrunner" )
    DAEMON_ARGS="--config-file /etc/st2/st2.conf"
    exec /opt/stackstorm/st2/bin/st2actionrunner ${DAEMON_ARGS}
    ;;
  "st2resultstracker" )
    DAEMON_ARGS="--config-file /etc/st2/st2.conf"
    exec /opt/stackstorm/st2/bin/st2resultstracker ${DAEMON_ARGS}
    ;;
  "st2notifier" )
    DAEMON_ARGS="--config-file /etc/st2/st2.conf"
    exec /opt/stackstorm/st2/bin/st2notifier ${DAEMON_ARGS}
    ;;
  "st2garbagecollector" )
    DAEMON_ARGS="--config-file /etc/st2/st2.conf"
    exec /opt/stackstorm/st2/bin/st2garbagecollector ${DAEMON_ARGS}
    ;;
  "st2timersengine" )
    DAEMON_ARGS="--config-file /etc/st2/st2.conf"
    exec /opt/stackstorm/st2/bin/st2timersengine ${DAEMON_ARGS}
    ;;
  "mistral-api" )
    set -e
    /opt/stackstorm/mistral/bin/mistral-db-manage --config-file /etc/mistral/mistral.conf upgrade head
    /opt/stackstorm/mistral/bin/mistral-db-manage --config-file /etc/mistral/mistral.conf populate
    API_ARGS="--log-file /var/log/mistral/mistral-api.log -b 0.0.0.0:8989 -w 2 mistral.api.wsgi --graceful-timeout 10"
    exec /opt/stackstorm/mistral/bin/gunicorn $API_ARGS
    ;;
  "mistral-server" )
    set -e
    /opt/stackstorm/mistral/bin/mistral-db-manage --config-file /etc/mistral/mistral.conf upgrade head
    /opt/stackstorm/mistral/bin/mistral-db-manage --config-file /etc/mistral/mistral.conf populate
    SERVER_ARGS="--config-file /etc/mistral/mistral.conf --log-file /var/log/mistral/mistral-server.log"
    exec /opt/stackstorm/mistral/bin/mistral-server --server engine,executor,notifier ${SERVER_ARGS}
    ;;
  "st2web" )
    exec /usr/sbin/nginx -g 'daemon off;'
    ;;
  "st2chatops" )
    set -e
    export ST2_API=${ST2_API_URL}
    cd /opt/stackstorm/chatops
    exec bin/hubot $DAEMON_ARGS
    ;;
  "st2-register-content" )
    set -ex
    PACKS=${PACKS:-"chatops core default linux packs"}
    for PACK in ${PACKS}; do
      st2-register-content --config-file /etc/st2/st2.conf \
        --register-all \
        --register-setup-virtualenvs \
        --register-pack /opt/stackstorm/packs/${PACK}
    done
    ;;

esac
