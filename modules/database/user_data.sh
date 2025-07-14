#!/bin/bash
set -e

# Set environment variables (CHANGE THESE VALUES)
export environment="dev"
export aws_region="us-east-2"

sudo apt-get update -y
sudo apt-get install -y mysql-server jq unzip curl

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# Update PATH for AWS CLI
export PATH="/usr/local/bin:$PATH"

# Get secret from AWS Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "${environment}-db-credentials" \
  --region "${aws_region}" \
  --query SecretString \
  --output text)

# Parse values from secret JSON
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.db_name')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.db_user')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.db_password')

# Secure MySQL: Create DB and user
sudo mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Allow external MySQL connections
sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql