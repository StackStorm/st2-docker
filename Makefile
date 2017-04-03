build:
	docker build -t st2-upstart:latest st2-upstart

up:
	docker-compose up -d

rmi:
	docker rmi $$(docker images -f dangling=true -q)
