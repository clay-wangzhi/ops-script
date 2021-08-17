#!/bin/bash
#
# Rollback

DIR=$(cd "$(dirname $0)" && pwd)

num=$(cat $DIR/last_bak.txt 2>/dev/null | wc -l)

log_print() {
  local LEVEL=$1
  local TEXT=$2
  case $LEVEL in
    OK)
      echo -e "\033[32m $TEXT \033[0m"
      ;;
    WARNING)
      echo -e "\033[33m $TEXT \033[0m"
      ;;
    ERROR)
      echo -e "\033[31m $TEXT \033[0m"
      ;;
    *)
      echo "INVALID OPTION (LOG_PRINT): $1"
      exit 1
      ;;
  esac
}

main() {
  [[ "${num}" -eq 0 ]] && { log_print WARNING "无备份记录"; exit 0; }
  [[ -n "$1" ]] && num=$1 || num=1

  bdir=$(tail -n $num $DIR/last_bak.txt | head -1)
 
  if [[ -d "${bdir}" ]]; then
    sh "${DIR}"/operate.sh stop
    if [[ $? -ne 0 ]]; then
      log_print ERROR "关闭服务失败"
      exit 1
    else
      log_print OK "关闭服务成功"
    fi
  else
    log_print ERROR "未查到备份目录,请确认!"
  fi
  
  sleep 2
  
  rm -rf "${DIR}"/webapps
  cp -a "${bdir}" $DIR/webapps

  sh "${DIR}"/operate.sh start
  if [[ $? -eq 0 ]]; then
    log_print OK "操作成功，请验证"
  else
    log_print ERROR "启动服务失败"
  fi
}

main "$@"
