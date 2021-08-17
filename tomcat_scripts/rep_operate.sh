#!/bin/bash
export LANG="en_US.UTF-8"

#set java environment
export JAVA_HOME=/usr/local/jdk1.7.0_80
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
export JAVA_HOME CLASSPATH PATH


#遍历jdbc文件所在位置
find /home/ncar/tomcat*/webapps/ -name jdbc*.properties > /tmp/jdbc.txt

#备份&&替换
Replace(){
    for i in `cat /tmp/jdbc.txt`
    do
        [ -f ${i}.`date +%F` ] || cp $i ${i}.`date +%F`
        sed -i "s/^jdbc.url.*/jdbc.url=jdbc\\:oracle\\:thin\\:@$newIP\\:$port\\:orcl/" $i
        sed -i "s/^jdbc.password.*/jdbc.password=$passwd/" $i
    done
}

#回滚
Rollback(){
    for i in `cat /tmp/jdbc.txt`
    do
        mv ${i}.`date +%F` $i
    done
}

#启动
Start(){
    nohup sh $dir/bin/startup.sh >/dev/null &
    return 0
}

#停止
Stop(){
    ps -ef | grep $dir/conf | grep -v 'grep' | awk '{print $2}' | xargs kill -9  
    return 0
}

##需放到tomcat目录下
dir=$(cd $(dirname $0) && pwd)
newIP='192.168.9.20'
passwd='car@2019#wash'
port='1521'

[ "$1" ] || { echo "Usage: [ replace | rollback | start | stop| restart ]" ; exit 1 ; }

case $1 in
    "replace" )
        Replace
        ;;
    "rollback" )
        Rollback
        ;;
    "start" )
        Start
        ;;
    "stop" )
        Stop
        ;;
    "restart" )
        Stop
        sleep 3
        Start
        ;;
    * )
        exit 0
        ;;
esac
