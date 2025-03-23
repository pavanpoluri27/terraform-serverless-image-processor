# Necessary imports
import boto3
import os
import uuid
from datetime import datetime

# Initialize AWS clients
s3_client = boto3.client('s3')
dynamodb_client = boto3.client('dynamodb')

# Environment variables from Lambda function resource
PROCESSED_BUCKET = os.environ['PROCESSED_BUCKET']
METADATA_TABLE = os.environ['METADATA_TABLE']

def handler(event, context):
    try:
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
        
        return {
            'statusCode': 200,
            'body': {
                'message': 'Image processed successfully',
                'imageId': image_id
            }
        }
        
    except Exception as e:
        print(f"Error processing image: {str(e)}")
        raise e