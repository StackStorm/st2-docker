#!/bin/bash
#
# This script runs within the CircleCI environment to deploy st2-docker images
# to Docker Hub.

set -euo pipefail
IDS=$'\n\t'

source bin/common.sh

for name in stackstorm; do
  if [ -z ${BUILD_DEV} ]; then
    # This is not a dev build!

    # Push the tag to docker hub if and only if this is a tagged build.
    # ASSUMPTION: Builds are never "re-tagged".
    if [ ! -z ${CIRCLE_TAG} ]; then
      if [ "${CIRCLE_TAG}" == "${latest}" ]; then
        # Update latest if and only if the tag is the most recent tag.
        # ASSUMPTION: Tags are applied in monotonically increasing order.
        ${dry_run} docker push stackstorm/${name}:${tag}
        if [ ! -z "${short_tag}" ]; then
          ${dry_run} docker push stackstorm/${name}:${short_tag}
        fi
      else
        echo "Not deploying image. ${CIRCLE_TAG} != ${latest}"
      fi
    fi

    # Tag with 'master' if current branch is master
    if [[ "${CIRCLE_BRANCH}" == "master" ]]; then
      ${dry_run} docker push stackstorm/${name}:master
    fi

    # 'latest' simply means "the last build/tag that ran without a specific tag/version specified".
    # https://medium.com/@mccode/the-misunderstood-docker-tag-latest-af3babfd6375
    ${dry_run} docker push stackstorm/${name}
  else
    # Build unstable, and tag as "dev".

    # TODO: Potentially useful to prepend "dev" with revision of latest unstable
    #       release (e.g. "2.4dev")
    ${dry_run} docker push stackstorm/${name}:dev
  fi
done
