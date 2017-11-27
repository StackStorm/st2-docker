#!/bin/sh

apt-get install -y docker.io
# Debian package heavily deprecated, as usual.
curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
gpasswd -a ubuntu docker
newgrp docker
#chown -R ubuntu:ubuntu /srv/arteria
