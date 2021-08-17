#!/usr/bin/env bash
#
# Replace the yum repo

set -e

REPOS="http://mirrors.aliyun.com/repo"
OS_VERSION=$(rpm -q centos-release | cut -d- -f3)

if ! rpm -q wget; then
  yum -y install wget
fi

cd /etc/yum.repos.d/

# Backup default repo
mkdir -p bak
mv ./*.repo bak

# Install aliyun repo
wget -O Centos-"${OS_VERSION}".repo "${REPOS}"/Centos-"${OS_VERSION}".repo
wget -O epel-"${OS_VERSION}".repo "${REPOS}"/epel-"${OS_VERSION}".repo

# Create a new cache
yum clean all
yum makecache