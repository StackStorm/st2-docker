#!/bin/bash

# Parse options
while [[ "$#" > 1 ]]; do case $1 in
  --tag) ST2_TAG="$2";;
  --st2) ST2_VERSION="$2";;
  --st2web) ST2WEB_VERSION="$2";;
  --st2mistral) ST2MISTRAL_VERSION="$2";;
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

echo "Installed versions: st2-${ST2_VERSION} st2web-${ST2WEB_VERSION} st2mistral-${ST2MISTRAL_VERSION}" > /st2-manifest.txt
echo "Image built at $(date) using st2-docker:${ST2_DOCKER_SHA1}" >> /st2-manifest.txt

# Install st2, st2web, and st2mistral
sudo apt-get install -y st2=${ST2_VERSION} st2web=${ST2WEB_VERSION} st2mistral=${ST2MISTRAL_VERSION}
