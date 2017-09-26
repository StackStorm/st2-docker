# Description

As soon as the `stackstorm` container is started, and before StackStorm services are started
by init, shell scripts with suffix `.sh` located in this directory are executed in alphanumeric
order of the file name.

Scripts in this directory can be used to write configuration files required by StackStorm.

NOTE: The scripts must not rely on any StackStorm service being available. If you require
StackStorm to be running, then place the scripts in the `st2.d` directory instead.
