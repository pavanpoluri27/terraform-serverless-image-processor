# REST API definition
resource "aws_api_gateway_rest_api" "image_api" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "API for image processing service"
}

# Resource for getting image metadata
# Setting up the endpoint /images
resource "aws_api_gateway_resource" "images" {
  rest_api_id = aws_api_gateway_rest_api.image_api.id
  parent_id   = aws_api_gateway_rest_api.image_api.root_resource_id
  path_part   = "images"
}

# GET method to list images
resource "aws_api_gateway_method" "get_images" {
  rest_api_id   = aws_api_gateway_rest_api.image_api.id
  resource_id   = aws_api_gateway_resource.images.id
  http_method   = "GET"
  authorization = "NONE"
}

# Link the GET method with Lambda function
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.image_api.id
  resource_id             = aws_api_gateway_resource.images.id
  http_method             = aws_api_gateway_method.get_images.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_invoke_arn}/invocations"
}

# Deploy the API
resource "aws_api_gateway_deployment" "api_deployment" {
  # Want to make sure this resource is initialized after 
  # successful lambda integration
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.image_api.id

  # To prevent downtime
  lifecycle {
    create_before_destroy = true
  }
}

# Defining the stage
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.image_api.id
  stage_name    = var.environment
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.image_api.execution_arn}/*/${aws_api_gateway_method.get_images.http_method}${aws_api_gateway_resource.images.path}"
}