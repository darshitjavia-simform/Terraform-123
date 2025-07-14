# Create Secrets Manager secret

module "secrets-manager" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.3.1"

    name    = "${var.environment}-db-secret"
    description = "Database credentials for ${var.environment} environment"

    secret_string = jsonencode({
      db_root_password = var.db_root_password
      db_name          = var.db_name
      db_user          = var.db_user
      db_password      = var.db_password
    })

   #IAM ACCESS CONTROL
    
    create_iam_policy = true
    block_public_policy = true
    force_destroy = true

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Resource = "*"
        }
      ]
    })
}