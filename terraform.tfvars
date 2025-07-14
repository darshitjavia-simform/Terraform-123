aws_region = "us-east-2"

# VPC Configuration
vpc_name = "dev-vpc"
vpc_cidr = "10.0.0.0/16"

azs = ["us-east-2a", "us-east-2b", "us-east-2c"]

public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

enable_nat_gateway = true
single_nat_gateway = true
enable_vpn_gateway = false

# Compute Configuration
alb_sg_name   = "alb-sg"
ec2_sg_name   = "ec2-sg"
image_id      = "ami-0d1b5a8c13042c939"
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
    cidr_blocks = []
  },
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


###########################
# variables for database module
###########################

# Database configuration
environment = "dev"
ami_id = "ami-0d1b5a8c13042c939"
db_instance_type = "t3.micro"
volume_size = 20
db_root_password = "RootPassword123"
db_name = "myappdb"
db_user = "appuser"
db_password = "AppUser123"