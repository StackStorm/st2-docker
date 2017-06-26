#!/bin/bash

/etc/init.d/rsyslog start
/etc/init.d/ssh start
/etc/init.d/postgresql start
/etc/init.d/rabbitmq-server start
/etc/init.d/mongod
/etc/init.d/nginx start

st2ctl start

tail -F /var/log/st2/st2api.log

