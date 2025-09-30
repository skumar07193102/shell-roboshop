#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
user=$(id -u)
if [ $user -ne 0 ]; then
    echo -e " run the script with $R root previliges $N"
    exit 1
fi
logfolder=/var/log/nginx-practice/
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
dnf module install nginx:1.24 -y &>>$logfilename
VALIDATE $? "installing nginx"
systemctl enable nginx
systemctl start nginx
rm -rf /usr/share/nginx/html/* &>>$logfilename
VALIDATE $? "removed the default content of HTML"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$logfilename
VALIDATE $? "downloading fronend code"
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$logfilename
VALIDATE $? " extracting files"
rm -rf /etc/nginx/nginx.conf
cp /home/ec2-user/shell-roboshop/nginx.conf /etc/nginx/
systemctl restart nginx
VALIDATE $? "Nginx process has restarted" &>>$logfilename
