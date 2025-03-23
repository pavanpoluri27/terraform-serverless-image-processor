variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "environment" {
  type        = string
  description = "The deployment environment (dev, test, prod)"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function to monitor"
}

variable "upload_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for image uploads"
}

variable "processed_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for processed images"
}

variable "aws_region" {
  type        = string
  description = "AWS region for resources"
}