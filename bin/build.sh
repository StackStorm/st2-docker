#!/bin/bash
#
# This script runs within the CircleCI environment to build stackstorm images.

set -euo pipefail
IDS=$'\n\t'

source bin/common.sh

for name in stackstorm; do
  if [ ! -z ${BUILD_DEV} ]; then
    # Triggered to run nightly via ops-infra
    # Build unstable, and tag as "dev".

    ${dry_run} docker build --build-arg ST2_REPO=unstable --build-arg CIRCLE_SHA1=${CIRCLE_SHA1} \
      --build-arg CIRCLE_PROJECT_USERNAME=${CIRCLE_PROJECT_USERNAME:-} \
      --build-arg CIRCLE_PROJECT_REPONAME=${CIRCLE_PROJECT_REPONAME:-} \
      --build-arg CIRCLE_BUILD_URL=${CIRCLE_BUILD_URL:-} \
      -t stackstorm/${name}:dev images/${name}

    continue
  fi

  # From this point on, not a dev build...

  name_tag="${name}:${tag}"

  # Build the ${name_tag} image using Dockerfile in images/${name}
  ${dry_run} docker build --build-arg ST2_TAG=${st2_tag} --build-arg CIRCLE_SHA1=${CIRCLE_SHA1} \
    --build-arg CIRCLE_PROJECT_USERNAME=${CIRCLE_PROJECT_USERNAME:-} \
    --build-arg CIRCLE_PROJECT_REPONAME=${CIRCLE_PROJECT_REPONAME:-} \
    --build-arg CIRCLE_BUILD_URL=${CIRCLE_BUILD_URL:-} \
    -t stackstorm/${name_tag} images/${name}
done
