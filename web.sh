#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# inside /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log
USERID=$(id -u)
R="\e[31m"
N="\e[0m"
Y="\e[33m"
G="\e[32m"

if [ $USERID -ne 0 ]
then
   echo -e "$R ERROR:: Please run this script with root access $N"
   exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ] # $1 - is the 1st argument -- if the exit status is not equal to zero
    then
       echo -e "$2 ... $R FAILURE $N" # $2 is the package
       exit 1
    else
       echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install nginx -y &>>$LOGFILE

VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE

VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE

VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE

VALIDATE $? "Removing default index html files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE

VALIDATE $? "Downloading web artifact"

cd /usr/share/nginx/html &>>$LOGFILE

VALIDATE $? "Moving to default html directory"

unzip /tmp/web.zip &>>$LOGFILE

VALIDATE $? "Unzipping web artifact"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$LOGFILE

VALIDATE $? "Copying roboshop config"

systemctl restart nginx &>>$LOGFILE

VALIDATE $? "Restarting nginx"