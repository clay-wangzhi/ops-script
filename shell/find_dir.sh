#!/bin/bash
#--------------------------------------------------
# This script is for:
# 1. Find the project path based on the port number.
# @usage:  . 脚本名称
#--------------------------------------------------

set -o errexit

read -p "Please enter the project port number: " PORT

cd "$(pwdx \
     "$(netstat -nplt 2>/dev/null \
       | grep -w "${PORT}" \
       | awk '{ print $NF }' \
       |awk -F/ '{ print $1 }' \
     )" \
     | awk '{ print $NF }' \
   )"