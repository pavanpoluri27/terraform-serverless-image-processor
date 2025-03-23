output "upload_bucket_name" {
  value       = module.storage.upload_bucket_name
  description = "Name of the S3 bucket for image uploads"
}

output "processed_bucket_name" {
  value       = module.storage.processed_bucket_name
  description = "Name of the S3 bucket for processed images"
}

output "lambda_function_name" {
  value       = module.compute.lambda_function_name
  description = "Name of the image processing Lambda function"
}

output "api_url" {
  value       = module.api.api_url
  description = "URL of the deployed API"
}

output "dashboard_url" {
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.monitoring.dashboard_name}"
  description = "URL to the CloudWatch dashboard"
}