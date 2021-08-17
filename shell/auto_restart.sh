#!/usr/bin/env bash
#
# Service auto restart

SERVICE_NAME=ShengDaOrderQueryAndCallBack
url="https://h5.schengle.com/ShengDaOrderQueryAndCallBack/query/checkStatus"
http_response=$(curl -s -w "%{http_code}" ${url} -o /dev/null)
restart_script="/home/ncar/service/operate.sh"

[[ ${http_response} -ne 200 ]] && bash ${restart_script} restart ${SERVICE_NAME}
