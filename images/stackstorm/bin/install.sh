#!/bin/bash

set -euo pipefail
IDS=$'\n\t'

# Parse options
while [[ "$#" > 1 ]]; do case $1 in
  --tag) ST2_TAG="$2";;
  --st2) ST2_VERSION="$2";;
  --st2web) ST2WEB_VERSION="$2";;
  --st2mistral) ST2MISTRAL_VERSION="$2";;
  --repo) CIRCLE_PROJECT_REPONAME="$2";;
  --user) CIRCLE_PROJECT_USERNAME="$2";;
  --buildurl) CIRCLE_BUILD_URL="$2";;
  --sha) CIRCLE_SHA1="$2";;
  *) break;;
esac; shift; shift;
done

# apt-cache may not have current package data without apt-get update
apt-get update

# FIXME: De-duplicate following commands - initial effort to do so failed
if [ -z ${ST2_VERSION:-} ]; then
  if [[ -n ${ST2_TAG:-} ]]; then
    ST2_VERSION="$(apt-cache madison st2 | cut -f 2 -d '|' | tr -d '[ \t]' | grep ${ST2_TAG} | head -1)"
  else
    ST2_VERSION="$(apt-cache madison st2 | cut -f 2 -d '|' | tr -d '[ \t]' | head -1)"
  fi
fi
if [ -z ${ST2WEB_VERSION:-} ]; then
  if [[ -n ${ST2_TAG:-} ]]; then
    ST2WEB_VERSION="$(apt-cache madison st2web | cut -f 2 -d '|' | tr -d '[ \t]' | grep ${ST2_TAG} | head -1)"
  else
    ST2WEB_VERSION="$(apt-cache madison st2web | cut -f 2 -d '|' | tr -d '[ \t]' | head -1)"
  fi
fi
if [ -z ${ST2MISTRAL_VERSION:-} ]; then
  if [[ -n ${ST2_TAG:-} ]]; then
    ST2MISTRAL_VERSION="$(apt-cache madison st2mistral | cut -f 2 -d '|' | tr -d '[ \t]' | grep ${ST2_TAG} | head -1)"
  else
    ST2MISTRAL_VERSION="$(apt-cache madison st2mistral | cut -f 2 -d '|' | tr -d '[ \t]' | head -1)"
  fi
fi

# Install st2, st2web, and st2mistral
sudo apt-get update
sudo apt-get install -y st2=${ST2_VERSION} st2web=${ST2WEB_VERSION} st2mistral=${ST2MISTRAL_VERSION}

MANIFEST="/st2-manifest.txt"

echo "Image built at $(date)" > $MANIFEST

if [[ "${CIRCLE_PROJECT_REPONAME:-}" != "" ]] && [[ "${CIRCLE_PROJECT_USERNAME:-}" != "" ]] && [[ "${CIRCLE_SHA1:-}" != "" ]]; then
  echo "GitHub URL: https://github.com/${CIRCLE_PROJECT_USERNAME:-}/${CIRCLE_PROJECT_REPONAME:-}/commit/${CIRCLE_SHA1:-}" >> $MANIFEST
fi
if [[ "${CIRCLE_PROJECT_REPONAME:-}" == "" ]] && [[ "${CIRCLE_PROJECT_USERNAME:-}" == "" ]] && [[ "${CIRCLE_SHA1:-}" != "" ]]; then
  echo "Commit SHA: ${CIRCLE_SHA1:-}" >> $MANIFEST
fi
if [[ "${CIRCLE_BUILD_URL:-}" != "" ]]; then
  echo "Build URL: ${CIRCLE_BUILD_URL:-}" >> $MANIFEST
fi
if [[ "${ST2_TAG:-}" != "" ]]; then
  echo "Tag: ${ST2_TAG:-}" >> $MANIFEST
fi

echo "" >> $MANIFEST

echo "Installed versions:" >> $MANIFEST
echo "  - st2-${ST2_VERSION}" >> $MANIFEST
echo "  - st2web-${ST2WEB_VERSION}" >> $MANIFEST
echo "  - st2mistral-${ST2MISTRAL_VERSION}" >> $MANIFEST
