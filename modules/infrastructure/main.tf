module "vpc_base" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway         = var.enable_nat_gateway
  single_nat_gateway         = var.single_nat_gateway
  enable_vpn_gateway         = var.enable_vpn_gateway
  manage_default_network_acl = false
  manage_default_route_table = false  

  create_igw                 = true
  enable_dns_hostnames       = true
  enable_dns_support         = true

  map_public_ip_on_launch = true

}
