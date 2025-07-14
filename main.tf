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

}

#Compute module

module "compute" {
  source = "./modules/compute"

  depends_on                    = [module.vpc]
  vpc_id                        = module.vpc.vpc_id
  public_subnets                = module.vpc.public_subnets
  private_subnets               = module.vpc.private_subnets
  alb_sg_name                   = var.alb_sg_name
  ec2_sg_name                   = var.ec2_sg_name
  image_id                      = var.image_id
  instance_type                 = var.instance_type
  key_name                      = var.key_name
  asg_name                      = var.asg_name
  asg_min                       = var.asg_min
  asg_max                       = var.asg_max
  asg_desired                   = var.asg_desired
  alb_ingress_rules             = var.alb_ingress_rules
  alb_egress_rules              = var.alb_egress_rules
  ec2_ingress_rules             = var.ec2_ingress_rules
  ec2_egress_rules              = var.ec2_egress_rules
}


##############################################################
# Database module calling
##############################################################

module "database" {
  source = "./modules/database"

  environment            = var.environment
  ami_id                 = var.ami_id
  instance_type          = var.db_instance_type
  volume_size            = var.volume_size
  key_name               = var.key_name
  vpc_id                 = module.vpc.vpc_id
  db_subnet_id           = module.vpc.private_subnets[0]  # Using the first private subnet for the DB instance
  app_security_group_id  = module.compute.ec2_sg_id
  db_root_password       = var.db_root_password
  db_name                 =var.db_name
  db_user                = var.db_user
  db_password            = var.db_password
}

#Frontend module

module "frontend" {
  source      = "./modules/frontend"
  environment = var.environment
}