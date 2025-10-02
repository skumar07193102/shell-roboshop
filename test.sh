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
fi
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
user=$(id roboshop)
if [ $user -eq 0 ]; then 
    echo "User already exists $Y SKIPPING $N"
 else
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
     echo " $G successfully created the user $N"
fi