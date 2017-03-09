ST2USER?=st2admin
ST2PASSWORD?=Ch@ngeMe

all: setup web

setup:
	mkdir -p ~/.ssh
	cp -i ssh/id_busybee* ~/.ssh
	chmod 600 ~/.ssh/id_busybee

web:
	ssh -i ~/.ssh/id_busybee root@localhost htpasswd -bs /etc/st2/htpasswd ${ST2USER} ${ST2PASSWORD}
