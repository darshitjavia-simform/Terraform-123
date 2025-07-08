module "mysql_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "mysql-db"

  ami                    = var.mysql_ami_id
  instance_type          = var.mysql_instance_type
  subnet_id              = element(var.private_subnets, 0)  # First private subnet
  vpc_security_group_ids = [module.mysql_sg.security_group_id]
  key_name               = var.key_pair_name

  tags = {
    Name = "mysql-db"
  }

  user_data = file("${path.module}/scripts/mysql-install.sh")
}


module "mysql_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "mysql-sg"
  description = "Allow MySQL from app servers only"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow MySQL from app servers"
      cidr_blocks = var.app_private_cidr_blocks
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}