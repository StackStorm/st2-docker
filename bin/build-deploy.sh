#!/bin/bash
#
# This script runs within the CircleCI environment to build and deploy
# st2-docker images to Docker Hub.
#
# Generally speaking, we only maintain the image containing the latest release
# of StackStorm tagged in the st2-docker repo. To build an image with a
# specific release of StackStorm, push an annotated tag of the format "vX.Y.Z",
# where "v" is literal, and "X.Y.Z" is the release number. The tag will be made
# available within CircleCI using the $CIRCLE_TAG environment variable.
#
# If $CIRCLE_TAG has zero length, then no tag was pushed. The following image
# will be built:
#
#   stackstorm/stackstorm:X.Y.Z   (where X.Y.Z is the latest StackStorm release)
#
# If this image was already built, then it will be built again (using a
# potentially different Dockerfile). The image is only guaranteed to contain
# the specified StackStorm release.
#
# If X.Y.Z is the latest release, the following target image is set to refer
# to the above image:
#
#   stackstorm/stackstorm:latest

set -euo pipefail
IDS=$'\n\t'

if [ -z ${CIRCLE_SHA1:-} ]; then
  echo "ERROR: CIRCLE_SHA1 is not defined."
  echo "To resolve, run:"
  echo "  $ export CIRCLE_SHA1=<commit_sha>"
  echo "  $ $0"
  exit 1
fi

echo CIRCLE_TAG=${CIRCLE_TAG:-}
latest=`git tag -l | sort -r | head -1`
echo latest=${latest}

if [[ ${CIRCLE_TAG:-} =~ ^v(.+)$ ]]; then
  # A tag was pushed, so we'll build an image using this specific release.
  tag=${BASH_REMATCH[1]}
else
  # Build and tag an image using the latest StackStorm release
  if [[ ${latest} =~ ^v(.+)$ ]]; then
    tag=${BASH_REMATCH[1]}
  else
    echo "ERROR: Could not find a git tag in the st2-docker repo with format vX.Y.Z"
    echo "To resolve, run:"
    echo "  $ git co master"
    echo "  $ git tag -a 'vX.Y.Z' -m 'Stamping X.Y.Z' HEAD"
    echo "  $ git push --tags"
    exit 1
  fi
fi

echo tag=${tag}

if [ -z ${DOCKER_USER:-} ] || [ -z ${DOCKER_PASSWORD:-} ] ; then
  echo "ERROR: DOCKER_USER and/or DOCKER_PASSWORD are not defined."
  echo "To resolve, run:"
  echo "  $ export DOCKER_USER=<docker_login>"
  echo "  $ export DOCKER_PASSWORD=<docker_password>"
  echo "  $ $0"
  exit 1
fi

docker login --username ${DOCKER_USER} --password ${DOCKER_PASSWORD}

for name in stackstorm; do
  docker build --build-arg ST2_TAG=${tag} --build-arg ST2_DOCKER_SHA1=${CIRCLE_SHA1} \
    -t stackstorm/${name}:${tag} images/${name}
  docker push stackstorm/${name}:${tag}
  if [ "v${tag}" == "${latest}" ]; then
    docker tag stackstorm/${name}:${tag} stackstorm/${name}:latest
    docker push stackstorm/${name}:latest
  else
    echo "v${tag} != ${latest}"
  fi
done
