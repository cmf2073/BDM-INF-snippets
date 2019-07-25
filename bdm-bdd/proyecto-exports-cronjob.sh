#!/bin/bash
## BDM mysql export for Proyeco-claves
## Setting up variables
MYSQL_Output_file="/var/lib/mysql-files/OutFile2.csv"
NOW=$(date )
NOW_Year=$(date +"%Y")
NOW_Month=$(date +"%m%b")
NOW_Day=$(date +"%d")
NOW_Hour=$(date +"%H")

mysql_host=localhost
mysql_port=3307
mysql_usr=root
mysql_db=cloud_bdm

export clientID=$1
file_hash=$2

S3_record_bucket="s3://bdm-exports-private/"
S3_public_bucket="s3://bdm-exports-public/"
Home_folder=/mnt/mysql-datavol/mysql-backups

# Test variables
### echo $NOW
### echo $NOW_Year
### echo $NOW_Month
### echo $NOW_Day
### echo $NOW_Hour
### echo $S3_record_bucket$NOW_Year-$NOW_Month-$NOW_Day-$NOW_Hour-output.csv
### /bin/pwd
echo $clientID

echo "- - - - - Startting JOB - - - -" $NOW

## Delete output.csv file from its path
/bin/rm $MYSQL_Output_file
### /bin/ls -lh $MYSQL_Output_file

## Execute mysql query
#### mysql --defaults-file=$Home_folder/.my.cnf  $mysql_db < /home/ubuntu/.scripts/BDM-INF-snippets/bdm-bdd/proyecto_claves_query-xxx.sql
mysql --defaults-file=$Home_folder/.my.cnf  $mysql_db -e "set @clientID='${clientID}';source /home/ubuntu/.scripts/BDM-INF-snippets/bdm-bdd/proyecto-exports-query.sql;"

## Upload output.csv file to bdm-exports-private bucket
/usr/bin/s3cmd put $MYSQL_Output_file $S3_record_bucket$NOW_Year-$NOW_Month-$NOW_Day-$NOW_Hour-$clientID-output.csv

## Upload output.csv file to public buccket
/usr/bin/s3cmd put -P $MYSQL_Output_file $S3_public_bucket$clientID-$file_hash-output.csv

echo "- - - - - END OF JOB - - - - " $(date )
echo " - "
echo "  - "
echo "   - "
echo "    - "
