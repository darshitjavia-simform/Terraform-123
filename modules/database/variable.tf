variable "vpc_id" {}
variable "private_subnets" {
  type = list(string)
}
variable "mysql_ami_id" {
  description = "AMI ID for Ubuntu or Amazon Linux"
}
variable "mysql_instance_type" {
  default = "t3.micro"
}
variable "key_pair_name" {}
variable "app_private_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks of application instances"
}
