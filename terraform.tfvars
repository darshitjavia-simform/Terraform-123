vpc_name = "dev-vpc"

vpc_cidr = "10.0.0.0/16"

azs = ["us-east-2a", "us-east-2b", "us-east-2c"]

public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

enable_nat_gateway         = true
single_nat_gateway         = true
enable_vpn_gateway         = false
manage_default_network_acl = false

enable_public_nacl  = true
enable_private_nacl = true

public_nacl_ingress_rules = [
  {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  },
  {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
]

public_nacl_egress_rules = [
  {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  },
  {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
]

private_nacl_ingress_rules = [
  {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 0
    to_port    = 65535
  },
  {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0" # Allow ALB to access port 80
    from_port  = 80
    to_port    = 80
  }
]

private_nacl_egress_rules = [
  {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
]



tags = {
  Environment = "dev"
  Owner       = "darshit"
  Terraform   = "true"
}


#coumpte vrariables

alb_sg_name   = "alb-sg"
ec2_sg_name   = "ec2-sg"
image_id      = "ami-0c803b171269e2d72" # Example AMI ID, replace with a valid one for your region
instance_type = "t2.micro"
key_name      = "ec2-key-pair"

alb_ingress_rules = [
  {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
]

alb_egress_rules = [
  {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

ec2_ingress_rules = [
  {
    description = "Health Check from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
]

ec2_egress_rules = [
  {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

asg_name = "app-asg"

asg_min = 2

asg_max = 5

asg_desired = 2


