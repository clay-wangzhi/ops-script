#!/usr/bin/env bash
#
# Service operate script

# java env
export JRE_HOME=/opt/jdk1.8.0_144/jre

SERVICE_NAME=$2
SERVICE_DIR=/home/ncar/service
LOG_DIR=${SERVICE_DIR}/logs
JAR_NAME=${SERVICE_NAME}.jar
PID=${SERVICE_NAME}.pid
JAVA_OPTS="-Xms1024m -Xmx1024m -XX:-UseGCOverheadLimit -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${LOG_DIR}/siggc_error_dump.log"


function start() {
    nohup $JRE_HOME/bin/java $JAVA_OPTS -jar $JAR_NAME >>$LOG_DIR/start_info.log 2>&1 &
    echo $! > ${SERVICE_DIR}/$PID
    echo "start $SERVICE_NAME ...."
}

function stop() {
    if [[ -f "$SERVICE_DIR/$PID" ]]; then
        kill -9 "$(cat $SERVICE_DIR/$PID)" >/dev/null
        rm -f $SERVICE_DIR/$PID
    fi
    echo "stop $SERVICE_NAME ...."

    sleep 5

    P_ID=$(ps -ef | grep -w "$SERVICE_NAME" | grep "java" | awk '{print $2}')
    if [[ -z $P_ID ]]; then
        echo "$SERVICE_NAME process not exists or stop success"
    else
        echo "$SERVICE_NAME process pid is:$P_ID"
        echo "begin kill $SERVICE_NAME process, pid is:$P_ID"
        kill -9 "$P_ID"
    fi
}

function status() {
    P_ID=$(ps -ef | grep -w "$SERVICE_NAME" | grep "java" | awk '{print $2}')
    if [[  -z $P_ID ]]; then
        echo "$SERVICE_NAME process is stopped!"
    else
        echo "$SERVICE_NAME process is running ...."
    fi
}

function main() {
    cd $SERVICE_DIR/webapps || exit 1
    case "$1" in
    start)
        start
        ;;

    stop)
        stop
        ;;

    restart)
        echo "restart $SERVICE_NAME ...."
        stop
        sleep 2
        start
        ;;
    status)
        status
        ;;

    *)
        echo "[ERROR] illegal option"
        ;;
    esac
}

main "$@"