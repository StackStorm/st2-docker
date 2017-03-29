build:
	docker build -t st2:latest st2

up:
	docker-compose up -d

rmi:
	docker rmi $$(docker images -f dangling=true -q)
