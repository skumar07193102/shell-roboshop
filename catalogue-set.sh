#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
set -euo pipefail
trap 'echo "there is a error on line number $LINENO : command is $BASH_COMMAND "' ERR
user=$(id -u)
if [ $user -ne 0 ]; then
    echo -e " run the script with $R root previliges $N"
    exit 1
fi
Hostname=mongodb.devsecops86s.space
logfolder=/var/log/catalogue-practice/
mkdir -p $logfolder
scriptname=$( echo $0 | cut -d "." -f1 )
logfilename=$logfolder/$scriptname.log
# VALIDATE (){
#     if [ $1 -ne 0 ]; then
#         echo -e " $2 is $R Failed $N "
#         exit 1
#     else
#         echo -e " $2 is $G Successfull $N "
#     fi
# }
dnf module install nodejs:20 | tee -a $logfilename
user=$(cat /etc/passwd | grep -i roboshop) &>>$logfilename
if [ $user -e 0 ]; then
    echo "User already exists $Y SKIPPING $N"
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    echo " $G successfully created the user $N"
fi
mkdir -p /app &>>$logfilename
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$logfilename
cd /app
unzip /tmp/catalogue.zip 
npm install &>>$logfilename
cp /home/ec2-user/shell-roboshop/catalogue.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue  
cp /home/ec2-user/shell-roboshop/mongo.repo /etc/yum.repos.d/
dnf install mongodb-mongosh -y &>>$logfilename
INDEX=$(mongosh $Hostname --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $Hostname </app/db/master-data.js &>>$logfilename
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi
systemctl restart catalogue

