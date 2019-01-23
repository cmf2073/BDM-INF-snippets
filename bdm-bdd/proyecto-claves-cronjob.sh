#!/bin/bash
## BDM mysql export for Proyeco-claves
## Setting up variables
MYSQL_Output_file="/var/lib/mysql-files/output.csv"
NOW=$(date )
NOW_Year=$(date +"%Y")
NOW_Month=$(date +"%m%b")
NOW_Day=$(date +"%d")
NOW_Hour=$(date +"%H")

S3_record_bucket="s3://proyecto-claves-output-record/"
S3_public_bucket="s3://proyecto-claves-blwdzredq6srdlf3/"
Home_folder=/mnt/mysql-datavol/mysql-backups

echo $NOW
echo $NOW_Year
echo $NOW_Month
echo $NOW_Day
echo $NOW_Hour
echo $S3_record_bucket$NOW_Year-$NOW_Month-$NOW_Day-$NOW_Hour-output.csv


## Delete output.csv file from its path
/bin/rm $MYSQL_Output_file
### /bin/ls -lh $MYSQL_Output_file

## Execute mysql query
mysql --defaults-file=$Home_folder/.my.cnf cloud_bdm < proyecto_claves_query.sql

## Upload output.csv file to Proyecto-claves-record bucket
/usr/bin/s3cmd put $MYSQL_Output_file $S3_record_bucket$NOW_Year-$NOW_Month-$NOW_Day-$NOW_Hour-output.csv

## Upload output.csv file to public buccket
s3cmd put -P $MYSQL_Output_file $S3_public_bucket
