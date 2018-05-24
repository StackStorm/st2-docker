#!/bin/bash
#
# This script runs within the CircleCI environment to deploy st2-docker images
# to Docker Hub.

set -euo pipefail
IDS=$'\n\t'

source bin/common.sh

for name in stackstorm; do
  if [ ! -z ${BUILD_DEV} ]; then
    # Build unstable, and tag as "dev".

    # TODO: Potentially useful to prepend "dev" with revision of latest unstable
    #       release (e.g. "2.4dev")
    ${dry_run} docker push stackstorm/${name}:dev
    continue
  fi

  # From this point on, not a dev build...
  name_tag="${name}:${tag}"

  if ${tagged_build}; then
    # gatekeeper.sh returns 'allow' on STDOUT if the images can be pushed
    if [ `bin/gatekeeper.sh ${name} ${tag}` != 'allow' ]; then
      echo "${name_tag} already exists on docker hub.. not pushing again!"
      exit 1
    fi
  fi

  ${dry_run} docker push stackstorm/${name}:${tag}

  if ${tagged_build}; then
    if [ "${st2_tag}" == "${latest_short}" ]; then
      ${dry_run} docker tag stackstorm/${name_tag} stackstorm/${name}:${short_tag}
      ${dry_run} docker push stackstorm/${name}:${short_tag}
    fi

    if [ "${st2_tag}" == "${latest}" ]; then
      ${dry_run} docker tag stackstorm/${name_tag} stackstorm/${name}:latest
      ${dry_run} docker push stackstorm/${name}:latest
    fi
  fi
done
