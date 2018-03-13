#!/bin/bash
#
# This script runs within the CircleCI environment to build stackstorm images.

set -euo pipefail
IDS=$'\n\t'

source bin/common.sh

for name in stackstorm; do
  if [ -z ${BUILD_DEV} ]; then
    # This is not a dev build
    st2_tag=${tag}

    if [ -z ${CIRCLE_TAG} ]; then
      # A tag was not pushed, so we only need to build 'latest' (not tagged)
      tag='latest'
    fi

    name_tag="${name}:${tag}"

    # Build the image, tag using CIRCLE_TAG
    ${dry_run} docker build --build-arg ST2_TAG=${st2_tag} --build-arg CIRCLE_SHA1=${CIRCLE_SHA1} \
      --build-arg CIRCLE_PROJECT_USERNAME=${CIRCLE_PROJECT_USERNAME:-} \
      --build-arg CIRCLE_PROJECT_REPONAME=${CIRCLE_PROJECT_REPONAME:-} \
      --build-arg CIRCLE_BUILD_URL=${CIRCLE_BUILD_URL:-} \
      -t stackstorm/${name_tag} images/${name}

    if [ "v${tag}" == "${latest}" ]; then
      ${dry_run} docker tag stackstorm/${name_tag} stackstorm/${name}:${short_tag:-}
    else
      echo "INFO: Short tag is unchanged since this is not a tagged build."
    fi

    if [ "$tag" != 'latest' ]; then
      ${dry_run} docker tag stackstorm/${name_tag} stackstorm/${name}:latest
    fi
  else
    # Triggered to run nightly via ops-infra
    # Build unstable, and tag as "dev".

    # TODO: Potentially useful to prepend "dev" with revision of latest unstable
    #       release (e.g. "2.4dev")

    ${dry_run} docker build --build-arg ST2_REPO=unstable --build-arg CIRCLE_SHA1=${CIRCLE_SHA1} \
      --build-arg CIRCLE_PROJECT_USERNAME=${CIRCLE_PROJECT_USERNAME:-} \
      --build-arg CIRCLE_PROJECT_REPONAME=${CIRCLE_PROJECT_REPONAME:-} \
      --build-arg CIRCLE_BUILD_URL=${CIRCLE_BUILD_URL:-} \
      -t stackstorm/${name}:dev images/${name}
  fi
done
