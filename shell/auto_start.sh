#!/bin/bash
#
# Auto start tomcat

set -o errexit

DIR=$(cd "$(dirname "$0")"; pwd)

while true;do
  st=$(date +%Y-%m-%d.%H:%M:%S)

  if nc -w 10 -z 127.0.0.1 8080 > /dev/null 2>&1; then
    echo "${st} Running..."  >> "${DIR}"/status.log
  else
    echo "${st} ERROR..." >> "${DIR}"/status.log
    cd "${DIR}"
    sh "${DIR}"/bin/startup.sh >/dev/null 2>&1
  fi

  sleep 30
done
