#!/usr/bin/env bash
# check downstream services and mark container unhealthy if downstream is not unreachable
DOWNSTREAM_API_STATUS=$(curl --write-out "%{http_code}\n" --silent --output /dev/null $ST2_API_URL/v1)
if [ "${DOWNSTREAM_API_STATUS}" != "404" ]; then  echo "st2api downstream failure"; exit 1; fi

DOWNSTREAM_STREAM_STATUS=$(curl --write-out "%{http_code}\n" --silent --output /dev/null $ST2_STREAM_URL/v1/stream)
if [ "${DOWNSTREAM_STREAM_STATUS}" != "404" ]; then  echo "st2stream downstream failure"; exit 1; fi

DOWNSTREAM_AUTH_STATUS=$(curl --write-out "%{http_code}\n" --silent --output /dev/null  $ST2_AUTH_URL/v1)
if [ "${DOWNSTREAM_AUTH_STATUS}" != "404" ]; then  echo "st2auth downstream failure"; exit 1; fi

# Check each service through the nginx reverse proxy for a specific return code. If the curl request
# fails to work through nginx, a stop signal will be sent to nginx, causing the container to restart.
API_STATUS=$(curl --write-out "%{http_code}\n" --silent --output /dev/null http://localhost/api/v1/)
if [ "${API_STATUS}" != "401" ]; then  echo "st2api nginx failure"; nginx -s stop; fi

STREAM_STATUS=$(curl --write-out "%{http_code}\n" --silent --output /dev/null http://localhost/stream/v1/stream)
if [ "${STREAM_STATUS}" != "401" ]; then  echo "st2stream nginx failure"; nginx -s stop; fi

AUTH_STATUS=$(curl --write-out "%{http_code}\n" --silent --output /dev/null  http://localhost/auth/v1/)
if [ "${AUTH_STATUS}" != "404" ]; then  echo "st2auth nginx failure"; nginx -s stop; fi

exit 0