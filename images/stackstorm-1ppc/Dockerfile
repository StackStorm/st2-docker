# pin to st2 2.2.1
FROM stackstorm/stackstorm@sha256:5e8f9f0e4a3a1f89fd060a6b8cea7050dd6af28280ca56134676a132755d53c2

RUN wget -O /dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
    && chmod +x /dumb-init

ENV ST2_SERVICE nop

COPY nginx_st2.conf /etc/nginx/conf.d/st2.conf
COPY entrypoint-1ppc.sh /sbin/init

ENTRYPOINT ["/dumb-init", "--"]
CMD ["/entrypoint.sh"]
