#!/bin/bash

ST2USER=$1
ST2PASSWORD=$2

htpasswd -bs /etc/st2/htpasswd ${ST2USER} ${ST2PASSWORD}
st2 login -p ${ST2PASSWORD} ${ST2USER}

echo "export ST2USER='${ST2USER}'" > ~root/st2.vars
echo "export ST2PASSWORD='${ST2PASSWORD}'" >> ~root/st2.vars
echo "export ST2_AUTH_TOKEN='`st2 auth -t -p ${ST2PASSWORD} ${ST2USER}`'" >> ~root/st2.vars

chmod 0400 ~root/st2.vars
