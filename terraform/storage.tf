# 1. The S3 Bucket
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.environment}-app-data"
}

# 2. DevSecOps: Block Public Access
resource "aws_s3_bucket_public_access_block" "app_data_block" {
  bucket                  = aws_s3_bucket.app_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. DevSecOps: Enforce Encryption at Rest
resource "aws_s3_bucket_server_side_encryption_configuration" "app_data_enc" {
  bucket = aws_s3_bucket.app_data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}