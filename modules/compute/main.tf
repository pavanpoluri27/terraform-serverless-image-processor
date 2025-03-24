# Define an IAM role for Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Define an IAM policy for Lambda to access S3 and DynamoDB
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-policy"
  description = "Policy for Lambda to access S3 and DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Accessing S3 bucket
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          var.upload_bucket_arn,
          "${var.upload_bucket_arn}/*",
          var.processed_bucket_arn,
          "${var.processed_bucket_arn}/*"
        ]
      },
      # Accessing DynamoDB table
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = var.dynamodb_table_arn
      },
      # Creating logs for CloudWatch
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Create a Lambda layer for Python dependencies
resource "aws_lambda_layer_version" "dependencies_layer" {
  layer_name          = "${var.project_name}-${var.environment}-dependencies"
  compatible_runtimes = ["python3.9"]

  filename = "${path.module}/src/lambda_layer.zip"
}

# Zip the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_function.py"
  output_path = "${path.module}/deployment-package.zip"
}

# Lambda function for actual image processing
resource "aws_lambda_function" "image_processor" {
  function_name    = "${var.project_name}-${var.environment}-processor"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "lambda_function.handler"
  runtime          = "python3.9"
  timeout          = 10
  memory_size      = 128
  role             = aws_iam_role.lambda_exec_role.arn
  layers           = [aws_lambda_layer_version.dependencies_layer.arn]

  environment {
    variables = {
      PROCESSED_BUCKET = var.processed_bucket_name
      METADATA_TABLE   = var.dynamodb_table_name
      ENV              = var.environment
    }
  }
}

# Permission for S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.upload_bucket_arn
}

# S3 bucket notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.upload_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".png"
  }
  # Want to make sure the Lambda permission is created before this notification
  depends_on = [aws_lambda_permission.allow_s3]
}