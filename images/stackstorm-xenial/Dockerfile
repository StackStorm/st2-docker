FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive

# Install essential packages
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

# Install nginx
RUN set -eux && \
curl -sSL https://nginx.org/keys/nginx_signing.key | apt-key add - && \
echo "deb https://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list.d/nginx.list && \
apt-get update && \
apt-get -y install --no-install-recommends nginx

# Set nodejs version to install
# This can be overriden at build time by passing `--arg NODE_REPO=node_12.x`
ARG NODE_REPO=node_10.x

# Install nodejs
RUN set -eux && \
curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
echo "deb https://deb.nodesource.com/${NODE_REPO}/ xenial main" > /etc/apt/sources.list.d/nodesource.list && \
apt-get update && \
apt-get -y install --no-install-recommends nodejs

# Set st2 repo/version to install
# These can be overriden at build time
# If ST2_REPO=stable and ST2_VERSION left blank, then it picks the latest stable version
#  available at build time
ARG ST2_REPO=stable
ARG ST2_VERSION=

# Install stackstorm: st2, st2chatops, st2web, st2mistral
RUN set -eux && \
curl -sSL https://packagecloud.io/StackStorm/${ST2_REPO}/gpgkey | apt-key add - && \
echo "deb https://packagecloud.io/StackStorm/${ST2_REPO}/ubuntu/ xenial main" > /etc/apt/sources.list.d/st2.list && \
apt-get update && \
apt-get -y install --no-install-recommends \
      st2=${ST2_VERSION}* \
      st2chatops=${ST2_VERSION}* \
      st2mistral=${ST2_VERSION}* \
      st2web=${ST2_VERSION}*

# Copy supervisord main config
# It switches source file between stable/unstable based on ST2_REPO var
#   so that it can have different supervisord configs among `latest` and `dev` image
#   which is useful especially when introducing a new st2 component
COPY ${ST2_REPO}/supervisord.conf /etc/supervisor/supervisord.conf

# Copy supervisord config fragments
# These files are dynamically copied into /etc/supervisor/conf.d based on env vars and
#   become effective to supervisord during the startup process
COPY supervisord.d/ /st2-docker/supervisord.d

# Copy entrypoint shell scripts
# - entrypoint.sh: Main entrypoint
# - entrypoint-supervisord.sh: Starts supervisord. Called from entrypoint.sh
# - entrypoint-1ppc.sh: Handles 1ppc mode. Called from entrypoint.sh instead of
#     entrypoint-supervisord.sh if running 1ppc mode
COPY bin/entrypoint.sh /st2-docker/bin/
COPY bin/entrypoint-supervisord.sh /st2-docker/bin/
COPY bin/entrypoint-1ppc.sh /st2-docker/bin/

# Copy shell scripts that are launched by supervisord
# - run-sshd: Starts sshd. It also does some initialization before starting daemon
# - run-postinit.sh: Run shell scripts in /st2-docker/st2.d/ *AFTER* st2 become ready
COPY bin/run-sshd.sh /st2-docker/bin/
COPY bin/run-postinit.sh /st2-docker/bin/

# Copy shell scripts that are luunched by supervisord: for all st2 components
COPY bin/run-st2/ /st2-docker/bin/run-st2

# Replace st2ctl command
# This will become unnecessary when the modification is merged into upstream
COPY st2ctl /opt/stackstorm/st2/bin/st2ctl

# Copy insecure keys
COPY insecure_keys/insecure_datastore_key.json /etc/st2/keys/datastore_key.json 
COPY insecure_keys/insecure_ssl_st2.crt /etc/ssl/st2/st2.crt
COPY insecure_keys/insecure_ssl_st2.key /etc/ssl/st2/st2.key
COPY insecure_keys/insecure_stanley_rsa /home/stanley/.ssh/stanley_rsa
COPY insecure_keys/insecure_stanley_rsa.pub /home/stanley/.ssh/stanley_rsa.pub

# Do post-install setup
RUN set -eux && \
# Install redis client library for coordination backend
# see: https://docs.stackstorm.com/latest/reference/policies.html
bash -c 'source /opt/stackstorm/st2/bin/activate && pip install redis' && \
# Enable authentication
crudini --set /etc/st2/st2.conf auth enable True && \
# Enable datastore (st2kv) encryption by specifying encryption key
crudini --set /etc/st2/st2.conf keyvalue encryption_key_path /etc/st2/keys/datastore_key.json && \
# Copy nginx config for st2web
cp /usr/share/doc/st2/conf/nginx/st2.conf /etc/nginx/conf.d/st2.conf && \
# Set default locale to C.UTF-8
echo LANG=C.UTF-8 > /etc/default/locale

# Set LANG to C.UTF-8
ENV LANG=C.UTF-8

ENTRYPOINT ["/st2-docker/bin/entrypoint.sh"]
