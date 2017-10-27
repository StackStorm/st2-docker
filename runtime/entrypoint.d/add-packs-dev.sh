#!/bin/bash

mkdir -p /opt/stackstorm/packs.dev
crudini --set /etc/st2/st2.conf content packs_base_paths /opt/stackstorm/packs.dev
