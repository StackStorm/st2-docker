#!/bin/bash

RC=${HOME}/.bashrc
SNIPPET=/st2-docker/entrypoint.d/sttysize.snippet

if ! grep -q sttysize ${RC}; then
  echo >> ${RC}
  echo "[ -r ${SNIPPET} ] && . ${SNIPPET}" >> ${RC}
fi
