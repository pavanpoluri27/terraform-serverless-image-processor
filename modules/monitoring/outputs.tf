output "dashboard_name" {
  value       = aws_cloudwatch_dashboard.main.dashboard_name
  description = "Name of the CloudWatch dashboard"
}

output "log_group_name" {
  value       = aws_cloudwatch_log_group.lambda_logs.name
  description = "Name of the CloudWatch log group for Lambda"
}