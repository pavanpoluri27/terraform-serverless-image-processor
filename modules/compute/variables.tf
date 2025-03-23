variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "environment" {
  type        = string
  description = "The deployment environment (dev, test, prod)"
}

variable "upload_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket for image uploads"
}

variable "upload_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for image uploads"
}

variable "processed_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket for processed images"
}

variable "processed_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for processed images"
}

variable "dynamodb_table_arn" {
  type        = string
  description = "ARN of the DynamoDB table for image metadata"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the DynamoDB table for image metadata"
}