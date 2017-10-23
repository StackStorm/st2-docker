#!/bin/bash

ENV_FILE=/st2-docker/env

if [ -f ${ENV_FILE} ]; then
  source ${ENV_FILE}
fi

# Run custom init scripts which require ST2 to be running
for f in /st2-docker/st2.d/*; do
  case "$f" in
    *.sh) echo "$0: running $f"; . "$f" ;;
    *)    echo "$0: ignoring $f" ;;
  esac
  echo
done
