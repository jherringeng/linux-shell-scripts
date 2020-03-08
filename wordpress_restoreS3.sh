#vim mysqlbackupS3.sh
#!/bin/bash
# Database credentials
USER="root"
PASSWORD="OcMly95tvlDJ"

BACKUPROOT="/home/bitnami/backup/mysql_dump"
WORDPRESSROOT="/opt/bitnami/apps/wordpress/htdocs"
TIMESTAMP="/home/bitnami/backup/mysql_dump/logs/time_stamp"

. $TIMESTAMP
TSTAMP="$TSTAMP"
S3BUCKET="s3://wordpress-backup-jherring"
#logging
LOG_ROOT="/home/bitnami/backup/mysql_dump/logs/dump.log"

#Restoration of Mysql Database from S3\
echo "$(tput setaf 2)restoring backup of database stored at $TSTAMP" >> "$LOG_ROOT"
s3cmd   get   --force  --recursive $S3BUCKET/mysql_dump/backup-$TSTAMP.sql  		$BACKUPROOT/backup-$TSTAMP.sql
mysql -u=$USER -p=$PASSWORD < $BACKUPROOT/backup-$TSTAMP.sql

echo "$(tput setaf 3)Finished restoration of database from S3 Bucket at $TSTAMP" >> "$LOG_ROOT"
   
   #Restoration of Wordpress directories and files
s3cmd   get   --force  --recursive $S3BUCKET/wp-content  	$WORDPRESSROOT/wp-content 
s3cmd   get   --force  --recursive $S3BUCKET/wp-includes  	$WORDPRESSROOT/wp-includes 
s3cmd   get   --force  --recursive $S3BUCKET/wp-config.php  $WORDPRESSROOT/wp-config.php 
s3cmd   get   --force  --recursive $S3BUCKET/.htaccess  	$WORDPRESSROOT/.htaccess 

echo "$(tput setaf 2)Moved the backup files from S3 bucket at $TSTAMP to local"  >> "$LOG_ROOT"
echo "$(tput setaf 3)Coll!! Script have been executed successfully. Backup restored." >> "$LOG_ROOT"