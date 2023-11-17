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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copied MongoDB repo into yum.repos.d"

yum install mongodb-org -y &>>$LOGFILE

VALIDATE $? "Installation of MongoDB"

systemctl enable mongod &>>$LOGFILE

VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>>$LOGFILE

VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$LOGFILE

VALIDATE $? "Edited MongoDB conf"

systemctl restart mongod &>>$LOGFILE

VALIDATE $? "Restarting MongoDB"