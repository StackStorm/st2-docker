#!/bin/bash

# (minimal) check for chatops env
if [[ -z "$HUBOT_ADAPTER" ]] ; then
  echo "WARNING: \$HUBOT_ADAPTER is not set, cannot start hubot..."
  # just sleep indefinitely to avoid this container getting repeatedly restarted
  sleep infinity
fi

# st2chatops - wait for the st2 api to be up before starting hubot
while true ; do
  API_UP=$(curl -s -o /dev/null -m 10 --connect-timeout 5 ${ST2_API_URL})
  if [[ "$?" -ne 0 ]] ; then
    echo "st2api not yet available, waiting for retry..."
    sleep 5
  else
    echo "st2api is ready, starting hubot..."
    bin/hubot
  fi
done
