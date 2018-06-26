SHA := $(shell git describe --match=NeVeRmAtCh --always --abbrev=40 --dirty=*)

build:
	docker build --build-arg CIRCLE_SHA1="$(SHA)" -t stackstorm/stackstorm:latest images/stackstorm

build-dev:
	docker build --build-arg ST2_REPO=unstable --build-arg CIRCLE_SHA1="$(SHA)" -t stackstorm/stackstorm:local-dev images/stackstorm

env:
	bin/write-env.sh conf

gen-ssh:
	bin/gen-ssh.sh

gen-ssl:
	bin/gen-ssl.sh

up:
	docker-compose up -d

down:
	docker-compose down

rmi:
	docker rmi $$(docker images -f dangling=true -q)

exec:
	docker-compose exec stackstorm /bin/bash
