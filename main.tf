provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/infrastructure"

  vpc_name                   = var.vpc_name
  vpc_cidr                   = var.vpc_cidr
  azs                        = var.azs
  public_subnets            = var.public_subnets
  private_subnets           = var.private_subnets
  enable_nat_gateway        = var.enable_nat_gateway
  single_nat_gateway        = var.single_nat_gateway
  enable_vpn_gateway        = var.enable_vpn_gateway
  manage_default_network_acl = var.manage_default_network_acl

  enable_public_nacl        = var.enable_public_nacl
  enable_private_nacl       = var.enable_private_nacl
  public_nacl_ingress_rules = var.public_nacl_ingress_rules
  public_nacl_egress_rules  = var.public_nacl_egress_rules
  private_nacl_ingress_rules = var.private_nacl_ingress_rules
  private_nacl_egress_rules  = var.private_nacl_egress_rules

  tags = var.tags
}

#Compute module

module "compute" {
  source = "./modules/compute"

  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  alb_sg_name        = var.alb_sg_name
  alb_ingress_rules  = var.alb_ingress_rules
  alb_egress_rules   = var.alb_egress_rules

  ec2_sg_name        = var.ec2_sg_name
  ec2_ingress_rules  = var.ec2_ingress_rules
  ec2_egress_rules   = var.ec2_egress_rules

  image_id        = var.image_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  asg_name        = var.asg_name
  asg_min         = var.asg_min
  asg_max         = var.asg_max
  asg_desired     = var.asg_desired
}
