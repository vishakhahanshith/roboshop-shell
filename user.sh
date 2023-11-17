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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing NodeJS" 

# Once the user is created, if you run this command for the 2nd time, the script will definitely fail because the user already exists
# IMPROVEMENT: first check if the user already exists or not, if doesn't exist, then create the user
useradd roboshop &>>$LOGFILE

# Write a condition to check whether the directory exists or not
mkdir /app &>>$LOGFILE

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE

VALIDATE $? "Downloading user artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip /tmp/user.zip &>>$LOGFILE

VALIDATE $? "Unzipping user"

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies"

# Give the full path of catalogue.service because we are inside /app directory
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>>$LOGFILE

VALIDATE $? "Copying user.service"

systemctl daemon-reload

VALIDATE $? "daemon reload"

systemctl enable user

VALIDATE $? "Enabling user"

systemctl start user

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing mongo client"

mongo --host mongodb.joindevops.online </app/schema/user.js &>>$LOGFILE

VALIDATE $? "Loading user data into mongodb"