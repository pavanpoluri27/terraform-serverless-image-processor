# S3 bucket to store the uploaded images
resource "aws_s3_bucket" "image_upload" {
  bucket        = "${var.project_name}-${var.environment}-uploads"
  force_destroy = true  # Allows deletion of non-empty bucket for cleanup
}

# S3 bucket to store the processed images
resource "aws_s3_bucket" "image_processed" {
  bucket        = "${var.project_name}-${var.environment}-processed"
  force_destroy = true
}

# Block public access to the S3 bucket used to store the uploaded images
resource "aws_s3_bucket_public_access_block" "upload_block" {
  bucket = aws_s3_bucket.image_upload.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Block public access to the S3 bucket used to store the processed images
resource "aws_s3_bucket_public_access_block" "processed_block" {
  bucket = aws_s3_bucket.image_processed.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create a DynamoDB table to store the image metadata
resource "aws_dynamodb_table" "image_metadata" {
  name           = "${var.project_name}-${var.environment}-metadata"
  billing_mode   = "PAY_PER_REQUEST"  # Stays within free tier
  hash_key       = "ImageId"

  attribute {
    name = "ImageId"
    type = "S"
  }

  tags = {
    Name        = "ImageMetadata"
    Environment = var.environment
  }
}