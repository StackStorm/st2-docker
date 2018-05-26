#!/bin/bash

set -euo pipefail

SSH_DIR=/home/stanley/.ssh
AUTHORIZED_KEYS=${SSH_DIR}/authorized_keys

SSH_PRIV_KEY=${SSH_DIR}/stanley_rsa
SSH_PUB_KEY=${SSH_PRIV_KEY}.pub

SSL_DIR=/etc/ssl/st2
ST2_KEY=${SSL_DIR}/st2.key
ST2_CRT=${SSL_DIR}/st2.crt

if [ ! -f ${SSH_PRIV_KEY} ]; then
  ssh-keygen -f ${SSH_PRIV_KEY} -P ""
fi

if ! grep -s -q -f ${SSH_PUB_KEY} ${AUTHORIZED_KEYS}; then
  cat ${SSH_PUB_KEY} >> ${AUTHORIZED_KEYS}
fi

if [ ! -f ${ST2_KEY} ]; then
  openssl req -x509 -newkey rsa:2048 -keyout ${ST2_KEY} -out ${ST2_CRT} -days 3650 -nodes -subj '/O=st2 self signed/CN=localhost'
fi
