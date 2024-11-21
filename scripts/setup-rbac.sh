#!/bin/bash

echo "Loading RBAC definitions"
st2-apply-rbac-definitions --config-file /etc/st2/st2.docker.conf