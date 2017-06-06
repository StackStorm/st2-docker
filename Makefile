build:
	docker build -t stackstorm/stackstorm:latest images/stackstorm

build-chatops:
        docker build -t stackstorm/stackstorm:latest images/stackstorm-chatops

env:
	bin/write-env.sh conf

up:
	docker-compose up -d

down:
	docker-compose down

rmi:
	docker rmi $$(docker images -f dangling=true -q)

exec:
	docker exec -it stackstorm /bin/bash
