#!/bin/bash
# this needs to run as root, so can't be ran in the st2api container
KEYPATH=/etc/st2/keys/datastore_key.json
if [ ! -f "/etc/st2/keys/datastore_key.json" ]
then
    echo "Generating ${KEYPATH}"
    st2-generate-symmetric-crypto-key --key-path /etc/st2/keys/datastore_key.json
    chown -R st2:st2 /etc/st2/keys
    chmod -R 750 /etc/st2/keys
fi

