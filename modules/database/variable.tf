# The environment name (e.g., dev, staging, prod)
# Used for naming resources consistently.
variable "environment" {
  type        = string
  description = "Deployment environment name"
}


# The AWS region where the resources will be deployed.
# Example: us-east-2
variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
  default     = "us-east-2"
}

# The Amazon Machine Image ID to use for the database EC2 instance.
# Example: Ubuntu or Amazon Linux.
variable "ami_id" {
  type        = string
  description = "AMI ID for the database instance"
}

# The EC2 instance type to use for the DB server (e.g., t3.micro, t3.medium).
variable "instance_type" {
  type        = string
  description = "Instance type for the database"
  default     = "t3.micro"
}

# Size of the root EBS volume in GB (for database storage).
variable "volume_size" {
  type        = number
  description = "Root volume size in GB"
  default     = 20
}

# SSH Key pair name to access the EC2 instance.
variable "key_name" {
  type        = string
  description = "EC2 Key pair name"
}

# The VPC ID where the database instance will be deployed.
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

# The private subnet ID where the database EC2 instance will reside.
variable "db_subnet_id" {
  type        = string
  description = "Subnet ID for the database instance"
}

# The security group ID of the application servers that are allowed to access the DB.
variable "app_security_group_id" {
  type        = string
  description = "App server security group ID allowed to connect to DB"
}

# The root password for the MySQL database (used during initial setup).
variable "db_root_password" {
  type        = string
  description = "Root password for the database"
  sensitive   = true
}

# The name of the database to create (e.g., myapp_db).
variable "db_name" {
  type        = string
  description = "Name of the database"
}

# The user to create in the database with privileges on the `db_name` database.
variable "db_user" {
  type        = string
  description = "Database user"
}

# The password for the `db_user` (used for application connectivity).
variable "db_password" {
  type        = string
  description = "Password for the database user"
  sensitive   = true
}
