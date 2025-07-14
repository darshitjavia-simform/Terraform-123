
variable "vpc_name"{ 
  type = string 
}

variable "vpc_cidr"{ 
  type = string 
}
variable "azs"{ 
  type = list(string) 
}

variable "public_subnets" { 
  type = list(string) 
}

variable "private_subnets" { 
  type = list(string) 
}
variable "enable_nat_gateway"{ 
  type = bool 
}

variable "single_nat_gateway"{ 
  type = bool 
}
variable "enable_vpn_gateway"{ 
  type = bool 
}

# variable "manage_default_network_acl"{ 
#   type = bool 
# }

# variable "enable_public_nacl"{ 
#   type = bool 
# }
# variable "enable_private_nacl"{ 
#   type = bool 
# }

# variable "public_nacl_ingress_rules"     { type = list(object({
#   rule_no    = number
#   protocol   = string
#   action     = string
#   cidr_block = string
#   from_port  = number
#   to_port    = number
# })) }

# variable "public_nacl_egress_rules"      { type = list(object({
#   rule_no    = number
#   protocol   = string
#   action     = string
#   cidr_block = string
#   from_port  = number
#   to_port    = number
# })) }

# variable "private_nacl_ingress_rules"    { type = list(object({
#   rule_no    = number
#   protocol   = string
#   action     = string
#   cidr_block = string
#   from_port  = number
#   to_port    = number
# })) }

# variable "private_nacl_egress_rules"     { type = list(object({
#   rule_no    = number
#   protocol   = string
#   action     = string
#   cidr_block = string
#   from_port  = number
#   to_port    = number
# })) }

# variable "tags" {
#   type = map(string)
# }