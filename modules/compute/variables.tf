variable "alb_sg_name" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the resources will be created"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs"
}

#compute module variables

variable "alb_ingress_rules" {
  description = "List of ingress rules for the ALB security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
  }))
}

variable "alb_egress_rules" {
  description = "List of egress rules for the ALB security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
  }))
}

variable "ec2_sg_name" {
  type = string
}

variable "ec2_ingress_rules" {
  description = "List of ingress rules for the EC2 security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))

}

variable "ec2_egress_rules" {
  description = "List of egress rules for the EC2 security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
  }))
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

variable "environment"{
  type = string
}

variable "aws_region" {
  type        = string
  description = "AWS region where the resources will be created"
}