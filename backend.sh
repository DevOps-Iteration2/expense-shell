source common.sh

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
if [ -z "$id" ]; then
  echo User already exists
  exit 9
else
  useradd expense
fi
Check_Status $?

Print_Task_Heading "Remove Old App Content"
rm -rf /app &>>$LOG
Check_Status $?

Print_Task_Heading "App Directory"
mkdir /app &>>$LOG
Check_Status $?

Print_Task_Heading "Download App Content"
curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip &>>$LOG
Check_Status $?

Print_Task_Heading "Extract App Content"
cd /app
unzip /tmp/backend.zip &>>$LOG
Check_Status $?

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