output "lambda_function_name" {
  value       = aws_lambda_function.image_processor.function_name
  description = "Name of the image processing Lambda function"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.image_processor.arn
  description = "ARN of the image processing Lambda function"
}

output "lambda_role_arn" {
  value       = aws_iam_role.lambda_exec_role.arn
  description = "ARN of the Lambda execution role"
}