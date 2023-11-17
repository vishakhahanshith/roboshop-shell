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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOGFILE

VALIDATE $? "Installing rabbitmq erlang package"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOGFILE

VALIDATE $? "Installing rabbitmq server package"

yum install rabbitmq-server -y &>>$LOGFILE

VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOGFILE

VALIDATE $? "Enabling rabbitmq erlang"

systemctl start rabbitmq-server &>>$LOGFILE

VALIDATE $? "Starting rabbitmq erlang"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGFILE

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGFILE