#############################################
# ------------------------------
# modules/database/main.tf
# ------------------------------

resource "aws_instance" "db_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.db_subnet_id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name              = var.key_name
  iam_instance_profile  = aws_iam_instance_profile.db_instance_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data_base64    = base64encode(templatefile("${path.module}/user_data.sh", {
    db_root_password  = var.db_root_password
    db_name           = var.db_name
    db_user           = var.db_user
    db_password       = var.db_password
  }))

  tags = merge(
    var.tags,
    {
      Name = "db-instance"
    }
  )
}

# Security Group for Database
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Security group for database instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
    description     = "Allow MySQL from App servers"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_iam_role" "db_role" {
  name = "db-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "db_backup_policy" {
  name = "db-backup-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
      Resource = [
        "arn:aws:s3:::${var.s3_bucket}",
        "arn:aws:s3:::${var.s3_bucket}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "db_role_attach" {
  role       = aws_iam_role.db_role.name
  policy_arn = aws_iam_policy.db_backup_policy.arn
}

resource "aws_iam_instance_profile" "db_instance_profile" {
  name = "db-instance-profile"
  role = aws_iam_role.db_role.name
}

resource "aws_s3_bucket" "db_backup" {
  bucket        = var.s3_bucket
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "db_backup_versioning" {
  bucket = aws_s3_bucket.db_backup.id

  versioning_configuration {
    status = "Enabled"
  }
}
