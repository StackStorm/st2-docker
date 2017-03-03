FROM stackstorm/packagingtest:trusty-upstart

RUN apt-get update && apt-get upgrade -y

# Configure system so that the "stable" ST2 packages are fetched from packagecloud.io
RUN curl -s https://packagecloud.io/install/repositories/StackStorm/stable/script.deb.sh | sudo bash

# Install st2, st2web, crudini and uuid-runtime
#  - crudini is used to update the st2.conf file
#  - uuid-runtime is required, otherwise the last test in 'test_quickstart_key.yaml' fails
RUN sudo apt-get install -y st2 st2web crudini uuid-runtime

# stackstorm/packagingtest:trusty-upstart already exposes port 22
EXPOSE 80 443 9100 9101 9102

# Configure init scripts to start services in runlevel 2
RUN ln -sf /etc/init.d/st2actionrunner /etc/rc2.d/S80st2actionrunner && \
    ln -sf /etc/init.d/st2api /etc/rc2.d/S81st2api && \
    ln -sf /etc/init.d/st2auth /etc/rc2.d/S82st2auth && \
    ln -sf /etc/init.d/st2garbagecollector /etc/rc2.d/S82st2garbagecollector && \
    ln -sf /etc/init.d/st2notifier /etc/rc2.d/S84st2notifier && \
    ln -sf /etc/init.d/st2resultstracker /etc/rc2.d/S85st2resultstracker && \
    ln -sf /etc/init.d/st2rulesengine /etc/rc2.d/S86st2rulesengine && \
    ln -sf /etc/init.d/st2sensorcontainer /etc/rc2.d/S87st2sensorcontainer && \
    ln -sf /etc/init.d/st2stream /etc/rc2.d/S88st2stream

# Unless these lines are changed, the services are not started when runlevel -> 2
RUN sed -i 's/start on filesystem and net-device-up IFACE!=lo/start on runlevel \[2345\]/' /etc/init/st2*.conf && \
    sed -i 's/stop on starting rc RUNLEVEL=\[016\]/stop on runlevel \[!2345\]/' /etc/init/st2*.conf

# Setup symmetric crypto key for datastore
RUN mkdir -p /etc/st2/keys && \
    st2-generate-symmetric-crypto-key --key-path /etc/st2/keys/datastore_key.json && \
    usermod -a -G st2 st2 && chgrp st2 /etc/st2/keys && chmod o-r /etc/st2/keys && \
    chgrp st2 /etc/st2/keys/datastore_key.json && chmod o-r /etc/st2/keys/datastore_key.json && \
    crudini --set /etc/st2/st2.conf keyvalue encryption_key_path /etc/st2/keys/datastore_key.json

# Set the MongoDB hostname, as well as the RabbitMQ username, password and hostname
RUN crudini --set /etc/st2/st2.conf database host mongo && \
    crudini --set /etc/st2/st2.conf messaging url amqp://admin:pwd123@rabbitmq:5672

# Setup SSH and SUDO access for stanley user
RUN mkdir -p /home/stanley/.ssh && chmod 0700 /home/stanley/.ssh && \
    ssh-keygen -f /home/stanley/.ssh/stanley_rsa -P "" && \
    cat /home/stanley/.ssh/stanley_rsa.pub >> /home/stanley/.ssh/authorized_keys && \
    chown -R stanley:stanley /home/stanley/.ssh && \
    echo "stanley    ALL=(ALL)       NOPASSWD: SETENV: ALL" >> /etc/sudoers.d/st2 && \
    chmod 0440 /etc/sudoers.d/st2 && \
    sed -i -r "s/^Defaults\s+\+?requiretty/# Defaults +requiretty/g" /etc/sudoers

CMD ["/sbin/init"]
