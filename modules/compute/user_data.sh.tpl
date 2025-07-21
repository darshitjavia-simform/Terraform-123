#!/bin/bash
set -e

# Log everything to help debug
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "==== Updating packages ===="
apt-get update -y
apt-get install -y apache2 unzip curl

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

# Use Apache to show a test page
echo "<h1>Connected to DB at $DB_ENDPOINT</h1>" > /var/www/html/index.html
echo "OK" > /var/www/html/health.html

# Start Apache
systemctl enable apache2
systemctl start apache2
