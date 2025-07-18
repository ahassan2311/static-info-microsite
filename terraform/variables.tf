# Define the S3 bucket name variable with default value "ftf-charity-microsite-uk-2025"
variable "bucket_name" {
  description = "The name of the S3 bucket for the static site"
  default     = "ftf-charity-microsite-uk-2025"
  type        = string
}
