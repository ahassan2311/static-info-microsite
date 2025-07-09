output "bucket_name" {
  value = aws_s3_bucket.site_bucket.bucket
}

output "website_url" {
  value = aws_s3_bucket.site_bucket.website_endpoint
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
