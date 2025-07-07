module "db_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  name                        = "db-instance"
  ami                         = "ami-12345678"
  instance_type               = "t2.micro"
  key_name                    = "my-key-pair"
  vpc_security_group_ids      = ["sg-12345678"]
  subnet_id                   = "subnet-12345678"
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.db_instance_profile.name

    user_data = <<-EOF
                #!/bin/bash
                echo "Running database setup..."
                # Add your database setup commands here
                EOF


  tags = {
    Name        = "DatabaseInstance"
    Environment = "Production"
    Application = "MyApp"
    Role        = "Database"
  }

}

# Security Group: Only allow MySQL traffic from app SG
resource "aws_security_group" "db_sg" {
  name        = "${var.name}-db-sg"
  description = "Allow MySQL from App SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
    description     = "MySQL from App instances"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for Backup to S3
resource "aws_iam_role" "db_backup_role" {
  name = "${var.name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}


resource "aws_iam_role_policy" "db_backup_policy" {
  name = "${var.name}-backup-policy"
  role = aws_iam_role.db_backup_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
      Resource = [
        "arn:aws:s3:::${var.backup_bucket_name}",
        "arn:aws:s3:::${var.backup_bucket_name}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "db_instance_profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.db_backup_role.name
}