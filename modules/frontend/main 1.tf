
# S3 Bucket Module: Hosts the static frontend website

module "s3_frontend" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "${var.environment}-frontend-site" # Unique S3 bucket name
 

  website = {
    index_document = "index.html"            # Default home page
    error_document = "error.html"            # Error page for 404
  }

  # Security and access settings
  attach_policy            = false  # We'll create the policy separately
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  attach_public_policy     = false
  block_public_policy      = true
  block_public_acls        = true
  ignore_public_acls       = true
  restrict_public_buckets  = true
  force_destroy            = true             # Delete bucket even if it has files

  tags = {
    Name        = "${var.environment}-frontend-site"
    Environment = var.environment
  }
}


# CloudFront Origin Access Identity: Allows CloudFront to access private S3

resource "aws_cloudfront_origin_access_identity" "frontend_oai" {
  comment = "OAI for ${var.environment} frontend"
}


# S3 Bucket Policy: Allow CloudFront OAI to access the bucket

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = module.s3_frontend.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.frontend_oai.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_frontend.s3_bucket_arn}/*"
      }
    ]
  })

  depends_on = [
    module.s3_frontend,
    aws_cloudfront_origin_access_identity.frontend_oai
  ]
}


# Local value to fetch the S3 bucket domain

locals {
  bucket_domain = "${module.s3_frontend.s3_bucket_id}.s3.${var.aws_region}.amazonaws.com"
}


# CloudFront Distribution: Delivers S3-hosted website globally via CDN

resource "aws_cloudfront_distribution" "frontend_cdn" {
  enabled             = true                     # Enable the distribution
  is_ipv6_enabled     = true                     # Enable IPv6 support
  default_root_object = "index.html"             # File to serve by default

  # Origin is the S3 bucket hosting the site
  origin {
    domain_name = local.bucket_domain
    origin_id   = "s3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_oai.cloudfront_access_identity_path
    }
  }

  # Cache behavior: what methods are allowed and how caching works
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3Origin"
    viewer_protocol_policy = "redirect-to-https"  # Force HTTPS

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"                         # No cookies forwarded
      }
    }
  }

  # Restrictions: No geo restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Viewer certificate: Use default CloudFront SSL certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Tags for identification
  tags = {
    Name = "${var.environment}-frontend-distribution"
  }

  # Ensure S3 bucket and policy are created before CloudFront
  depends_on = [
    module.s3_frontend,
    aws_s3_bucket_policy.frontend_bucket_policy
  ]
}

# Upload static files to S3 after bucket is created
resource "null_resource" "upload_static_files" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Uploading static site files to S3..."
      aws s3 cp ./modules/frontend/error.html s3://${module.s3_frontend.s3_bucket_id}/error.html
      aws s3 cp ./modules/frontend/index.html s3://${module.s3_frontend.s3_bucket_id}/index.html
    EOT
  }

  depends_on = [module.s3_frontend]
}
