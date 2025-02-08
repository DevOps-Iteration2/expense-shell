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
mysql_secure_installation --set-root-pass "${mysql_root_password}"&>>$LOG
Check_Status $?