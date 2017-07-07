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
    && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

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

# Override these values if you want to specify different package versions
ARG ST2_VERSION="2.2.1-5"
ARG ST2WEB_VERSION="2.2.1-1"
ARG ST2MISTRAL_VERSION="2.2.1-4"

# Configure system so that the "stable" ST2 packages are fetched from packagecloud.io
RUN curl -s https://packagecloud.io/install/repositories/StackStorm/${ST2_REPO}/script.deb.sh | sudo bash

# Install st2, st2web, and st2mistral
RUN sudo apt-get install -y st2=${ST2_VERSION} st2web=${ST2WEB_VERSION} st2mistral=${ST2MISTRAL_VERSION}

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
    && crudini --set /etc/st2/st2.conf auth enable True \
    && crudini --set /etc/st2/st2.conf content packs_base_paths /opt/stackstorm/packs.dev

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
RUN wget -O - http://nginx.org/keys/nginx_signing.key | apt-key add - \
    && echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 \
    && apt-get update \
    && apt-get install -y nginx \
    && cp /usr/share/doc/st2/conf/nginx/st2.conf /etc/nginx/conf.d \
    && mkdir -p /etc/ssl/st2 \
    && mkdir /var/run/sshd \
    && openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/st2/st2.key -out /etc/ssl/st2/st2.crt -days 3650 -nodes -subj '/O=st2 self signed/CN=localhost'

EXPOSE 22 443

# Share /opt/stackstorm/packs.dev with the host
# NOTE: This is intended to be used for pack development.
VOLUME ["/opt/stackstorm/packs.dev"]

COPY bin/entrypoint.sh /entrypoint.sh
COPY config/local.conf /etc/init/local.conf

# Default username/password is used unless overridden by supplying ST2_USER and/or ST2_PASSWORD
# environment variables to `docker run` after the name of the image:
#   docker run -e ST2_USER... image
ENTRYPOINT ["/entrypoint.sh"]
