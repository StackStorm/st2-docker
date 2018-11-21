#!/bin/bash
set -euo pipefail

IMAGE_BASE=${IMAGE_BASE:-xenial}
BUILD_TARGET=${BUILD_TARGET:-stable}

BUILD_ARGS=
IMAGE_TAG_POSTFIX=
ST2_REPO=
ST2_VERSION=
NODE_REPO=

if [ "${BUILD_TARGET}" = "stable" ]; then
  ST2_REPO="stable"
  ST2_VERSION=
  NODE_REPO="node_10.x"
  IMAGE_TAG_POSTFIX=
elif [[ ${BUILD_TARGET} =~ ^v(.+)$ ]]; then
  ST2_REPO="stable"
  ST2_VERSION=${BASH_REMATCH[1]}
  NODE_REPO="node_10.x"
  IMAGE_TAG_POSTFIX="-${ST2_VERSION}"
elif [ "${BUILD_TARGET}" = "unstable" ]; then
  ST2_REPO="unstable"
  ST2_VERSION=
  NODE_REPO="node_10.x"
  IMAGE_TAG_POSTFIX="-dev"
else
  exit 1
fi

BUILD_ARGS="--build-arg ST2_REPO=${ST2_REPO}"
BUILD_ARGS="${BUILD_ARGS} --build-arg ST2_VERSION=${ST2_VERSION}"
BUILD_ARGS="${BUILD_ARGS} --build-arg NODE_REPO=${NODE_REPO}"

IMAGE_TAG="${IMAGE_BASE}${IMAGE_TAG_POSTFIX}"

set -x
docker build -t stackstorm/stackstorm:${IMAGE_TAG} ${BUILD_ARGS} .
