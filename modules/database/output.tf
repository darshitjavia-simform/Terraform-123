# Output the EC2 instance ID of the database server.
# Useful for referencing in monitoring or automation scripts.
output "db_instance_id" {
  value = aws_instance.db_instance.id
}

# Output the private IP address of the database server.
# This can be used by the app server to connect securely via internal networking.
output "db_instance_private_ip" {
  value = aws_instance.db_instance.private_ip
}

# Output the name of the S3 bucket where DB backups are stored.
# Useful for setting up lifecycle rules, cost monitoring, etc.
output "s3_backup_bucket" {
  value = aws_s3_bucket.db_backup.bucket
}

# Output the security group ID of the database server.
# Helpful if you want to attach this SG to other related resources.
output "db_security_group_id" {
  value = aws_security_group.db_sg.id
}

# Output the private DNS name of the database server.
# This can be used by the application server to connect to the database without needing to know the
output "db_private_dns" {
  value = aws_instance.db_instance.private_dns
}



