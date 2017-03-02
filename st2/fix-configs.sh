#!/bin/bash

sed -i 's/start on filesystem and net-device-up IFACE!=lo/start on runlevel \[2345\]/' /etc/init/st2*.conf
sed -i 's/stop on starting rc RUNLEVEL=\[016\]/stop on runlevel \[!2345\]/' /etc/init/st2*.conf
