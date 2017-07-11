#!/bin/bash

echo DOCKER_USER=${DOCKER_USER}
echo DOCKER_PASSWORD=${DOCKER_PASSWORD}

exit 0

docker login --username ${DOCKER_USER} --password ${DOCKER_PASSWORD} --email ${DOCKER_EMAIL}
docker push stackstorm:stackstorm/${ST2_TAG}

docker build --build-arg ST2_TAG=${ST2_TAG} -t stackstorm/stackstorm:${ST2_TAG} images/stackstorm

if [ "$ST2_TAG" == "$LATEST" ]; then
  # Also build the latest image
  docker build --build-arg ST2_TAG=${ST2_TAG} -t stackstorm/stackstorm:latest images/stackstorm
fi
