SHA := $(shell git describe --match=NeVeRmAtCh --always --abbrev=40 --dirty=*)

build:
	docker build --build-arg CIRCLE_SHA1="$(SHA)" -t stackstorm/stackstorm:latest images/stackstorm

env:
	bin/write-env.sh conf

up:
	docker-compose up -d

down:
	docker-compose down

rmi:
	docker rmi $$(docker images -f dangling=true -q)

exec:
	docker-compose exec stackstorm /bin/bash
