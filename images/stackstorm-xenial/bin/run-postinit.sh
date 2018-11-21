#!/bin/bash
set -eux

ENV_FILE=/st2-docker/env

if [ -f ${ENV_FILE} ]; then
  source ${ENV_FILE}
fi

# Wait until st2api becomes ready.
# Assumes that st2api is listening on the default port, 9101.
# `wget` exits with code 6 when it fails to authenticate, which is expected here.
# TODO: Switch to check /healtzh or whatever the health check endpoint URI
# once that capability is implemented into st2api
wget --tries 5 --retry-connrefused -q -O /dev/null http://localhost:9101 || [ $? -eq 6 ]

# Run custom init scripts which require ST2 to be running
for f in /st2-docker/st2.d/*; do
  case "$f" in
    *.sh) echo "$0: running $f"; . "$f" ;;
    *)    echo "$0: ignoring $f" ;;
  esac
  echo
done
