#!/bin/bash
#
# This script runs within the CircleCI environment to build stackstorm images.

set -euo pipefail
IDS=$'\n\t'

source bin/common.sh

${dry_run} mkdir -p tar

for name in stackstorm; do
  if [ ! -z ${BUILD_DEV} ]; then
    ${dry_run} docker save -o tar/${name}.tar stackstorm/${name}:dev

    continue
  fi

  # From this point on, not a dev build...

  st2_tag=${tag}

  if [ -z ${CIRCLE_TAG} ]; then
    # A tag was not pushed, so we only need to build 'latest' (not tagged)
    tag='latest'
  fi

  name_tag="${name}:${tag}"

  # Build the image, tag using CIRCLE_TAG
  tags="stackstorm/${name_tag}"

  if [ "v${tag}" == "${latest}" ]; then
    tags+=" stackstorm/${name}:${short_tag:-}"
  fi

  if [ "$tag" != 'latest' ]; then
    tags+=" stackstorm/${name}:latest"
  fi

  ${dry_run} docker save -o tar/${name}.tar ${tags}
done
