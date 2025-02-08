echo Disable default NodeJS version module
dnf module disable nodejs -y &>> /tmp/expense.log # output gets appended to the existing
echo $?

echo Enable NodeJS module
dnf module enable nodejs:20 -y
echo $?

echo Install NodeJS
dnf install nodejs -y
echo $?

echo Copy Backend Service
cp backend.service /etc/systemd/system/backend.service
$?

echo Adding Application User
useradd expense
$?

echo Remove Old App Content
rm -rf /app
$?

echo App Directory
mkdir /app
$?

echo Download App Content
curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip
$?

echo Extract App Content
cd /app
unzip /tmp/backend.zip
$?

echo Install NodeJS dependencies
cd /app
npm install
$?

systemctl daemon-reload

echo Enable backend service
systemctl enable backend
systemctl start backend
$?

echo Install MYSQL Client
dnf install mysql -y
$?

echo Load Schema
mysql -h 172.16.17.18 -uroot -pExpenseApp@1 < /app/schema/backend.sql
$?