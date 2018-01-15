#!/bin/bash
#
# This script runs within the CircleCI environment to build stackstorm images.

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
echo BUILD_DEV=${BUILD_DEV:-}
latest=`git tag -l | sort -r | head -1`
echo latest=${latest}

if [[ ${CIRCLE_TAG:-} =~ ^v(.+)$ ]]; then
  # A tag was pushed, so we'll build an image using this specific release.
  tag=${BASH_REMATCH[1]}
  if [[ ${CIRCLE_TAG:-} =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    short_tag="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
  fi
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

for name in stackstorm; do
  if [ -z ${BUILD_DEV:-} ]; then
    # This is not a dev build
    ST2_TAG=${tag}

    if [ -z ${CIRCLE_TAG:-} ]; then
      # A tag was not pushed, so we only need to build 'latest'
      tag='latest'
    fi

    docker build --build-arg ST2_TAG=${ST2_TAG} --build-arg CIRCLE_SHA1=${CIRCLE_SHA1:-} \
      --build-arg CIRCLE_PROJECT_USERNAME=${CIRCLE_PROJECT_USERNAME:-} \
      --build-arg CIRCLE_PROJECT_REPONAME=${CIRCLE_PROJECT_REPONAME:-} \
      --build-arg CIRCLE_BUILD_URL=${CIRCLE_BUILD_URL:-} \
      -t stackstorm/${name}:${tag} images/${name}

    if [ "v${tag}" == "${latest}" ]; then
      docker tag stackstorm/${name}:${tag} stackstorm/${name}:latest
      docker tag stackstorm/${name}:${tag} stackstorm/${name}:${short_tag:-}
    elif [ "${tag}" ==  "latest" ]; then
      echo "${tag} == latest"
      docker tag stackstorm/${name}:${tag} stackstorm/${name}:latest
    else
      echo "v${tag} != ${latest}"
    fi
  else
    # Triggered to run nightly via ops-infra
    # Build unstable, and tag as "dev".

    # TODO: Potentially useful to prepend "dev" with revision of latest unstable
    #       release (e.g. "2.4dev")

    docker build --build-arg ST2_REPO=unstable --build-arg CIRCLE_SHA1=${CIRCLE_SHA1} \
      --build-arg CIRCLE_PROJECT_USERNAME=${CIRCLE_PROJECT_USERNAME:-} \
      --build-arg CIRCLE_PROJECT_REPONAME=${CIRCLE_PROJECT_REPONAME:-} \
      --build-arg CIRCLE_BUILD_URL=${CIRCLE_BUILD_URL:-} \
      -t stackstorm/${name}:dev images/${name}
  fi
done
