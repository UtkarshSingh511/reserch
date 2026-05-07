# Resource creation with secure settings to prevent configuration drift
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "multi-cloud-secure-bucket"
}

# Ensuring the bucket is private (enforcing access control)
resource "aws_s3_bucket_acl" "secure_bucket_acl" {
  bucket = aws_s3_bucket.secure_bucket.id
  acl    = "private"
}

# Enabling versioning as a safe default
resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
