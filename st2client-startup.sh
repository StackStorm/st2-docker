#!/bin/bash

#st2client startup and registration
while true
do
ACTIONS=$(st2 action list)
if [ "$?" -ne 0 ]
then
    echo "unable to reach downstream, will try again"
    sleep 5
elif [ "$ACTIONS" == "No matching items found" ]
then
    echo "No packs registered, will register"
    st2 pack register
else
    echo "actions found st2client ready"
    sleep infinity
fi
done