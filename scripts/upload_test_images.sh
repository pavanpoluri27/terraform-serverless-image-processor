#!/bin/bash

# Script to download sample images and upload them to the S3 bucket created by Terraform
# Usage: ./upload_test_images.sh <bucket-name>

BUCKET_NAME=$1

if [ -z "$BUCKET_NAME" ]; then
  echo "Error: Bucket name is required."
  echo "Usage: ./upload_test_images.sh <bucket-name>"
  exit 1
fi

# Create a temporary directory for images
IMG_DIR="my_images"
mkdir -p $IMG_DIR

echo "Downloading sample images from Caltech GitHub"

# Using curl to download images
curl -s -o $IMG_DIR/image1.jpg https://raw.githubusercontent.com/google-research/simclr/master/data/caltech-101/101_ObjectCategories/accordion/image_0001.jpg
curl -s -o $IMG_DIR/image2.jpg https://raw.githubusercontent.com/google-research/simclr/master/data/caltech-101/101_ObjectCategories/butterfly/image_0001.jpg
curl -s -o $IMG_DIR/image3.jpg https://raw.githubusercontent.com/google-research/simclr/master/data/caltech-101/101_ObjectCategories/camera/image_0001.jpg
curl -s -o $IMG_DIR/image4.jpg https://raw.githubusercontent.com/google-research/simclr/master/data/caltech-101/101_ObjectCategories/car_side/image_0001.jpg

echo "About to upload images to S3 bucket: $BUCKET_NAME"

# Upload images to S3 bucket
for file in $IMG_DIR/*.jpg; do
  filename=$(basename $file)
  echo "Uploading $filename..."
  aws s3 cp $file s3://$BUCKET_NAME/$filename
done

# Delete the temporary image directory
echo "Cleaning up temporary files..."
rm -rf $IMG_DIR

echo "Upload complete! Images are now being processed by your Lambda function."
echo "Check your CloudWatch dashboard and processed images bucket to see results."