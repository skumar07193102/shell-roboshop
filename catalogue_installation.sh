#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
user=$(id -u)
if [ $user -ne 0 ]; then
    echo -e " run the script with $R root previliges $N"
fi
Hostname=mongodb.devsecops86s.space
logfolder=/var/log/catalogue-practice/
mkdir -p $logfolder
scriptname=$( echo $0 | cut -d "." -f1 )
logfilename=$logfolder/$scriptname.log
VALIDATE (){
    if [ $1 -ne 0 ]; then
        echo -e " $2 is $R Failed $N "
        exit 1
    else
        echo -e " $2 is $G Successfull $N "
    fi
}
dnf module install nodejs:20 -y &>>$logfilename
VALIDATE $? "installing Nodejs"
id roboshop
if [ $? -ne 0 ]; then
    echo "User already exists $Y SKIPPING $N"
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    echo " $G successfully created the user $N"
fi
mkdir -p /app &>>$logfilename
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$logfilename
VALIDATE $? " donwloading the catalogue code"
cd /app
unzip /tmp/catalogue.zip &>>$logfilename
VALIDATE $? " extracting the archieve"
nom install &>>$logfilename
VALIDATE $? "Dependencies are installed"
cp /home/ec2-user/shell-roboshop/catalogue.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue  
VALIDATE $? "starting catalogue service"
cp /home/ec2-user/shell-roboshop/mongo.repo /etc/yum.repos.d/
dnf install mongodb-mongosh -y &>>$logfilename
VALIDATE $? " Installing mongosh client"
mongosh --host $Hostname </app/db/master-data.js &>>$logfilename
VALIDATE $? "catalog products loading"
systemctl restart catalogue
VALIDATE $? "Rstarting catalogue service"
