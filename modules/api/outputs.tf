output "api_url" {
  value       = aws_api_gateway_deployment.api_deployment.invoke_url
  description = "URL of the deployed API"
}

output "api_id" {
  value       = aws_api_gateway_rest_api.image_api.id
  description = "ID of the REST API"
}

output "stage_name" {
  value       = aws_api_gateway_deployment.api_deployment.stage_name
  description = "Name of the API deployment stage"
}