#!/bin/bash

# Parse options
while [[ "$#" > 1 ]]; do case $1 in
  --sha) ST2_DOCKER_SHA1="$2";;
  --st2) ST2_VERSION="$2";;
  --st2web) ST2WEB_VERSION="$2";;
  --st2mistral) ST2MISTRAL_VERSION="$2";;
  --tag) ST2_TAG="$2";;
  *) break;;
esac; shift; shift;
done

if [ -z ${ST2_VERSION} ]; then
  ST2_VERSION=`apt-cache madison st2 | cut -f 2 -d '|' | tr -d '[ \t]' | grep ${ST2_TAG} | head -1`
fi
if [ -z ${ST2WEB_VERSION} ]; then
  ST2WEB_VERSION=`apt-cache madison st2web | cut -f 2 -d '|' | tr -d '[ \t]' | grep ${ST2_TAG} | head -1`
fi
if [ -z ${ST2MISTRAL_VERSION} ]; then
  ST2MISTRAL_VERSION=`apt-cache madison st2mistral | cut -f 2 -d '|' | tr -d '[ \t]' | grep ${ST2_TAG} | head -1`
fi

MANIFEST="/st2-manifest.txt"

echo "Image built at $(date) using st2-docker:${ST2_DOCKER_SHA1}" > $MANIFEST
echo "" >> $MANIFEST
echo "Installed versions:" >> $MANIFEST
echo "  - st2-${ST2_VERSION}" >> $MANIFEST
echo "  - st2web-${ST2WEB_VERSION}" >> $MANIFEST
echo "  - st2mistral-${ST2MISTRAL_VERSION}" >> $MANIFEST

# Install st2, st2web, and st2mistral
sudo apt-get install -y st2=${ST2_VERSION} st2web=${ST2WEB_VERSION} st2mistral=${ST2MISTRAL_VERSION}
