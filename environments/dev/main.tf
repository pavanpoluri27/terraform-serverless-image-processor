provider "aws" {
  region = var.aws_region
}

# Define local variables
locals {
  project_name = "image-processor-tf"
  environment  = "dev"
}

# Storage Module for S3 & DynamoDB
module "storage" {
  source = "../../modules/storage"

  project_name = local.project_name
  environment  = local.environment
}

# Compute Module for Lambda Function
module "compute" {
  source = "../../modules/compute"

  # Passing the necessary variables
  project_name          = local.project_name
  environment           = local.environment
  upload_bucket_arn     = module.storage.upload_bucket_arn
  upload_bucket_name    = module.storage.upload_bucket_name
  processed_bucket_arn  = module.storage.processed_bucket_arn
  processed_bucket_name = module.storage.processed_bucket_name
  dynamodb_table_arn    = module.storage.dynamodb_table_arn
  dynamodb_table_name   = module.storage.dynamodb_table_name
}

# API Module
module "api" {
  source = "../../modules/api"
  
  # Passing the necessary variables
  project_name         = local.project_name
  environment          = local.environment
  lambda_function_name = module.compute.lambda_function_name
  lambda_invoke_arn    = module.compute.lambda_function_arn
  aws_region           = var.aws_region
}

# Monitoring Module (CloudWatch)
module "monitoring" {
  source = "../../modules/monitoring"

  # Passing the necessary variables
  project_name          = local.project_name
  environment           = local.environment
  lambda_function_name  = module.compute.lambda_function_name
  upload_bucket_name    = module.storage.upload_bucket_name
  processed_bucket_name = module.storage.processed_bucket_name
  aws_region            = var.aws_region
}