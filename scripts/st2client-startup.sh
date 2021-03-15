#!/bin/bash

counter=0

# st2client startup and registration
while [ "$counter" -lt 5 ]; do
  ACTIONS=$(st2 action list)
  if [ "$?" -ne 0 ]; then
    echo "unable to reach downstream, will try again"
    counter=$((counter+1))
    sleep $((counter*5))
  elif [ "$ACTIONS" == "No matching items found" ]; then
    echo "No packs registered, will register"
    st2 pack register
  else
    echo "actions found st2client ready"
    sleep infinity
  fi
done

echo "No packs were able to be registered due to st2 failures. You may need to load them manually"
sleep infinity