# Free The Forgotten Charity Microsite

A static informational website for *Free The Forgotten* — a charity dedicated to raising awareness and support for forgotten causes. This project demonstrates infrastructure provisioning and deployment automation using AWS and Terraform.

---

## Project Overview

This microsite provides visitors with essential information about the charity’s mission and volunteering opportunities. The website is deployed as a static site on AWS S3, delivered globally through CloudFront CDN with HTTPS, and uses Route 53 for DNS management.

---

## Technology Stack

- **AWS S3** — Static website hosting  
- **AWS CloudFront** — Content Delivery Network (CDN) and HTTPS support  
- **AWS Route 53** — DNS management for custom domain  
- **AWS Certificate Manager (ACM)** — TLS/SSL certificates  
- **Terraform** — Infrastructure as Code to provision AWS resources  
- **GitHub Actions** — CI/CD pipeline for provisioning infrastructure and deploying website content  

---

## Features

- Fully automated infrastructure provisioning and deployment via GitHub Actions  
- Custom domain support with Route 53 DNS alias records  
- Secure HTTPS delivery using ACM certificates  
- Cache control configuration on CloudFront for efficient content delivery  
- S3 bucket configured with appropriate policies and CloudFront origin access identity for security  

---

## Setup & Deployment

### Prerequisites

- AWS Account with necessary permissions for S3, CloudFront, Route 53, ACM, and DynamoDB  
- Terraform CLI installed (version 1.8.3 recommended)  
- GitHub repository with Actions enabled  
- GitHub repository secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION` (e.g., `eu-west-2`)
  - `TF_BUCKET_NAME` (for remote state storage)

### Infrastructure Provisioning

1. Terraform provisions AWS resources including S3 bucket, CloudFront distribution, Route 53 records, and DynamoDB table for state locking.  
2. Remote Terraform state is stored in S3 with DynamoDB for state locking to support CI/CD pipeline stability.  

### CI/CD Pipeline

- Runs on every push to the `main` branch.  
- Executes Terraform init, plan, and apply to provision/update infrastructure.  
- Syncs website content from the `site` directory to the S3 bucket using AWS CLI.  

---

## How to Use

- Update website content in the `site/` directory.  
- Commit and push changes to the `main` branch.  
- GitHub Actions automatically runs, applying infrastructure changes and syncing updated content.  
- Changes will be live after CloudFront cache TTL expires or cache invalidation occurs (configurable).  

---

## Challenges & Learnings

- Handling Terraform state in CI/CD workflows required implementing remote state storage with S3 and DynamoDB to avoid resource duplication errors.  
- Importing existing AWS resources into Terraform state was necessary when manually created resources existed.  
- Proper IAM permissions and security policies ensured secure access between CloudFront and S3.  

---

## License

This project is for educational purposes and is not intended for open-source use.

---

## Contact

For questions or contributions, please reach out or create an issue on this repository.

