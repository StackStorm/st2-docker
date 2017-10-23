#!/bin/bash

cp -R /usr/share/doc/st2/examples /opt/stackstorm/packs
chgrp -R st2packs /opt/stackstorm/packs/examples
st2 run packs.setup_virtualenv packs=examples
