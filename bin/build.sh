#!/bin/bash

set -e

env

echo $CIRCLE_BRANCH

exit 0

while [[ "$#" > 1 ]]; do case $1 in
  --tag) ST2_TAG="$2";;
  *) break;;
esac; shift; shift;
done

LATEST=`git tag -l | sort -r | head -1`

if [ "$ST2_TAG" == "$LATEST" ]; then
  # Also build the latest image
  docker build --build-arg ST2_TAG=${ST2_TAG} -t stackstorm/stackstorm:latest images/stackstorm
fi
