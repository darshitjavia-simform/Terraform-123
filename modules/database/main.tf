# Generates a random lowercase string to append to the S3 bucket name to ensure global uniqueness.
resource "random_string" "bucket_suffix" {
  length  = 2
  special = false
  upper   = false
}

# Security group for the database instance
# Allows MySQL traffic (port 3306) only from the application server's security group.
resource "aws_security_group" "db_sg" {
  name        = "${var.environment}-db-sg"
  description = "Security group for database"
  vpc_id      = var.vpc_id

  # Ingress rule: allow database traffic from app servers only
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]  # Only allow traffic from app SG
    description     = "Allow DB access from app server"
  }

  # Egress rule: allow all outbound traffic from DB instance (e.g., for updates or S3 access)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-db-sg"
  }
}

# Creates a private S3 bucket to store database backups.
# Uses the random suffix to ensure global uniqueness.
resource "aws_s3_bucket" "db_backup" {
  bucket = "${var.environment}-db-backup-${random_string.bucket_suffix.result}"

  tags = {
    Name    = "${var.environment}-db-backup"
    Purpose = "database-backups"
  }
}

# Enables versioning on the S3 backup bucket to allow rollback or recovery of deleted/overwritten backups.
resource "aws_s3_bucket_versioning" "db_backup_versioning" {
  bucket = aws_s3_bucket.db_backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Blocks all forms of public access to the S3 backup bucket for security and compliance.
resource "aws_s3_bucket_public_access_block" "db_backup_block" {
  bucket = aws_s3_bucket.db_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Creates an IAM Role for the database EC2 instance.
# This allows the instance to assume this role to access AWS services (like S3).
resource "aws_iam_role" "db_role" {
  name = "${var.environment}-db-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"  # EC2 service is allowed to assume this role
      }
    }]
  })
}

# IAM policy granting permissions to the DB instance to interact with the backup S3 bucket.
resource "aws_iam_policy" "db_backup_policy" {
  name = "${var.environment}-db-backup-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.db_backup.arn,
        "${aws_s3_bucket.db_backup.arn}/*"
      ]
    }]
  })
}

# Attaches the backup access policy to the role so the EC2 instance can perform backup operations.
resource "aws_iam_role_policy_attachment" "db_backup_attach" {
  role       = aws_iam_role.db_role.name
  policy_arn = aws_iam_policy.db_backup_policy.arn
}

# Creates an instance profile that wraps the IAM role so it can be attached to the EC2 instance.

resource "aws_iam_instance_profile" "db_instance_profile" {
  name = "${var.environment}-db-instance-profile"
  role = aws_iam_role.db_role.name
}

# Launches an EC2 instance that will act as the database server.
# It uses the IAM instance profile for S3 backup permissions and private subnet for isolation.

resource "aws_instance" "db_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.db_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]  # Secure access with limited SG
  iam_instance_profile   = aws_iam_instance_profile.db_instance_profile.name
  monitoring             = true  # Enables detailed CloudWatch monitoring

  # Root volume configuration
  root_block_device {
    volume_size = var.volume_size         # GB size of the disk
    volume_type = "gp3"                   # Recommended volume type for performance
    encrypted   = true                    # Encrypts the EBS volume for security
  }

  # Bootstraps the instance using a shell script to:
  # - Install MySQL
  # - Set up database and user
  # - Schedule daily S3 backups using cron

  user_data = templatefile("${path.module}/user_data.sh", {
    db_root_password = var.db_root_password
    db_name          = var.db_name
    db_user          = var.db_user
    db_password      = var.db_password
    s3_bucket        = aws_s3_bucket.db_backup.bucket
    environment      = var.environment
    aws_region       = var.aws_region
  })

  tags = {
    Name        = "${var.environment}-database"
    Environment = var.environment
  }
}


#secure database credentials using AWS Secrets Manager

module "db_secrets" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 1.0"

  name                    = "${var.environment}-db-credentials"
  description             = "MySQL credentials for ${var.environment} DB on EC2"
  recovery_window_in_days = 7

  secret_string = jsonencode({
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  })

  tags = {
    Environment = var.environment
    Application = "Database"
  }
}

data "aws_caller_identity" "current" {
  # Fetches the current AWS account ID for use in policies
}

resource "aws_iam_policy" "secrets_read_policy" {
  name = "${var.environment}-secrets-read"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecrets"
      ],
      Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}-db-credentials*"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "secrets_read_attach" {
  role       = aws_iam_role.db_role.name
  policy_arn = aws_iam_policy.secrets_read_policy.arn
}
