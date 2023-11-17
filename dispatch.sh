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

yum install golang -y &>>$LOGFILE

VALIDATE $? "Installing golang"

useradd roboshop &>>$LOGFILE

mkdir /app &>>$LOGFILE

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE

VALIDATE $? "Downloading dispatch artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving to app directory"

unzip /tmp/dispatch.zip &>>$LOGFILE

VALIDATE $? "Unzipping dispatch"

go mod init dispatch &>>$LOGFILE

VALIDATE $? "Downloading mod init dispatch dependency"

go get &>>$LOGFILE

VALIDATE $? "Downloading get dependency"

go build &>>$LOGFILE

VALIDATE $? "Building the software"

cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>>$LOGFILE

VALIDATE $? "Copying dispatch.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable dispatch &>>$LOGFILE

VALIDATE $? "Enabling dispatch"

systemctl start dispatch &>>$LOGFILE

VALIDATE $? "Starting dispatch"