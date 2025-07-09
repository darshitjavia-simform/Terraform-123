###########################
# variables.tf
###########################

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "db_subnet_id" {
  description = "Subnet ID for the DB instance"
  type        = string
}

variable "app_sg_id" {
  description = "ID of the application security group"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "db_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "MySQL database name"
  type        = string
}

variable "db_user" {
  description = "MySQL username"
  type        = string
}

variable "db_password" {
  description = "MySQL user password"
  type        = string
  sensitive   = true
}

variable "s3_bucket" {
  description = "S3 bucket name for DB backups"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
