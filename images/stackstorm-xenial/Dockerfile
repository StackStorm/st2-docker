FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux && \
apt-get update && \
apt-get -y install --no-install-recommends \
      apache2-utils \
      apt-transport-https \
      ca-certificates \
      crudini \
      curl \
      supervisor \
      wget

RUN set -eux && \
curl -sSL https://nginx.org/keys/nginx_signing.key | apt-key add - && \
echo "deb https://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list.d/nginx.list && \
apt-get update && \
apt-get -y install --no-install-recommends nginx

ARG NODE_REPO=node_10.x
RUN set -eux && \
curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
echo "deb https://deb.nodesource.com/${NODE_REPO}/ xenial main" > /etc/apt/sources.list.d/nodesource.list && \
apt-get update && \
apt-get -y install --no-install-recommends nodejs

ARG ST2_REPO=stable
ARG ST2_VERSION=
RUN set -eux && \
curl -sSL https://packagecloud.io/StackStorm/${ST2_REPO}/gpgkey | apt-key add - && \
echo "deb https://packagecloud.io/StackStorm/${ST2_REPO}/ubuntu/ xenial main" > /etc/apt/sources.list.d/st2.list && \
apt-get update && \
apt-get -y install --no-install-recommends \
      st2=${ST2_VERSION}* \
      st2chatops=${ST2_VERSION}* \
      st2mistral=${ST2_VERSION}* \
      st2web=${ST2_VERSION}*

COPY ${ST2_REPO}/supervisord.conf /etc/supervisor/supervisord.conf

COPY bin/ /st2-docker/bin/
COPY supervisord.d/ /st2-docker/supervisord.d

COPY st2ctl /opt/stackstorm/st2/bin/st2ctl

COPY insecure_keys/insecure_datastore_key.json /etc/st2/keys/datastore_key.json 
COPY insecure_keys/insecure_ssl_st2.crt /etc/ssl/st2/st2.crt
COPY insecure_keys/insecure_ssl_st2.key /etc/ssl/st2/st2.key
COPY insecure_keys/insecure_stanley_rsa /home/stanley/.ssh/stanley_rsa
COPY insecure_keys/insecure_stanley_rsa.pub /home/stanley/.ssh/stanley_rsa.pub

RUN set -eux && \
# Install redis client library for coordination backend
# see: https://docs.stackstorm.com/latest/reference/policies.html
bash -c 'source /opt/stackstorm/st2/bin/activate && pip install redis' && \
crudini --set /etc/st2/st2.conf auth enable True && \
crudini --set /etc/st2/st2.conf keyvalue encryption_key_path /etc/st2/keys/datastore_key.json && \
cp /usr/share/doc/st2/conf/nginx/st2.conf /etc/nginx/conf.d/st2.conf && \
# Set default locale to C.UTF-8
echo LANG=C.UTF-8 > /etc/default/locale

ENV LANG=C.UTF-8

ENTRYPOINT ["/st2-docker/bin/entrypoint.sh"]
