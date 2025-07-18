# Configure the backend to store Terraform state remotely in S3 and lock it using DynamoDB
terraform {
  backend "s3" {
    bucket         = "ftf-charity-terraform-state"                      # S3 bucket to store the state file
    key            = "charity-microsite/terraform.tfstate"              # Path within the bucket
    region         = "eu-west-2"                                        # AWS region of the bucket
    dynamodb_table = "terraform-locks"                                  # DynamoDB table for state locking
    encrypt        = true                                               # Encrypt the state file at rest
  }
}

# Set the default AWS provider region
provider "aws" {
  region = "eu-west-2"
}

# Create the S3 bucket to host the static website
resource "aws_s3_bucket" "site_bucket" {
  bucket        = var.bucket_name
  force_destroy = true                                                # Allows force deletion of non-empty bucket

  lifecycle {
    prevent_destroy = true                                            # Prevent accidental deletion of bucket via Terraform
  }

  tags = {
    Project = "CharityMicrosite"
  }
}

# Configure the bucket to allow public access (required for CloudFront access)
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Attach a bucket policy to allow CloudFront Origin Access Identity (OAI) to read from the bucket
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.site_bucket.id

  depends_on = [
    aws_s3_bucket_public_access_block.block,
    aws_cloudfront_origin_access_identity.oai
  ]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal",
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.site_bucket.arn}/*"
      }
    ]
  })
}

# Create a CloudFront Origin Access Identity to securely access S3
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for accessing the S3 bucket"
}

# Create the CloudFront distribution to serve the site globally
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [
    "freetheforgottencharity.org",                    # Custom domain (root)
    "www.freetheforgottencharity.org"                # Custom domain (www)
  ]

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 60
    default_ttl = 300       # 5 minutes
    max_ttl     = 43200     # 12 hours
  }

  price_class = "PriceClass_100"    # Use lowest-cost edge locations

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:645240995945:certificate/d7ce72fc-b6ae-4564-9509-ccc3baad48ea"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "Charity-CDN"
  }
}

# Route 53 record for the root domain (A record pointing to CloudFront)
resource "aws_route53_record" "root_domain" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "freetheforgottencharity.org"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# Fetch the Route 53 hosted zone info
data "aws_route53_zone" "selected" {
  name         = "freetheforgottencharity.org"
  private_zone = false
}

# Route 53 record for www subdomain (also an A record alias to CloudFront)
resource "aws_route53_record" "www_domain" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.freetheforgottencharity.org"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}



