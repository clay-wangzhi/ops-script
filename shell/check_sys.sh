#!/bin/bash
#
# Check the basic condition of the system

set -o nounset

CPU_IDLE=$(sar -u 2 3|grep all|awk '{print $NF}'|sort -nr|tail -1)
DISK_USED=$(df -h | awk '{print $5,$6}')

mem_free() {
  if ! uname -r | grep 7 &> /dev/null; then
    MEM_FREE=$(free | head -3 | tail -1 | awk '{print $4/($3+$4)*100}')
  else
    MEM_FREE=$(free | head -2 | tail -1 | awk '{print ($7/$2)*100}')
  fi
}

disk_used_int() {
  df -h \
    | grep "/" \
    | awk '{print $5}' \
	  | awk -F'%' '{print $1}' \
	  | sort -nr \
	  | head -1
}

main() {
  cpu_idle_int=$(awk 'BEGIN{printf "%d", '"$CPU_IDLE"'+1}')
  mem_free
  mem_free_int=$(awk 'BEGIN{printf "%d", '"$MEM_FREE"'+1}')
  disk_max_used_int=$(disk_used_int)
  
  printf "CPU空闲率：\n%4.2f%s\n\n \
应用内存free率：\n%4.2f%s\n\n \
磁盘使用率：\n%s\n\n" \
"${CPU_IDLE}" % "${MEM_FREE}" % "${DISK_USED}"
  
  if [[ ${cpu_idle_int} -gt 80 \
    && ${mem_free_int} -gt 30 \
    && ${disk_max_used_int} -lt 70 ]];then
    echo -e "\033[32m各项指标均在阈值内，无异常 \033[0m"
  else
    echo -e "\033[31m指标异常，详见具体指标 \033[0m"
  fi
}

main "$@"
