# # Frontend static site hosting with S3 and CloudFront
module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.2.0"

  bucket = "frontend-static-${random_string.suffix.result}"
  acl    = "private"

  website = {
    index_document = "index.html"
    error_document = "index.html"
  }

  policy = data.aws_iam_policy_document.allow_public_read.json

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  versioning = {
    enabled = true
  }

  tags = {
    Name        = "FrontendStaticHosting"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "allow_public_read" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3.bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# CloudFront distribution for static site delivery

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "5.0.0"

  enabled             = true
  default_root_object = "index.html"

  origin = {
    s3 = {
      domain_name = module.s3.bucket_regional_domain_name
      origin_id   = "s3Origin"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  tags = {
    Project     = "FrontendDelivery"
    Environment = var.environment
  }
}
