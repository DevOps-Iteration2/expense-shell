source common.sh
app_dir= /app
component= backend

mysql_root_password=$1

if [ -z "${mysql_root_password}" ]; then
  echo Input password is missing
  exit 1
fi

Print_Task_Heading "Disable default NodeJS version module"
dnf module disable nodejs -y &>>$LOG # output gets appended to the existing
Check_Status $?

Print_Task_Heading "Enable NodeJS module"
dnf module enable nodejs:20 -y &>>$LOG
Check_Status $?

Print_Task_Heading "Install NodeJS"
dnf install nodejs -y &>>$LOG
Check_Status $?

Print_Task_Heading "Copy Backend Service"
cp backend.service /etc/systemd/system/backend.service &>>$LOG
Check_Status $?

Print_Task_Heading "Adding Application User"
id expense
if [ $? -ne 0 ]; then
  useradd expense &>>$LOG
fi
Check_Status $?

App_PreReq

Print_Task_Heading "Install NodeJS dependencies"
cd /app
npm install &>>$LOG
Check_Status $?

systemctl daemon-reload &>>$LOG

Print_Task_Heading "Enable backend service"
systemctl enable backend &>>$LOG
systemctl start backend &>>$LOG
Check_Status $?

Print_Task_Heading "Install MYSQL Client"
dnf install mysql -y &>>$LOG
Check_Status $?

Print_Task_Heading "Load Schema"
mysql -h 172.16.17.18 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOG
Check_Status $?