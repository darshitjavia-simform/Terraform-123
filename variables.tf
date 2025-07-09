variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-2"
}

# Reuse all VPC-related variables in root, but values come from dev.tfvars
variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}
variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}
variable "enable_nat_gateway" {
  type = bool
}

variable "single_nat_gateway" {
  type = bool
}
variable "enable_vpn_gateway" {
  type = bool
}
variable "manage_default_network_acl" {
  type = bool
}

variable "enable_public_nacl" {
  type = bool
}
variable "enable_private_nacl" {
  type = bool
}

variable "public_nacl_ingress_rules" { type = list(object({
  rule_no    = number
  protocol   = string
  action     = string
  cidr_block = string
  from_port  = number
  to_port    = number
})) }

variable "public_nacl_egress_rules" { type = list(object({
  rule_no    = number
  protocol   = string
  action     = string
  cidr_block = string
  from_port  = number
  to_port    = number
})) }

variable "private_nacl_ingress_rules" { type = list(object({
  rule_no    = number
  protocol   = string
  action     = string
  cidr_block = string
  from_port  = number
  to_port    = number
})) }

variable "private_nacl_egress_rules" { type = list(object({
  rule_no    = number
  protocol   = string
  action     = string
  cidr_block = string
  from_port  = number
  to_port    = number
})) }

variable "tags" {
  type = map(string)
}


#compute module variables


variable "alb_sg_name" {
  type = string

}

variable "alb_ingress_rules" {
  type = list(any)
}

variable "alb_egress_rules" {
  type = list(any)
}

variable "ec2_sg_name" {
  type = string
}

variable "ec2_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Ingress rules for the EC2 security group"
}

variable "ec2_egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  description = "Egress rules for the EC2 security group"
}

variable "image_id" {
  type        = string
  description = "AMI ID for the EC2 instances"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instances"
}

variable "key_name" {
  type        = string
  description = "Key pair name for SSH access to the EC2 instances"
}

variable "asg_name" {
  type        = string
  description = "Name of the Auto Scaling Group"
}

variable "asg_min" {
  type = number
}

variable "asg_max" {
  type = number
}

variable "asg_desired" {
  type = number
}

# Database Instance Variables
variable "db_ami_id" {
  description = "AMI ID for the database instance"
  type        = string
}

variable "db_instance_type" {
  description = "Instance type for the database server"
  type        = string
  default     = "t3.micro"
}

variable "db_root_password" {
  description = "Root password for MySQL database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Name of the MySQL database"
  type        = string
}

variable "db_user" {
  description = "Username for MySQL database"
  type        = string
}

variable "db_password" {
  description = "Password for MySQL database user"
  type        = string
  sensitive   = true
}

variable "db_backup_bucket" {
  description = "Name of S3 bucket for database backups"
  type        = string
}


#frontend module variables

