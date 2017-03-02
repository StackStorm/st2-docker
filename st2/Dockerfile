FROM stackstorm/packagingtest:trusty-upstart

RUN curl -s https://packagecloud.io/install/repositories/StackStorm/stable/script.deb.sh | sudo bash
RUN sudo apt-get install -y st2

# stackstorm/packagingtest already exposes port 22
EXPOSE 80 443 9100 9101 9102

RUN ln -sf /etc/init.d/st2actionrunner /etc/rc2.d/S80st2actionrunner && \
    ln -sf /etc/init.d/st2api /etc/rc2.d/S81st2api && \
    ln -sf /etc/init.d/st2auth /etc/rc2.d/S82st2auth && \
    ln -sf /etc/init.d/st2garbagecollector /etc/rc2.d/S82st2garbagecollector && \
    ln -sf /etc/init.d/st2notifier /etc/rc2.d/S84st2notifier && \
    ln -sf /etc/init.d/st2resultstracker /etc/rc2.d/S85st2resultstracker && \
    ln -sf /etc/init.d/st2rulesengine /etc/rc2.d/S86st2rulesengine && \
    ln -sf /etc/init.d/st2sensorcontainer /etc/rc2.d/S87st2sensorcontainer && \
    ln -sf /etc/init.d/st2stream /etc/rc2.d/S88st2stream

RUN sed -i 's/start on filesystem and net-device-up IFACE!=lo/start on runlevel \[2345\]/' /etc/init/st2*.conf && \
    sed -i 's/stop on starting rc RUNLEVEL=\[016\]/stop on runlevel \[!2345\]/' /etc/init/st2*.conf

# TODO: Change st2actionrunner to use DB Host `mongo` instead of `0.0.0.0`.
# TODO: Identify other changes that need to be made to use dependent services.

CMD ["/sbin/init"]
