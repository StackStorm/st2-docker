#!/bin/bash
#
# This script runs within the CircleCI environment to deploy st2-docker images
# to Docker Hub.

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
latest=$(git tag -l | sort -r | head -1)
echo latest=${latest}

if [[ ${CIRCLE_TAG:-} =~ ^v(.+)$ ]]; then
  # A tag was pushed, so we'll build an image using this specific release.
  tag=${BASH_REMATCH[1]}
fi

tag=${tag:-}

for name in stackstorm; do
  if [ -z ${BUILD_DEV:-} ]; then
    # This is not a dev build!

    # Push the tag to docker hub if and only if this is a tagged build.
    # ASSUMPTION: Builds are never "re-tagged".
    if [ ! -z ${CIRCLE_TAG:-} ]; then
      docker push stackstorm/${name}:${tag}

      if [ "${CIRCLE_TAG}" == "${latest}" ]; then
        # Update latest if and only if the tag is the most recent tag.
        # ASSUMPTION: Tags are applied in monotonically increasing order.
        docker tag stackstorm/${name}:${tag} stackstorm/${name}:latest
        docker push stackstorm/${name}:latest
      else
        echo "Not deploying image. ${CIRCLE_TAG} != ${latest}"
      fi
    fi
  else
    # Build unstable, and tag as "dev".

    # TODO: Potentially useful to prepend "dev" with revision of latest unstable
    #       release (e.g. "2.4dev")
    docker push stackstorm/${name}:dev
  fi
done
