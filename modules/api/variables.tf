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
  description = "Name of the Lambda function to integrate with API Gateway"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "ARN for invoking the Lambda function"
}

variable "aws_region" {
  type        = string
  description = "AWS region for resources"
}