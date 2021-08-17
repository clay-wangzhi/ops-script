#!/bin/bash
#
# MySQL backup

BACKUP_HOME=/home/clay_backup/data
DATE=$(date +%Y%m%d)
BACKUP_DIR=${BACKUP_HOME}/${DATE}
DB_USER=root
DB_PASS=123456
ARR_DB_NAME=("dj_prd" "complain_prd")
REMOTE_IP=192.168.167.20
REMOTE_USER=root
REMOTE_BAK_DIR=/home/backup/data
RETAIN_DAYS=5

local_mysql_backup() {
  echo "${DATE} mysql data backup started!"
  mkdir -p ${BACKUP_DIR}
  for db_name in "${ARR_DB_NAME[@]}"; do
    mysqldump -u${DB_USER} -p${DB_PASS} ${db_name} --single-transaction \
	  | gzip > ${BACKUP_DIR}/${db_name}.sql.gz
  done
  echo "Mysql data local backup was successful!"

}

delete_old_backup() {
  find ${BACKUP_HOME} -mtime +${RETAIN_DAYS} \
    -exec rm -rf {} \; > /dev/null 2>&1
  echo "Delete the backup file completed"
}

remote_mysql_backup() {
  # 必须提前做好免秘钥登录
  rsync -avz --progress --delete ${BACKUP_HOME}/ -e ssh ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_BAK_DIR}
  # scp -r ${BACKUP_DIR} ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_BAK_DIR}
  echo "Mysql data remote backup was successful!"
}

main() {
  echo ""
  local_mysql_backup
  delete_old_backup
  remote_mysql_backup
}

main "$@"
