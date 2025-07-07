variable "name" {
    description = "The name of the database instance"
    type        = string
}
variable "ami" {
    description = "The AMI to use for the database instance"
    type        = string
}
variable "instance_type" {
    description = "The type of instance to use for the database"
    type        = string
}
variable "key_name" {
    description = "The name of the key pair to use for SSH access to the database instance"
    type        = string
}
variable "subnet_id" {
    description = "The ID of the subnet in which to launch the database instance"
    type        = string
}
variable "vpc_id" {
    description = "The ID of the VPC in which to launch the database instance"
    type        = string
}
variable "app_sg_id" {
    description = "The security group ID to associate with the database instance"
    type        = string
}
variable "backup_bucket_name" {
    description = "The name of the S3 bucket for database backups"
    type        = string
}
variable "tags" {
  type    = map(string)
  default = {}
}
