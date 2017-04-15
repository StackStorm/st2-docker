build:
	docker build -t stackstorm/stackstorm:latest images/st2

up:
	docker-compose up -d

rmi:
	docker rmi $$(docker images -f dangling=true -q)
