#!/bin/bash

# check for chatops env enabled
if [[ -z "$ST2_CHATOPS_ENABLE" ]] || [[ "$ST2_CHATOPS_ENABLE" == "0" ]] ; then
  echo "chatops service is not enabled, exiting."
  exit 0
fi

# wait for the st2 api to be up before starting hubot
while true ; do
  API_UP=$(curl -s -o /dev/null -m 10 --connect-timeout 5 ${ST2_API_URL})
  if [[ $? -ne 0 ]] ; then
    echo "st2api not yet available, waiting for retry..."
    sleep 5
  else
    echo "st2api is ready, starting hubot..."
    break
  fi
done

# test hubot's config before attempting to start
echo "Testing hubot configuration..."
bin/hubot --config-check

if [[ $? -ne 0 ]] ; then
   echo "WARNING: hubot --config-check failed, are your adapter variables configured properly?"
   exit 1
fi

# start hubot
echo "Starting hubot..."
bin/hubot
