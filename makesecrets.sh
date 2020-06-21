#!/bin/bash

# Generate st2 datastore crypto key on st2 startup
# https://docs.stackstorm.com/datastore.html#securing-secrets-admin-only

# this needs to run as root, so can't be ran in the st2api container
KEYPATH=/etc/st2/keys/datastore_key.json
if [ ! -f "${KEYPATH}" ]; then
  echo "Generating ${KEYPATH}"
  st2-generate-symmetric-crypto-key --key-path ${KEYPATH}
  chown -R st2:st2 /etc/st2/keys
  chmod -R 750 /etc/st2/keys
fi
