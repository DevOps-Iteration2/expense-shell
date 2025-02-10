source common.sh
mysql_root_password=$1

if [ -z "${mysql_root_password}" ]; then
  echo Input password is missing
fi

Print_Task_Heading "Install MYSQL Server"
dnf install mysql-server -y &>>$LOG
Check_Status $?

Print_Task_Heading "Start MYSQL Service"
systemctl enable mysqld &>>$LOG
systemctl start mysqld &>>$LOG
Check_Status $?

Print_Task_Heading "Setup root password"
echo 'show databases'|mysql -h 172.16.17.18 -uroot -p${mysql_root_password}&>>$LOG
mysql_secure_installation --set-root-pass ${mysql_root_password}&>>$LOG
Check_Status $?