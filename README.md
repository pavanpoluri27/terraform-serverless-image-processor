# Serverless Image Processing with Terraform and AWS

This project demonstrates a serverless image processing pipeline built with AWS services and Terraform. The pipeline automatically processes images uploaded to an S3 bucket, stores metadata in DynamoDB, and makes the processed images available through an API. The goal of this project is to use Infrastructure as Code through Terraform and use the free tier AWS resources to set up the infrastructure. Hence, the image "processing" in the context of this project is actually getting the image (object) from the uploaded S3 bucket, renaming it, and putting it into a processed S3 bucket.

## Architecture

The project uses the following AWS services:

- **S3**: For storing original and processed images
- **Lambda** (Python): For image processing logic
- **DynamoDB**: For storing image metadata
- **API Gateway**: For providing REST API access to processed images
- **CloudWatch**: For monitoring and logging

## Features

- Automated image processing on upload
- Image transformation and storage
- Metadata tracking in DynamoDB
- RESTful API access
- Monitoring dashboard
- CI/CD pipeline with GitHub Actions

## Prerequisites

- AWS Account (Free Tier compatible)
- Terraform (>= 1.0.0)
- AWS CLI
- Python 3.9+
- GitHub Account

## Project Structure

The project follows a modular Terraform structure:

```
terraform-serverless-image-processor/
├── .github/workflows/         # GitHub Actions workflows
├── modules/                   # Terraform modules
│   ├── storage/               # S3 buckets and DynamoDB
│   ├── compute/               # Lambda functions (Python)
│   ├── api/                   # API Gateway
│   └── monitoring/            # CloudWatch
├── environments/
│   └── dev/                   # Dev environment config
├── scripts/                   # Helper scripts
├── test-images/               # Sample images for testing
└── README.md
```

## Deployment Steps

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/terraform-serverless-image-processor.git
cd terraform-serverless-image-processor
```

### 2. Configure AWS credentials

```bash
aws configure
```

### 3. Create the Python Lambda layer manually

Before deploying with Terraform, create the Lambda layer structure manually:

```bash
cd modules/compute/src
mkdir -p python/lib/python3.9/site-packages
pip install -r requirements.txt -t python/lib/python3.9/site-packages
zip -r lambda_layer.zip python
cd ../../../
```

### 4. Deploy the infrastructure

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 5. Test the image processing pipeline

After deployment, use the provided script to upload test images:

```bash
chmod +x scripts/upload_test_images.sh
./scripts/upload_test_images.sh $(terraform output -raw upload_bucket_name)
```

### 6. Access the processed images

You can view the processed images through the AWS console or using the deployed API:

```
API URL: $(terraform output -raw api_url)/images
```

### 7. Monitor the process

Access the CloudWatch dashboard using the generated URL:

```
Dashboard URL: $(terraform output -raw dashboard_url)
```

## How It Works

1. **Image Upload**: Images are uploaded to an S3 bucket
2. **Event Triggering**: S3 event notification automatically triggers the Lambda function
3. **Image Processing**: The Python Lambda function processes the image
4. **Metadata Storage**: Image metadata is stored in DynamoDB
5. **API Access**: Processed images and metadata can be accessed via REST API

## Infrastructure as Code Benefits

This project demonstrates several key Terraform and infrastructure-as-code concepts:

- **Modular Design**: Clear separation of concerns with reusable modules
- **CI/CD Integration**: Infrastructure changes are validated and applied through GitHub Actions
- **Environment Management**: Easy to create multiple environments with minimal changes
- **State Management**: Proper Terraform state handling
- **Resource Dependencies**: Automatic dependency resolution and ordering

## Terraform Modules

- **Storage Module**: Manages S3 buckets and DynamoDB tables
- **Compute Module**: Handles Lambda functions with IAM roles and policies
- **API Module**: Configures API Gateway
- **Monitoring Module**: Sets up CloudWatch logs and dashboards

## CI/CD Pipeline

The project includes a GitHub Actions workflow that:

1. Validates the Terraform configuration
2. Plans the infrastructure changes on pull requests
3. Applies the changes when merged to main

To set up the CI/CD pipeline:

1. Add your AWS credentials as GitHub repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

2. Push your code to GitHub to trigger the workflow

## AWS Free Tier Considerations

This project is designed to stay within AWS Free Tier limits:

- Uses on-demand DynamoDB to minimize costs
- Implements cleanup processes for test data
- Optimizes Lambda execution time
- Uses GitHub Actions for CI/CD

## Extending the Project

This project can be extended in several ways:

- Add more sophisticated image processing using Pillow or other libraries
- Implement user authentication for the API
- Create a web frontend for uploads and viewing
- Add multi-region replication for global availability

## License

This project is licensed under the MIT License - see the LICENSE file for details.