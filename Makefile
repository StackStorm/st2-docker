ST2USER?=st2admin
ST2PASSWORD?=Ch@ngeMe

all: setup

setup:
	mkdir -p ~/.ssh
	cp -i ssh/id_busybee* ~/.ssh
	chmod 600 ~/.ssh/id_busybee
	ssh -i ~/.ssh/id_busybee root@localhost /usr/bin/setup_container.sh ${ST2USER} ${ST2PASSWORD}

build:
	docker build -t st2-upstart:latest st2-upstart
