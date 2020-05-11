#!/usr/bin/env bash
# Check each service through the nginx reverse proxy for a specific return code. If the curl request
# fails to work through nginx, a stop signal will be sent to nginx, causing the container to restart.
API_STATUS=$(curl --write-out "%{http_code}\n" --silent --output /dev/null http://localhost/api/v1/)
if [ "${API_STATUS}" != "401" ]; then  echo "st2api failure"; nginx -s stop; fi

STREAM_STATUS=$(curl --write-out "%{http_code}\n" --silent --output /dev/null http://localhost/stream/v1/stream)
if [ "${STREAM_STATUS}" != "401" ]; then  echo "st2stream failure"; nginx -s stop; fi

AUTH_STATUS=$(curl --write-out "%{http_code}\n" --silent --output /dev/null  http://localhost/auth/v1/)
if [ "${AUTH_STATUS}" != "404" ]; then  echo "st2auth failure"; nginx -s stop; fi

exit 0