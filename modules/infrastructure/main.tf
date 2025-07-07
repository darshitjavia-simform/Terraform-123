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
  manage_default_network_acl = var.manage_default_network_acl
  create_igw                 = true
  enable_dns_hostnames       = true
  enable_dns_support         = true

  map_public_ip_on_launch = true

  tags = var.tags
}

# Optional: Public NACL
resource "aws_network_acl" "public_nacl" {
  count  = var.enable_public_nacl ? 1 : 0
  vpc_id = module.vpc_base.vpc_id

  dynamic "ingress" {
    for_each = var.public_nacl_ingress_rules
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = var.public_nacl_egress_rules
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = {
    Name = "custom-public-nacl"
  }
}

resource "aws_network_acl_association" "public" {
  count          = var.enable_public_nacl ? length(module.vpc_base.public_subnets) : 0
  subnet_id      = module.vpc_base.public_subnets[count.index]
  network_acl_id = aws_network_acl.public_nacl[0].id
}

# Optional: Private NACL
resource "aws_network_acl" "private_nacl" {
  count  = var.enable_private_nacl ? 1 : 0
  vpc_id = module.vpc_base.vpc_id

  dynamic "ingress" {
    for_each = var.private_nacl_ingress_rules
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = var.private_nacl_egress_rules
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = {
    Name = "custom-private-nacl"
  }
}

resource "aws_network_acl_association" "private" {
  count          = var.enable_private_nacl ? length(module.vpc_base.private_subnets) : 0
  subnet_id      = module.vpc_base.private_subnets[count.index]
  network_acl_id = aws_network_acl.private_nacl[0].id
}
