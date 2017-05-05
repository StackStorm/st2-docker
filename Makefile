build:
	docker build -t stackstorm/stackstorm:latest images/stackstorm

env:
	bin/write-env.sh conf

up:
	docker-compose up -d

rmi:
	docker rmi $$(docker images -f dangling=true -q)

exec:
	docker exec -it stackstorm /bin/bash

clean:
	docker system prune -f

clean-all: clean
	docker volume rm -f st2docker_mongo-volume st2docker_postgres-volume \
		st2docker_rabbitmq-volume st2docker_redis-volume
	rm -rf conf
