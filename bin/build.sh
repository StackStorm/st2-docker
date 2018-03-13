#!/bin/bash
#
# This script runs within the CircleCI environment to build stackstorm images.

set -euo pipefail
IDS=$'\n\t'

CIRCLE_SHA1=${CIRCLE_SHA1:-}
echo CIRCLE_SHA1=${CIRCLE_SHA1}

CIRCLE_TAG=${CIRCLE_TAG:-}
echo CIRCLE_TAG=${CIRCLE_TAG}

BUILD_DEV=${BUILD_DEV:-}
echo BUILD_DEV=${BUILD_DEV}

if [ -z ${CIRCLE_SHA1} ]; then
  echo "ERROR: CIRCLE_SHA1 is not defined."
  echo "To resolve, run:"
  echo "  $ export CIRCLE_SHA1=<commit_sha>"
  echo "  $ $0"
  exit 1
fi

# Get the latest tag beginning with 'v'
latest=`git tag -l "v*" | sort -r | head -1`
echo latest=${latest}

if [ ! -z ${CIRCLE_TAG} ]; then
  if [[ ! ${CIRCLE_TAG} =~ ^v(.+)$ ]]; then
    echo "ERROR: CIRCLE_TAG must begin with 'v'"
    exit 1
  fi
fi

if [[ ${CIRCLE_TAG} =~ ^v(.+)$ ]]; then
  # A tag was pushed, so we'll build an image using this specific release.
  tag=${BASH_REMATCH[1]}
  if [[ ${CIRCLE_TAG} =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
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
  if [ -z ${BUILD_DEV} ]; then
    # This is not a dev build
    st2_tag=${tag}

    if [ -z ${CIRCLE_TAG} ]; then
      # A tag was not pushed, so we only need to build 'latest'
      tag=''
      colon=''
    else
      tag="${tag}"
      colon=':'
    fi

    name_tag="${name}${colon}${tag}"

    docker build --build-arg ST2_TAG=${st2_tag} --build-arg CIRCLE_SHA1=${CIRCLE_SHA1} \
      --build-arg CIRCLE_PROJECT_USERNAME=${CIRCLE_PROJECT_USERNAME:-} \
      --build-arg CIRCLE_PROJECT_REPONAME=${CIRCLE_PROJECT_REPONAME:-} \
      --build-arg CIRCLE_BUILD_URL=${CIRCLE_BUILD_URL:-} \
      -t stackstorm/${name_tag} images/${name}

    if [ "v${tag}" == "${latest}" ]; then
      docker tag stackstorm/${name_tag} stackstorm/${name}:${short_tag:-}
    else
      echo "No need to tag build with two digit tag (v${tag} != ${latest})"
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
