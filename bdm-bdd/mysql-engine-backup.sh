#!/bin/bash
## BDM mysql backup script
## Setting up variables
NOW=$(date )
NOW_Year=$(date +"%Y")
NOW_Month=$(date +"%m%b")
DATE_SIGN=$(date +"%Y-%b-%d")
Date_Epoch=$(date +"%s")

mysql_host=127.0.0.1
mysql_port=3307
mysql_usr=root
mysql_db=redmine_prd

home_folder=/usr/local/scripts/
LogFile=/usr/local/scripts/Redmine-mysql-bkup.log
redmine_s3bucket="s3://s3sysadmin2/lsm-INF-001/redmine-bkups/"
redmine_source="/usr/local/redmine-bkups/mysql/"
#gitlab_source="/home/ubuntu/test_folder/"
### gitlab_dest_folder="gitlab-2014"
#gitlab_dest_folder="gitlab-2016"
redmine_dest_folder="redmine-mysql-$NOW_Month-$NOW_Year/"
redmine_uploaded="/usr/local/redmine-bkups/mysql-ok/"

# Print some lines to define LOG starting area.
echo "================================================================================================================" >> $LogFile
echo "================================================================================================================" >> $LogFile 
echo "START --------------------------------------------------------------------------------------" >> $LogFile
echo "////////////////////////////////////////////////////////////////////////////////////////////"  >> $LogFile
echo "$NOW - Starting Job - STAGE 1 - Dumping Redmine mysql dB to file." >> $LogFile

mysqldump --defaults-file=$home_folder/.my.cnf -h $mysql_host -u$mysql_usr -P$mysql_port $mysql_db | gzip -c > $redmine_source/redmine-db-backup-$DATE_SIGN-$Date_Epoch.sql.gz

echo "$NOW - Starting Job - STAGE 2 - Sending Redmine Mysql dump to S3-bucket." >> $LogFile

### Clean temp retention folder if NOT empty
if [ "$(ls -A "$redmine_uploaded")" ]; then
        echo "$redmine_uploaded is not Empty. Deleting files from retention folder." >> $LogFile
        sudo /bin/rm $redmine_uploaded*
else
        echo "$redmine_uploaded is Empty. Nothing to do." >> $LogFile
fi

### Move backup files to S3 if the repo is NOT empty
if [ "$(ls -A "$redmine_source")" ]; then
        echo "----------------------------------------------------------------------------------------"  >> $LogFile
        echo "- -Good News!! $redmine_source is not Empty. Moving NEW backup files to S3 bucket." >> $LogFile
        for i in $redmine_source*; do
        echo "Moving $i to $redmine_s3bucket$redmine_dest_folder" >> $LogFile
        /usr/bin/s3cmd put $i $redmine_s3bucket$redmine_dest_folder
        sudo /bin/mv $i $redmine_uploaded
        done
else
        echo "- -WARNING!! $gitlab_source is empty. Nothing to do. Bye." >> $LogFile
fi

                #for i in $gitlab_source*; do
                #/usr/bin/s3cmd put $i s3://s3bucket002-gitlab/$gitlab_dest_folder/
                #sudo /bin/mv $i $gitlab_uploaded
                #done

# Print some lines to the end of the LOG process.
echo "$(date) - Ended backup Job - Desination AWS-bucket is $redmine_s3bucket$redmine_dest_folder." >> $LogFile
echo "====================================================================================== END" >> $LogFile
