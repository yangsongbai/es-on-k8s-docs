#!/usr/bin/env bash

# fail should be called as a last resort to help the user to understand why the probe failed
function fail {
  timestamp=$(date --iso-8601=seconds)
  echo "{\"timestamp\": \"${timestamp}\", \"message\": \"liveness probe failed\", "$1"}" | tee /proc/1/fd/2 2> /dev/null
  exit 1
}

READINESS_PROBE_TIMEOUT=${READINESS_PROBE_TIMEOUT:=3}

# $PROBE_USERNAME
PROBE_USERNAME=$ELASTIC_USER
#
PROBE_PASSWORD=$ELASTIC_PASSWORD

# setup basic auth if credentials are available
if [ -n "${PROBE_USERNAME}" ] && [ -n "${PROBE_PASSWORD}" ]; then
  BASIC_AUTH="-u ${PROBE_USERNAME}:${PROBE_PASSWORD}"
else
  BASIC_AUTH=''
fi

# Check if we are using IPv6
if [[ $POD_IP =~ .*:.* ]]; then
  LOOPBACK="[::1]"
else
  LOOPBACK=127.0.0.1
fi

# request Elasticsearch on /
# we are turning globbing off to allow for unescaped [] in case of IPv6
ENDPOINT="http://${LOOPBACK}:9200/"
# 双百分号是为了转义百分号
status=$(curl -o /dev/null -w "%{http_code}" --max-time ${READINESS_PROBE_TIMEOUT} -XGET -g -s ${BASIC_AUTH} $ENDPOINT)
curl_rc=$?

if [[ ${curl_rc} -ne 0 ]]; then
  fail "\"curl_rc\": \"${curl_rc}\""
fi

# ready if status code 200, 503 is tolerable if ES version is 6.x
if [[ ${status} == "200" ]]; then
  exit 0
else
  fail " \"status\": \"${status}\" "
fi