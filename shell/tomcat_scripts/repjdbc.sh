#!/bin/bash
#
# Replace the database configuration file

IP="192.168.9.20"
PORT="1521"
PASSWD="car@2019#wash"

# Traverse the location of the JDBC file
find /home/ncar/tomcat-*/webapps/ -name jdbc*.properties > /tmp/jdbc.txt
FILES=$(cat /tmp/jdbc.txt)
PROJECTS=$(cat /tmp/jdbc.txt | awk -F/ '{print $4}')

log_print() {
  local LEVEL=$1
  local TEXT=$2
  case $LEVEL in
    OK)
      # green
      echo -e "\033[32m $TEXT \033[0m"
      ;;
    INFO)
      # blue
      echo -e "\033[34m $TEXT \033[0m"
      ;;
    WARNING)
      # yellow
      echo -e "\033[33m $TEXT \033[0m"
      ;;
    ERROR)
      # red
      echo -e "\033[31m $TEXT \033[0m"
      ;;
    *)
      echo "INVALID OPTION (LOG_PRINT): $1"
      exit 1
      ;;
  esac
}

# Backup && Replace
bak_rep() {
  for file in ${FILES}; do
    [ -f "${file}".`date +%F` ] || cp "${file}" "${file}".`date +%F`
    log_print INFO "Start updating the ${file} file ..."
    sed -i 's#^jdbc.url.*#jdbc.url=jdbc\\:oracle\\:thin\\:@'"${IP}"'\\:'"${PORT}"'\\:orcl#' "${file}"
    if [[ $? -eq 0  ]]; then
      log_print OK "The IP and the port modified successfully!"
    else
      log_print ERROR "The IP and the port modified failed!"
    fi
    sed -i "s/^jdbc.password.*/jdbc.password=${PASSWD}/" "${file}"
    if [[ $? -eq 0  ]]; then
      log_print OK "The password modified successfully!"
      echo
    else
      log_print ERROR "The password modified failed!"
      echo
    fi
  done
}

rollback() {
  for file in ${FILES}; do
    log_print INFO "Start rolling back the ${file} file ..."
    mv "${file}".`date +%F` "${file}"
    if [[ $? -eq 0  ]]; then
      log_print OK "Roll back the success!"
      echo
    else
      log_print ERROR "Roll back the failure!"
      echo
    fi
  done
}

stop() {
  for project in ${PROJECTS}; do
    log_print INFO "Stopping the ${project} project ..."
    /home/ncar/${project}/bin/catalina.sh stop &> /dev/null
    if [[ $? -eq 0  ]]; then
      log_print OK "Stop success!"
      echo
    else
      log_print ERROR "Stop failure!"
      echo
    fi
  done
  sleep 5
  log_print WARNING "$(ps -ef | grep java)"
}

main() {
  PS3="Please Select Operation : "
  select k in replace rollback stop quit; do
    case $k in
      replace)
        bak_rep
        exit 0
        ;;
      rollback)
        rollback
        exit 0
        ;;
      stop)
        stop
        exit 0
        ;;
      quit)
        exit 0
        ;;
    esac
  done
}

main "$@"
