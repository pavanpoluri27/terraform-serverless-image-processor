# Necessary imports
import boto3
import os
import uuid
import json
from datetime import datetime
from decimal import Decimal

# Initialize AWS clients
s3_client = boto3.client('s3')
dynamodb_client = boto3.client('dynamodb')
dynamodb_resource = boto3.resource('dynamodb')

# Custom JSON encoder to handle Decimal types
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        if isinstance(obj, datetime):
            return obj.isoformat()
        return super(DecimalEncoder, self).default(obj)

# Environment variables from Lambda function resource
PROCESSED_BUCKET = os.environ['PROCESSED_BUCKET']
METADATA_TABLE = os.environ['METADATA_TABLE']

def handler(event, context):
    try:
        # API Gateway event
        if 'Records' not in event:
            return handle_api_request(event)
        else:
            # S3 event
            return handle_s3_event(event)
            
    except Exception as e:
        print(f"Error: {str(e)}")
        # Return a formatted error response for API Gateway
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            }, cls=DecimalEncoder)
        }

def handle_api_request(event):
    #Handle requests coming from API Gateway
    print(f"Received API Gateway event: {json.dumps(event)}")
    
    # Get HTTP method from the event
    http_method = event.get('httpMethod', '')
    
    if http_method == 'GET':
        # Use resource to get a Table object
        table = dynamodb_resource.Table(METADATA_TABLE)
        
        # Scan the DynamoDB table to get all images
        response = table.scan()
        items = response.get('Items', [])
        
        # Format the response for API Gateway
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # For CORS support
            },
            'body': json.dumps({
                'images': items
            }, cls=DecimalEncoder)
        }
    else:
        # Return error for unsupported methods
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': f'Unsupported method: {http_method}'
            }, cls=DecimalEncoder)
        }

def handle_s3_event(event):
    #Handle events from S3 bucket notifications
    # Get the object from the event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key'].replace('+', ' ')
    
    print(f"Processing image from bucket: {bucket}, key: {key}")
    
    # Get the image from S3
    response = s3_client.get_object(Bucket=bucket, Key=key)
    image_content = response['Body'].read()
    content_type = response.get('ContentType', 'image/jpeg')
    
    # We are just simply copying the image from the upload bucket,
    # renaming it and putting it in the processed bucket.
    processed_key = f"processed-{key.split('/')[-1]}"
    
    # Upload the renamed image to the processed bucket
    s3_client.put_object(
        Bucket=PROCESSED_BUCKET,
        Key=processed_key,
        Body=image_content,
        ContentType=content_type
    )
    
    # Save metadata to DynamoDB
    image_id = str(uuid.uuid4())
    timestamp = datetime.now().isoformat()
    
    dynamodb_client.put_item(
        TableName=METADATA_TABLE,
        Item={
            'ImageId': {'S': image_id},
            'OriginalBucket': {'S': bucket},
            'OriginalKey': {'S': key},
            'ProcessedBucket': {'S': PROCESSED_BUCKET},
            'ProcessedKey': {'S': processed_key},
            'ProcessedAt': {'S': timestamp},
            'OriginalSize': {'N': str(len(image_content))},
            'ProcessedSize': {'N': str(len(image_content))},
            'SimulatedProcessing': {'S': 'For this portfolio project, we simulate image processing by copying the original image. In a production scenario, we would use Pillow for actual image processing.'}
        }
    )
    
    print(f"Successfully processed {key} and saved metadata")
    
    # Return a successful response - this is primarily for API Gateway,
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'message': 'Image processed successfully',
            'imageId': image_id
        }, cls=DecimalEncoder)
    }