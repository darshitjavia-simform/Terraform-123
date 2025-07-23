#!/bin/bash
set -e

# Log everything to help debug
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "==== Updating packages ===="
apt-get update -y
apt-get install -y apache2 unzip curl

echo "==== Installing MySQL client ===="
apt-get install -y mysql-client

echo "==== Installing AWS CLI v2 (official way) ===="
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
export PATH=$PATH:/usr/local/bin

echo "==== Verifying AWS CLI ===="
aws --version || { echo "AWS CLI install failed"; exit 1; }

echo "==== Fetching DB endpoint from SSM ===="
DB_ENDPOINT=$(aws ssm get-parameter \
  --name "/${environment}/db/endpoint" \
  --region ${aws_region} \
  --query "Parameter.Value" \
  --output text)

echo "DB_ENDPOINT=$DB_ENDPOINT"

# Save to system env
echo "DB_HOST=$DB_ENDPOINT" >> /etc/environment

# Optionally test DB connection
echo "==== Testing DB connection ===="
mysql -h "$DB_ENDPOINT" -u "${db_user}" -p"${db_password}" -e "SELECT 1;" && \
  echo "✅ DB connection successful" > /var/www/html/db-status.html || \
  echo "❌ DB connection failed" > /var/www/html/db-status.html

# Apache test page
echo "<h1>Connected to DB</h1>" > /var/www/html/index.html
echo "OK" > /var/www/html/health.html

# Start Apache
systemctl enable apache2
systemctl start apache2


# Log to console
echo "=== Installing AWS CodeDeploy Agent ==="

# Update packages
sudo apt-get update -y
sudo apt-get install -y ruby wget

# Create a temp directory
TMP_DIR="/tmp/codedeploy-agent-install"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# Download and install the CodeDeploy agent
wget https://aws-codedeploy-${aws_region}.s3.${aws_region}.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Start the agent
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent

# Check status
echo "=== Agent Status ==="
sudo systemctl status codedeploy-agent --no-pager

# Clean up
cd ~
rm -rf "$TMP_DIR"

echo "=== CodeDeploy Agent installation completed ==="
