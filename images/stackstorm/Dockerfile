FROM ubuntu:trusty

# let Upstart know it's in a container
ENV container docker

COPY config/init-fake.conf /etc/init/fake-container-events.conf

# uuid-runtime is required, otherwise the last test in 'test_quickstart_key.yaml' fails
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update \
    && apt-get install -y \
      openssh-server \
      sudo \
      curl \
      gdebi-core \
      sshpass \
      cron \
      netcat \
      net-tools \
      crudini \
      uuid-runtime \
      apache2-utils \
      bash-completion

# enable bash-completion
RUN dpkg-divert /etc/bash.bashrc && \
    sed -i '/^# enable bash completion/,/^# sudo hint/{//p;//d;s/^#//}' /etc/bash.bashrc

RUN echo -e "#!/bin/sh\nexit 101\n" > /usr/sbin/policy-rc.d \
    && rm /sbin/initctl; dpkg-divert --rename --remove /sbin/initctl \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# remove some pointless services
RUN /usr/sbin/update-rc.d -f ondemand remove; \
  for f in \
    /etc/init/u*.conf \
    /etc/init/mounted-dev.conf \
    /etc/init/mounted-proc.conf \
    /etc/init/mounted-run.conf \
    /etc/init/mounted-tmp.conf \
    /etc/init/mounted-var.conf \
    /etc/init/hostname.conf \
    /etc/init/networking.conf \
    /etc/init/tty*.conf \
    /etc/init/plymouth*.conf \
    /etc/init/hwclock*.conf \
    /etc/init/module*.conf\
  ; do \
    dpkg-divert --local --rename --add "$f"; \
  done; \
  echo '# /lib/init/fstab: cleared out for bare-bones Docker' > /lib/init/fstab

# Default value of ST2_REPO is "stable"
ARG ST2_REPO=stable

# Configure system so that the "stable" ST2 packages
# are fetched from packagecloud.io
RUN curl -s https://packagecloud.io/install/repositories/StackStorm/${ST2_REPO}/script.deb.sh | sudo bash

# The following variable is the most recent commit in
# the st2-docker repo used to fetch this Dockerfile.
ARG CIRCLE_SHA1
ARG CIRCLE_BUILD_URL
ARG CIRCLE_PROJECT_USERNAME
ARG CIRCLE_PROJECT_REPONAME

# Override these values if you want to specify different package versions
ARG ST2_TAG
ARG ST2_VERSION
ARG ST2WEB_VERSION
ARG ST2MISTRAL_VERSION

COPY bin/install.sh /install.sh

# It is not possible to dynamically set ARG's, so we do the needful in bin/install.sh
# Install st2, st2web, st2mistral and st2chatops
RUN /install.sh

# Unless these lines are changed, the services are not started when runlevel -> 2
# Call mistral-db-manage before mistral starts
RUN sed -i 's/start on filesystem and net-device-up IFACE!=lo/start on runlevel \[2345\]/' /etc/init/st2*.conf \
    && sed -i 's/stop on starting rc RUNLEVEL=\[016\]/stop on runlevel \[!2345\]/' /etc/init/st2*.conf \
    && sed -i 's/start on filesystem and net-device-up IFACE!=lo/start on runlevel \[2345\]/' /etc/init/mistral.conf \
    && sed -i 's/stop on starting rc RUNLEVEL=\[016\]/stop on runlevel \[!2345\]/' /etc/init/mistral.conf \
    && sed -i '/start mistral-api/i\  /opt/stackstorm/mistral/bin/mistral-db-manage --config-file /etc/mistral/mistral.conf upgrade head\n\
  /opt/stackstorm/mistral/bin/mistral-db-manage --config-file /etc/mistral/mistral.conf populate\n' /etc/init/mistral.conf

# Setup symmetric crypto key for datastore
RUN mkdir -p /etc/st2/keys \
    && st2-generate-symmetric-crypto-key --key-path /etc/st2/keys/datastore_key.json \
    && usermod -a -G st2 st2 && chgrp st2 /etc/st2/keys && chmod o-r /etc/st2/keys \
    && chgrp st2 /etc/st2/keys/datastore_key.json && chmod o-r /etc/st2/keys/datastore_key.json \
    && crudini --set /etc/st2/st2.conf keyvalue encryption_key_path /etc/st2/keys/datastore_key.json \
    && crudini --set /etc/st2/st2.conf auth enable True

# Install redis client library for coordination backend
# see: https://docs.stackstorm.com/latest/reference/policies.html
RUN bash -c 'source /opt/stackstorm/st2/bin/activate && pip install redis'

# Setup SSH and SUDO access for stanley user
RUN mkdir -p /home/stanley/.ssh && chmod 0700 /home/stanley/.ssh \
    && ssh-keygen -f /home/stanley/.ssh/stanley_rsa -P "" \
    && cat /home/stanley/.ssh/stanley_rsa.pub >> /home/stanley/.ssh/authorized_keys \
    && chown -R stanley:stanley /home/stanley/.ssh \
    && echo "stanley    ALL=(ALL)       NOPASSWD: SETENV: ALL" >> /etc/sudoers.d/st2 \
    && chmod 0440 /etc/sudoers.d/st2 \
    && sed -i -r "s/^Defaults\s+\+?requiretty/# Defaults +requiretty/g" /etc/sudoers

# Install and configure nginx
# Use hkp://...:80 explicitly to grab the GPG key for nginx because port 11371
# is sometimes blocked by firewalls. See:
# https://github.com/StackStorm/st2-docker/issues/135#issuecomment-392186954
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ABF5BD827BD9BF62 \
    && echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y nginx \
    && cp /usr/share/doc/st2/conf/nginx/st2.conf /etc/nginx/conf.d/st2-base.cnf \
    && ( cd /etc/nginx/conf.d && ln -s st2-base.cnf st2.conf ) \
    && mkdir -p /etc/ssl/st2 \
    && mkdir /var/run/sshd \
    && openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/st2/st2.key -out /etc/ssl/st2/st2.crt -days 3650 -nodes -subj '/O=st2 self signed/CN=localhost'

EXPOSE 22 443

COPY bin/entrypoint.sh /st2-docker/bin/entrypoint.sh
COPY bin/st2.sh /st2-docker/bin/st2.sh
COPY config/local.conf /etc/init/local.conf

# 1ppc
RUN wget -O /dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
    && chmod +x /dumb-init
COPY bin/entrypoint-1ppc.sh /st2-docker/bin/entrypoint-1ppc.sh
COPY bin/inject_env.py /st2-docker/bin/inject_env.py
COPY config/nginx.st2-1ppc.conf.tpl /etc/nginx/conf.d/st2-1ppc.conf.tpl

# Default username/password is used unless overridden by supplying ST2_USER and/or ST2_PASSWORD
# environment variables to `docker run` after the name of the image:
#   docker run -e ST2_USER... image
ENTRYPOINT ["/st2-docker/bin/entrypoint.sh"]

# Install inspec
RUN curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec

COPY ./test /st2-docker/test
COPY bin/test.sh /st2-docker/bin

RUN /st2-docker/bin/test.sh
