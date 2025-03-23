output "upload_bucket_name" {
  value       = aws_s3_bucket.image_upload.bucket
  description = "Name of the S3 bucket for image uploads"
}

output "upload_bucket_arn" {
  value       = aws_s3_bucket.image_upload.arn
  description = "ARN of the S3 bucket for image uploads"
}

output "processed_bucket_name" {
  value       = aws_s3_bucket.image_processed.bucket
  description = "Name of the S3 bucket for processed images"
}

output "processed_bucket_arn" {
  value       = aws_s3_bucket.image_processed.arn
  description = "ARN of the S3 bucket for processed images"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.image_metadata.name
  description = "Name of the DynamoDB table for image metadata"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.image_metadata.arn
  description = "ARN of the DynamoDB table for image metadata"
}