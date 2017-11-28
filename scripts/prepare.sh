#!/bin/sh

# Debian package heavily deprecated, as usual. Install docker-ce from upstream instead
#apt-get install -y docker.io
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh && rm get-docker.sh
usermod -aG docker ubuntu

# Install docker compose
curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
gpasswd -a ubuntu docker
newgrp docker
#chown -R ubuntu:ubuntu /srv/arteria
