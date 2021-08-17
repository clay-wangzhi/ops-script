#!/bin/bash
#
# Locate the project path

set -o errexit

export LANG="en_US.UTF-8"

LOC_IP="192.168.1.53"
NGX_CONF="/opt/nginx/conf/nginx.conf"

read -p "请输入url地址：" url

num=`echo $url | grep -o : | wc -l`
port=`echo "$url" | awk -F: '{print $3}' | awk -F/ '{print $1}'`
project=`echo "$url" | awk -F/ '{print $4}'`

find_pid() {
  pid=$(netstat -nptl \
    | grep -w "$port" \
    | awk '{print $NF}' \
    | awk -F/ '{print $1}')
}

find_port() {
  proxy=$(grep -A 3 -w "${project}" "${NGX_CONF}" \
    | grep proxy_pass \
    | awk -F// '{print $2}' \
    | awk -F/ '{print $1}')
  if [[ -z ${proxy} ]];then
    proxy=$(grep -A 20 "${port}" "${NGX_CONF}" \
      | grep listen -A 20 \
      | grep proxy_pass \
      | awk -F// '{print $2}' \
      | awk -F';' '{print $1}')
  fi
  num=$(echo "${proxy}" | grep -o : | wc -l)
  if [[ $num -eq 1 ]];then
    rem_ip=$(echo "${proxy}" | awk -F: '{print $1}')
    port=$(echo "${proxy}" | awk -F: '{print $2}')
  else
    num=$(grep -A 4 -w "upstream ${proxy}" "${NGX_CONF}" | grep -c server)
    if [[ $num -gt 1 ]]; then
      echo -e "\033[33m多个节点,upsteam proxy为 ${proxy} ,请自行查看\033[0m"
      return 1
    elif [[ $num -lt 1 ]]; then
      echo -e "\033[32m项目地址为：${proxy}\033[0m"
      return 1
    else
      rem_ip=$(grep -A 4 -w "upstream $proxy" "${NGX_CONF}" \
        | grep server \
        | awk '{print $2}' \
        | awk -F: '{print $1}')
      port=$(grep -A 4 -w "upstream $proxy" "${NGX_CONF}" \
        | grep server \
        | awk '{print $2}' \
        | awk -F: '{print $2}')
    fi
  fi
  if [[ "${LOC_IP}" == "${rem_ip}" ]];then
    find_pid
  else
    echo -e "\033[32m项目地址为：${rem_ip}:${port}\033[0m"
    return 1
  fi
}

find_dir() {
    dir=$(pwdx "${pid}" | awk '{print $2}')
    cd "${dir}"
}

main() {
  if [[ "${num}" -eq 2 ]];then
    find_pid
    service=$(netstat -nptl \
      | grep -w "$port" \
      | awk '{print $NF}' \
      | awk -F/ '{print $2}')
    if [[ "${service}" == "nginx" ]];then
      find_port
      if [[ $? -ne 1 ]]; then
        find_pid
        find_dir
      else
        return 0
      fi
    else
      find_dir 
    fi
  else
    find_port
    if [[ $? -ne 1 ]]; then
      find_pid
      find_dir
    else
      return 0
    fi
  fi
}

main "$@"
