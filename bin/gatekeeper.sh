#!/bin/bash

set -euo pipefail
IDS=$'\n\t'

if [ $# -lt 2 ]; then
  echo "Usage: $0 <name> <tag>"
  exit 1
fi

name=$1
tag=$2

if [ ${tag} == 'latest' ]; then
  echo 'allow'
  exit 0
fi

wget -q https://registry.hub.docker.com/v1/repositories/stackstorm/${name}/tags -O - \
  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}' | grep ${tag} \
 || echo 'allow'
