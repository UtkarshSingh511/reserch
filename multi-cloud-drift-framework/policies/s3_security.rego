package terraform.analysis

# Policy to evaluate and prevent public S3 buckets
deny[msg] {
    input.resource.type == "aws_s3_bucket"
    input.resource.public == true
    msg = "Public S3 buckets are not allowed" # Security violation message
}
