output "vpc_id" {
  value = module.vpc_base.vpc_id
}

output "public_subnets" {
  value = module.vpc_base.public_subnets
}

output "private_subnets" {
  value = module.vpc_base.private_subnets
}

output "nat_gateway_ids" {
  value = module.vpc_base.natgw_ids
}
