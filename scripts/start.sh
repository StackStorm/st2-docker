#!/bin/sh

#mkdir -p /srv/arteria
cd /srv/arteria/st2-docker-umccr-master
docker-compose pull
docker-compose up -d
