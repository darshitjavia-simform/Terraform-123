output "s3_bucket_name" {
  description = "S3 bucket name for static website"
  value       = module.s3.bucket
}

output "cloudfront_url" {
  description = "CloudFront URL to access the frontend"
  value       = module.cloudfront.cloudfront_domain_name
}
