#!/bin/bash

ST2_CONF=/etc/st2/st2.conf
crudini --set ${ST2_CONF} auth    api_url     ${ST2_API_URL}
crudini --set ${ST2_CONF} mistral api_url     ${ST2_API_URL}
crudini --set ${ST2_CONF} mistral v2_base_url ${ST2_MISTRAL_API_URL}

crudini --set ${ST2_CONF} api allow_origin '*'


case "$ST2_SERVICE" in
  "nop" )
    exec tail -f /dev/null
    ;;
  "st2api" )
    DAEMON_ARGS="-k eventlet -b 0.0.0.0:9101 --workers 1 --threads 1 --graceful-timeout 10 --timeout 30"
    exec /opt/stackstorm/st2/bin/gunicorn_pecan /opt/stackstorm/st2/lib/python2.7/site-packages/st2api/gunicorn_config.py $DAEMON_ARGS
    ;;
  "st2auth" )
    DAEMON_ARGS="-k eventlet -b 0.0.0.0:9100 --workers 1 --threads 1 --graceful-timeout 10 --timeout 30"
    exec /opt/stackstorm/st2/bin/gunicorn_pecan /opt/stackstorm/st2/lib/python2.7/site-packages/st2auth/gunicorn_config.py $DAEMON_ARGS
    ;;
  "st2stream" )
    DAEMON_ARGS="-k eventlet -b 0.0.0.0:9102 --workers 1 --threads 10 --graceful-timeout 10 --timeout 30"
    exec /opt/stackstorm/st2/bin/gunicorn_pecan /opt/stackstorm/st2/lib/python2.7/site-packages/st2stream/gunicorn_config.py $DAEMON_ARGS
    ;;
  "st2sensorcontainer" )
    DAEMON_ARGS="--config-file /etc/st2/st2.conf"
    exec /opt/stackstorm/st2/bin/st2sensorcontainer ${DAEMON_ARGS}
    ;;
  "st2rulesengine" )
    DAEMON_ARGS="--config-file /etc/st2/st2.conf"
    exec /opt/stackstorm/st2/bin/st2rulesengine ${DAEMON_ARGS}
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
    exec /opt/stackstorm/mistral/bin/mistral-server --server engine,executor ${SERVER_ARGS}
    ;;
  "st2web" )
    exec /usr/sbin/nginx -g 'daemon off;'
    ;;
  "st2-register-content" )
    set -ex
    PACKS=${PACKS:-"chatops core default linux packs"}
    for PACK in ${PACKS}; do
      st2-register-content --config-file /etc/st2/st2.conf --register-all --register-setup-virtualenvs \
        --register-pack /opt/stackstorm/packs/${PACK}
    done
    ;;

esac
