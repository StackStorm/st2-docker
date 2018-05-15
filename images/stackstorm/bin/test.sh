#!/bin/bash -eux

# Run Integration Tests via Inspec Infra testing framework
# https://www.inspec.io

echo -e '\033[33mRunning Inspec Integration Tests ...\033[0m'
cd /st2-docker/test/integration
for dir in */; do
  dir=$(basename $dir)
  if [ -f "${dir}/inspec.yml" ]; then
    echo -e "\nRunning tests for \033[1;36m${dir}\033[0m ..."
    sudo inspec exec --show-progress ${dir}
  fi
done
