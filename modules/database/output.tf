###########################
# output.tf
###########################

output "db_instance_id" {
  description = "ID of the database instance"
  value       = aws_instance.db_instance.id
}

output "db_private_ip" {
  description = "Private IP of the database instance"
  value       = aws_instance.db_instance.private_ip
}

output "s3_backup_bucket" {
  description = "S3 bucket used for MySQL backups"
  value       = aws_s3_bucket.db_backup.bucket
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db_sg.id
}

output "db_iam_role_name" {
  description = "Name of the IAM role for database"
  value       = aws_iam_role.db_role.name
}
