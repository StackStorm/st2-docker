build:
	docker build -t stackstorm/stackstorm:latest images/stackstorm

up:
	docker-compose up -d

rmi:
	docker rmi $$(docker images -f dangling=true -q)

exec:
	docker exec -it stackstorm /bin/bash
