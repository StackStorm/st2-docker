# StackStorm in Docker containers

[![Build Status](https://travis-ci.org/umccr/st2-docker-umccr.svg?branch=master)](https://travis-ci.org/umccr/st2-docker-umccr)

UMCCR customisations of the stackstorm setup.

For more information about the docker compose setup itself, please see the official stackstorm [st2-docker](https://github.com/StackStorm/st2-docker) repo.

Customisations for UMCCR currently include:
- custom stackstorm base image with pre-installed packs
- added mounts points to persist configurations
- dns override to avoid issues when deploying to AWS
