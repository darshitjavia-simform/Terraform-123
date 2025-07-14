variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
}

#Infrastructure module variables

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

#############################################
#compute module variables
#############################################

variable "alb_sg_name" {
  type = string

}

variable "alb_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "alb_egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "ec2_sg_name" {
  type = string
}

variable "ec2_ingress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = optional(list(string))
  }))
  description = "Ingress rules for the EC2 security group"
}

variable "ec2_egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string) # CIDR blocks to allow outbound traffic
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


# ##############################################################
# # Database Instance Variables
# ##############################################################


# Database Instance Variables

variable "environment" {
  type        = string
  description = "Environment name (dev/stage/prod)"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for DB EC2 instance"
}

variable "db_instance_type" {
  type        = string
  description = "EC2 instance type for database"
}

variable "volume_size" {
  type        = number
  description = "Root volume size in GB"
}

variable "db_root_password" {
  type        = string
  description = "DB root password"
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "Name of the database"
}

variable "db_user" {
  type        = string
  description = "Database user"
}

variable "db_password" {
  type        = string
  description = "Database user password"
  sensitive   = true
}

#frontend module variables