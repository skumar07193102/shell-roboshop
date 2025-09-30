#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
logfolder=/var/log/mongodb-practice/
mkdir -p $logfolder
scriptname=$( echo $0 | cut -d "." -f1 )
logfilename=$logfolder/$scriptname.log
user=$(id -u)
if [ $user -ne 0 ]; then
    echo -e " run the script with $R root previliges $N"
fi
VALIDATE (){
    if [ $1 -ne 0 ]; then
        echo -e " $2 is $R Failed $N "
    else
        echo -e " $2 is $G Successfull $N "
    fi
}
cp /home/ec2-user/shell-roboshop/mongo.rep /etc/yum.repos.d/
dnf install mongodb-org -y
VALIDATE $? "Installing MongoDB"
systemctl start mongod
systemctl enable mongod
netstat -lntp | grep -i mongo
sed -i '/s/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"
systemctl restart mongod
VALIDATE $? "restarting mongod service"

