#!/bin/bash

set -e

echo CIRCLE_TAG=${CIRCLE_TAG}

LATEST=`git tag -l | sort -r | head -1`
echo LATEST=${LATEST}

docker login --username ${DOCKER_USER} --password ${DOCKER_PASSWORD} --email ${DOCKER_EMAIL}

# If CIRCLE_TAG is not zero length and starts with "v", then build the specific tag
# (this only happens after that StackStorm release)
if [[ $CIRCLE_TAG =~ ^v(.+)$ ]]; then
  ST2_TAG=${BASH_REMATCH[1]}
  docker build --build-arg ST2_TAG=${ST2_TAG} -t stackstorm/stackstorm:${ST2_TAG} images/stackstorm
  docker push stackstorm/stackstorm:${ST2_TAG}
fi

# If TAG is zero length, then only build the 'latest' image
# (this usually happens when developing st2-docker)
if [ -z $CIRCLE_TAG ]; then
  # Build the latest image (using $LATEST version of ST2)
  docker build --build-arg ST2_TAG=${LATEST} --build-arg ST2_DOCKER_SHA1=${CIRCLE_SHA1} \
    -t stackstorm/stackstorm:latest images/stackstorm
  docker push stackstorm/stackstorm:latest
fi
