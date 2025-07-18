#!/bin/bash
set -e

# Redirect all output to log file for debugging
exec > >(tee /var/log/db-setup.log|logger -t user-data -s 2>/dev/console) 2>&1

# Set environment variables
export environment="dev"
export aws_region="us-east-2"
export SECRET_NAME="todo-api-db"

# Install required packages
sudo apt-get update -y
sudo apt-get install -y mysql-server jq unzip curl

# Start MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# Add AWS CLI to PATH
export PATH="/usr/local/bin:$PATH"

# Retry fetching secret (up to 5 attempts)
MAX_RETRIES=5
RETRY_INTERVAL=10
for i in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $i: Fetching secret from Secrets Manager..."
  SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --region "$aws_region" \
    --query SecretString \
    --output text 2>/dev/null) && break
  sleep $RETRY_INTERVAL
done

if [ -z "$SECRET_JSON" ]; then
  echo "❌ Failed to fetch secret after $MAX_RETRIES attempts"
  exit 1
fi

# Parse credentials
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.db_name')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.db_user')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.db_password')

# Debug: echo parsed values (optional)
echo "Parsed DB Name: $DB_NAME"
echo "Parsed DB User: $DB_USER"

# Create DB and user
sudo mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Allow external MySQL connections
sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
