#!/bin/bash

set -euo pipefail
IDS=$'\n\t'

# apt-cache may not have current package data without apt-get update
apt-get update

declare -A vers=()
declare -A pkgs=( ["ST2_VERSION"]="st2" \
                  ["ST2WEB_VERSION"]="st2web" \
                  ["ST2MISTRAL_VERSION"]="st2mistral" \
                  ["ST2CHATOPS_VERSION"]="st2chatops" )

# Expand keys of pkgs array.
for i in "${!pkgs[@]}"
do
  # Save the newest available version of $pkgs[$i]
  if [ -z ${!i:-} ]; then
    vers["$i"]=$(apt-cache madison ${pkgs["$i"]} | cut -f 2 -d '|' | tr -d '[ \t]' | grep "^${ST2_TAG:-}" | head -1)
  else
    vers["$i"]=${!i}
  fi
done

# Install st2, st2web, and st2mistral
sudo apt-get install -y st2=${vers['ST2_VERSION']} st2web=${vers['ST2WEB_VERSION']} st2mistral=${vers['ST2MISTRAL_VERSION']}

# Install st2chatops, but disable unless entrypoint.d file is present
# Using GNU sort's version comparison, this performs a descending sort on
# a two element list containing "2.10" and ${vers['ST2CHATOPS_VERSION']}.
# If the "2.10.0" element is the first element, then install node.js v10.
# Else, install node.js v6.
node_script="setup_6.x"
if [ $(printf "2.10.0\n${vers['ST2CHATOPS_VERSION']}\n" | sort -V | head -n 1) = "2.10.0" ]; then
  node_script="setup_10.x"
fi

curl -sL https://deb.nodesource.com/${node_script} \
  | sudo -E bash - && sudo apt-get install -y st2chatops=${vers['ST2CHATOPS_VERSION']} && echo manual \
  | sudo tee /etc/init/st2chatops.override

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
for i in "${!pkgs[@]}"
do
  echo "  - ${pkgs[$i]}-${vers[$i]}" >> $MANIFEST
done
