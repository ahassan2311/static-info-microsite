# Output the S3 bucket name
output "bucket_name" {
  value = aws_s3_bucket.site_bucket.bucket
}

# Output the CloudFront distribution domain name
output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

# Output the custom domain URL
output "custom_domain_url" {
  value = "https://freetheforgottencharity.org"
}
