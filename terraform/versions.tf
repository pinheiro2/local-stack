terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

# 1. The AWS Provider (Configured for LocalStack)
provider "aws" {
  region                      = var.aws_region
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2            = "http://localhost:4566"
    iam            = "http://localhost:4566"
    rds            = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    s3             = "http://localhost:4566"
  }
}

# 2. The Vault Provider (Configured for local dev server)
provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "dev-root-token" 
}