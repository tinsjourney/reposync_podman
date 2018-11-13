#!/bin/bash 

source /config.env

# Configure subscription-manager proxy use
[ ! -z $PROXY_HOST ] && PROXY=" --server.proxy_hostname='${PROXY_HOST}'"
[ ! -z $PROXY_PORT ] && PROXY="${PROXY} --server.proxy_port='${PROXY_PORT}'"
[ ! -z $PROXY_USER ] && PROXY="${PROXY} --server.proxy_user='${PROXY_USER}'"
[ ! -z $PROXY_PASS ] && PROXY="${PROXY} --server.proxy_password='${PROXY_PASS}'"
[ ! -z $PROXY ] && subscription-manager config $PROXY

# Configure host to retrieve packages
[ ! -z $RHSM_PASS ] && RHSM_PASS=" --password ${RHSM_PASS}"

subscription-manager register --username ${RHSM_USER} ${RHSM_PASS} --force
subscription-manager attach --pool=${RHSM_POOL}
subscription-manager repos --disable="*"
subscription-manager repos --enable="rhel-7-server-rpms"

yum -y --setopt="tsflags=nodocs" install \
  yum-utils createrepo && \
  yum clean all && \
  rm -rf /var/cache/yum/*

SYNC_DATE="$(date +%Y%m%d)"

REPO_FOLDER="/var/www/html/${SYNC_DATE}"

mkdir -p $REPO_FOLDER
/bin/rm -f $REPO_CONF
for REPO in $REPO_LIST
do
  echo "Sync of ${REPO}"
  reposync -l -n -d --repoid=${REPO} --download_path=${REPO_FOLDER}
  mkdir -p $REPO_FOLDER/$REPO
  cd $REPO_FOLDER/$REPO
  createrepo .

done

# Unregister from RHSM
subscription-manager unsubscribe --all
subscription-manager unregister
subscription-manager clean
