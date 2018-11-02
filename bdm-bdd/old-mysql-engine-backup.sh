#!/bin/bash
## BDM mysql backup script
## Setting up variables
NOW=$(date )
NOW_Year=$(date +"%Y")
NOW_Month=$(date +"%m%b")
DATE_SIGN=$(date +"%Y-%b-%d")
Date_Epoch=$(date +"%s")
#
mysql_host=localhost
mysql_port=3307
mysql_usr=root
mysql_db=bdm2
#
home_folder=/mnt/mysql-datavol/mysql-backups
LogFile="/mnt/mysql-datavol/mysql-backups/bdm-mysql-bkup-${NOW_Month}${NOW_Year}.log"
#
bdm_mysql_s3bucket="s3://bdmmysqlbackupsauto"
bdm_mysql_source="/mnt/mysql-datavol/mysql-backups"
#
bdm_mysql_dest_folder="bdm-mysql-$NOW_Month-$NOW_Year/"
bdm_mysql_uploaded="/mnt/mysql-datavol/mysql-bkups/mysql-ok/"
#
# Print some lines to define LOG starting area.
echo "================================================================================================================" >> $LogFile
echo "================================================================================================================" >> $LogFile 
echo "START --------------------------------------------------------------------------------------" >> $LogFile
echo "////////////////////////////////////////////////////////////////////////////////////////////"  >> $LogFile
echo "$NOW - Starting Job - STAGE 1 - Dumping BDM mysql dB to file." >> $LogFile
#
echo "${home_folder}/my.cnf111"
#mysqldump --defaults-file=$home_folder/.my.cnf --routines -h $mysql_host -u$mysql_usr -P$mysql_port $mysql_db | gzip -c > $bdm_mysql_source/bdm-db-backup-$DATE_SIGN-$Date_Epoch.sql.gz
#
echo "$NOW - Starting Job - STAGE 2 - Sending BDM mysql dump to S3-bucket." >> $LogFile
#
### Clean temp retention folder if NOT empty
if [ "$(ls -A "$bdm_mysql_uploaded")" ]; then
        echo "$bdm_mysql_uploaded is not Empty. Deleting files from retention folder." >> $LogFile
        sudo /bin/rm $bdm_mysql_uploaded*
else
        echo "$bdm_mysql_uploaded is Empty. Nothing to do." >> $LogFile
fi
#
### Move backup files to S3 if the repo is NOT empty
if [ "$(ls -A "$bdm_mysql_source")" ]; then
        echo "----------------------------------------------------------------------------------------"  >> $LogFile
        echo "- -Good News!! $bdm_mysql_source is not Empty. Moving NEW backup files to S3 bucket." >> $LogFile
        for i in $bdm_mysql_source*; do
        echo "Moving $i to $bdm_mysql_s3bucket$bdm_mysql_dest_folder" >> $LogFile
        /usr/bin/s3cmd put $i $bdm_mysql_s3bucket$bdm_mysql_dest_folder
        sudo /bin/mv $i $bdm_mysql_uploaded
        done
else
        echo "- -WARNING!! $bdm_mysql_source is empty. Nothing to do. Bye." >> $LogFile
fi

# Print some lines to the end of the LOG process.
echo "$(date) - Ended backup Job - Desination AWS-bucket is $bdm_mysql_s3bucket$bdm_mysql_dest_folder." >> $LogFile
echo "====================================================================================== END" >> $LogFile
