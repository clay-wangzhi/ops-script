#!/bin/bash
#
# Backup

set -o errexit

export LANG="en_US.UTF-8"

DIR=$(cd "$(dirname "$0")"; pwd)
DATE=$(date +"%Y%m%d")
BDIR=$(date +"%H%M%S")

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
  if [[ -z  $(ls "$DIR"/webapps) ]]; then
    log_print WARNING "webapps目录下为空，跳过备份"
    exit 0
  fi

  [[ ! -d "${DIR}/bak/${DATE}/${BDIR}" ]] && mkdir -p "${DIR}/bak/${DATE}/${BDIR}"

  if cp -a "$DIR/webapps/*" "${DIR}/bak/${DATE}/${BDIR}"; then
    echo "${DIR}/bak/${DATE}/${BDIR}" >> "${DIR}/last_bak.txt"
    log_print OK "备份成功"
  else
    log_print ERROR "备份失败"
  fi
}

main "$@"
