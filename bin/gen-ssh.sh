#!/bin/bash

set -euo pipefail

SSH_DIR=ssh
AUTHORIZED_KEYS=${SSH_DIR}/authorized_keys

SSH_PRIV_KEY=${SSH_DIR}/stanley_rsa
SSH_PUB_KEY=${SSH_PRIV_KEY}.pub

mkdir -p ${SSH_DIR}

if [ ! -f ${SSH_PRIV_KEY} ]; then
  ssh-keygen -f ${SSH_PRIV_KEY} -P ""
fi

if ! grep -s -q -f ${SSH_PUB_KEY} ${AUTHORIZED_KEYS}; then
  cat ${SSH_PUB_KEY} >> ${AUTHORIZED_KEYS}
fi
