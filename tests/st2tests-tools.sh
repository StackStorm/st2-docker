#!/usr/bin/env bash

mkdir -p ${BATS_HELPERS_DIR} ${BATS_DIR}
cp -R /opt/bats/* ${BATS_DIR}
cp -R /opt/bats-helpers/* ${BATS_HELPERS_DIR}
