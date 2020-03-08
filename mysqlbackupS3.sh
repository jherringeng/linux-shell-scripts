wordpress user = user
db user = root
password = OcMly95tvlDJ

#vim mysqlbackupS3.sh
#!/bin/bash
#I use this to create a little bash script that will backup the database at regular intervals, and I’ll even chuck in deleting backups older than 15 days and move the dump_file in S3_bucket.
#create a few variables to contain the Database_credentials.
# Database credentials
USER="root"
PASSWORD="OcMly95tvlDJ"

BACKUPROOT="/home/bitnami/backup/mysql_dump"
WORDPRESSROOT="/opt/bitnami/apps/wordpress/htdocs"
TIMESTAMP="backup/mysql_dump/logs/time_stamp"
TSTAMP=$(date +"%d-%b-%Y-%H-%M-%S")
S3BUCKET="s3://wordpress-backup-jherring"

#logging
LOG_ROOT="/home/bitnami/backup/mysql_dump/logs/dump.log"

#Dump of Mysql Database into S3\
echo "$(tput setaf 2)creating backup of database start at $TSTAMP" >> "$LOG_ROOT"
mysqldump -A -u=$USER -p=$PASSWORD > $BACKUPROOT/backup-$TSTAMP.sql

echo "$(tput setaf 3)Finished backup of database and sending it in S3 Bucket at $TSTAMP" >> "$LOG_ROOT"

echo "$TSTAMP" > TIMESTAMP

#Delete files older than 15 days
find  $BACKUPROOT/*   -mtime +15   -exec rm  {}  \;
s3cmd   put   --recursive   $BACKUPROOT   $S3BUCKET
s3cmd   put   --recursive $WORDPRESSROOT/wp-content $S3BUCKET
s3cmd   put   --recursive $WORDPRESSROOT/wp-includes $S3BUCKET
s3cmd   put   --recursive $WORDPRESSROOT/wp-config.php $S3BUCKET
s3cmd   put   --recursive $WORDPRESSROOT/.htaccess $S3BUCKET

echo "$(tput setaf 2)Moved the backup files from local to S3 bucket at $TSTAMP" >> "$LOG_ROOT"
echo "$(tput setaf 3)Coll!! Script have been executed successfully at $TSTAMP" >> "$LOG_ROOT"