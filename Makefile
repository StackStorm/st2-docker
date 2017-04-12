build:
	docker build -t stackstorm/stackstorm:latest st2-upstart

up:
	docker-compose up -d

rmi:
	docker rmi $$(docker images -f dangling=true -q)

exec:
	docker exec -it st2 /bin/bash
