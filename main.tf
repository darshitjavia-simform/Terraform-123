provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/infrastructure"

  vpc_name                   = var.vpc_name
  vpc_cidr                   = var.vpc_cidr
  azs                        = var.azs
  public_subnets             = var.public_subnets
  private_subnets            = var.private_subnets
  enable_nat_gateway         = var.enable_nat_gateway
  single_nat_gateway         = var.single_nat_gateway
  enable_vpn_gateway         = var.enable_vpn_gateway
  manage_default_network_acl = var.manage_default_network_acl

  enable_public_nacl         = var.enable_public_nacl
  enable_private_nacl        = var.enable_private_nacl
  public_nacl_ingress_rules  = var.public_nacl_ingress_rules
  public_nacl_egress_rules   = var.public_nacl_egress_rules
  private_nacl_ingress_rules = var.private_nacl_ingress_rules
  private_nacl_egress_rules  = var.private_nacl_egress_rules

  tags = var.tags
}

#Compute module

module "compute" {
  source = "./modules/compute"

  depends_on        = [module.vpc]
  vpc_id            = module.vpc.vpc_id
  public_subnets    = module.vpc.public_subnets
  private_subnets   = module.vpc.private_subnets
  alb_sg_name       = var.alb_sg_name
  ec2_sg_name       = var.ec2_sg_name
  image_id          = var.image_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  asg_name          = var.asg_name
  asg_min           = var.asg_min
  asg_max           = var.asg_max
  asg_desired       = var.asg_desired
  alb_ingress_rules = var.alb_ingress_rules
  alb_egress_rules  = var.alb_egress_rules
  ec2_ingress_rules = var.ec2_ingress_rules
  ec2_egress_rules  = var.ec2_egress_rules
}

# Database module calling

# module "db_instance" {
#   source = "./modules/database"

#   vpc_id           = module.vpc.vpc_id
#   ami_id           = var.db_ami_id
#   instance_type    = var.db_instance_type
#   db_subnet_id     = module.vpc.private_subnets[0]
#   key_name         = var.key_name
#   app_sg_id        = module.compute.ec2_sg_id
#   db_root_password = var.db_root_password
#   db_name          = var.db_name
#   db_user          = var.db_user
#   db_password      = var.db_password
#   s3_bucket        = var.db_backup_bucket

#   tags = var.tags
# }
