source common.sh

Print_Task_Heading "Disable default NodeJS version module"
dnf module disable nodejs -y &>> /tmp/expense.log # output gets appended to the existing
echo $?

Print_Task_Heading "Enable NodeJS module"
dnf module enable nodejs:20 -y &>> /tmp/expense.log
echo $?

Print_Task_Heading "Install NodeJS"
dnf install nodejs -y
echo $?

Print_Task_Heading "Copy Backend Service"
cp backend.service /etc/systemd/system/backend.service
echo $?

Print_Task_Heading "Adding Application User"
useradd expense
echo $?

Print_Task_Heading "Remove Old App Content"
rm -rf /app
echo $?

Print_Task_Heading "App Directory"
mkdir /app
echo $?

Print_Task_Heading "Download App Content"
curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip
echo $?

Print_Task_Heading "Extract App Content"
cd /app
unzip /tmp/backend.zip
echo $?

Print_Task_Heading "Install NodeJS dependencies"
cd /app
npm install
echo $?

systemctl daemon-reload

Print_Task_Heading "Enable backend service"
systemctl enable backend
systemctl start backend
echo $?

Print_Task_Heading "Install MYSQL Client"
dnf install mysql -y
echo $?

Print_Task_Heading "Load Schema"
mysql -h 172.16.17.18 -uroot -pExpenseApp@1 < /app/schema/backend.sql
echo $?