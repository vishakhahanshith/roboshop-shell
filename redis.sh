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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOGFILE

VALIDATE $? "Installing Redis repo" 

yum module enable redis:remi-6.2 -y &>>$LOGFILE

VALIDATE $? "Enabling Redis 6.2" 

yum install redis -y &>>$LOGFILE

VALIDATE $? "Installing Redis 6.2" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf etc/redis/redis.conf &>>$LOGFILE

VALIDATE $? "Allowing remote connections to Redis" 

systemctl enable redis &>>$LOGFILE

VALIDATE $? "Enabling Redis" 

systemctl start redis &>>$LOGFILE

VALIDATE $? "Starting Redis"