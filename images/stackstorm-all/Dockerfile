FROM ubuntu:14.04

COPY mongod.init /etc/init.d/mongod

#####################################################################################################
## Change Password                  
#####################################################################################################

ENV ST2_PASSWORD=changeme

#####################################################################################################
## Prepare the environement and install StackStorm (install script)                  
#####################################################################################################

RUN export DEBIAN_FRONTEND=noninteractive \
	&& export NO_PROXY=localhost,127.0.0.1,${HOSTNAME} \
	&& apt-get update \
	&& apt-get dist-upgrade --yes \
	&& apt-get install --yes curl vim gnupg-curl openssh-server tree \
	&& /etc/init.d/rsyslog start \
	&& /etc/init.d/ssh start \
	&& curl -sSL -O https://stackstorm.com/packages/install.sh ; chmod +x install.sh ; ./install.sh --user=st2admin --password=${ST2_PASSWORD} \
	&& echo "stanley:stanley" | chpasswd

#####################################################################################################
## Cleaning                  
#####################################################################################################

RUN rm -f /install.sh /st2-community-installer.sh /st2bootstrap-deb.sh \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ADD start_st2_services.sh /

ENTRYPOINT /start_st2_services.sh

WORKDIR /opt/stackstorm/packs
