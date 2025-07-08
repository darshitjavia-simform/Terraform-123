#!/bin/bash
sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL Installation (basic)
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'StrongRootPass123!'; FLUSH PRIVILEGES;"
