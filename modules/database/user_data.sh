#!/bin/bash
yum update -y
yum install -y mysql-server
systemctl start mysqld
systemctl enable mysqld

mysqladmin -u root password '${db_root_password}'

mysql -u root -p'${db_root_password}' -e "CREATE DATABASE IF NOT EXISTS ${db_name};"
mysql -u root -p'${db_root_password}' -e "CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_password}';"
mysql -u root -p'${db_root_password}' -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'%';"
mysql -u root -p'${db_root_password}' -e "FLUSH PRIVILEGES;"
