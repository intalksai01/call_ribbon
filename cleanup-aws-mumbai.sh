#!/bin/bash

# IntalksAI Call Ribbon - AWS Mumbai Region Cleanup Script
# Removes all resources from ap-south-1 region

set -e

# Configuration
AWS_REGION="ap-south-1"
WIDGET_BUCKET="intalksai-call-ribbon-widget-mumbai-1759694831"
DISTRIBUTION_ID="E19YDUHE03AZ14"
APP_NAME="intalksai-call-ribbon"

echo "🧹 Starting cleanup of AWS Mumbai region (ap-south-1) resources..."

# Set AWS region
export AWS_DEFAULT_REGION=$AWS_REGION
echo "📍 Using AWS Region: $AWS_REGION"

# 1. Clean up CloudFront Distribution
echo "🗑️ Step 1: Cleaning up CloudFront distribution..."

# Get the ETag for the distribution
echo "🔍 Getting CloudFront distribution ETag..."
ETAG=$(aws cloudfront get-distribution --id $DISTRIBUTION_ID --query 'ETag' --output text 2>/dev/null || echo "")

if [ ! -z "$ETAG" ]; then
    echo "☁️ Found CloudFront distribution: $DISTRIBUTION_ID"
    
    # Disable the distribution first
    echo "⏹️ Disabling CloudFront distribution..."
    aws cloudfront update-distribution --id $DISTRIBUTION_ID --distribution-config file://<(aws cloudfront get-distribution --id $DISTRIBUTION_ID --query 'Distribution.DistributionConfig' --output json | jq '.Enabled = false') --if-match $ETAG
    
    echo "⏳ Waiting for distribution to be disabled..."
    aws cloudfront wait distribution-deployed --id $DISTRIBUTION_ID
    
    # Get the new ETag after disabling
    NEW_ETAG=$(aws cloudfront get-distribution --id $DISTRIBUTION_ID --query 'ETag' --output text)
    
    # Delete the distribution
    echo "🗑️ Deleting CloudFront distribution..."
    aws cloudfront delete-distribution --id $DISTRIBUTION_ID --if-match $NEW_ETAG
    
    echo "✅ CloudFront distribution deleted successfully"
else
    echo "⚠️ CloudFront distribution not found or already deleted"
fi

# 2. Clean up S3 Bucket
echo "🗑️ Step 2: Cleaning up S3 bucket..."

if aws s3 ls "s3://$WIDGET_BUCKET" 2>/dev/null; then
    echo "📦 Found S3 bucket: $WIDGET_BUCKET"
    
    # Remove all objects
    echo "🗑️ Removing all objects from bucket..."
    aws s3 rm s3://$WIDGET_BUCKET --recursive
    
    # Remove website configuration
    echo "🌐 Removing website configuration..."
    aws s3api delete-bucket-website --bucket $WIDGET_BUCKET 2>/dev/null || echo "⚠️ No website configuration found"
    
    # Delete bucket
    echo "🗑️ Deleting S3 bucket..."
    aws s3 rb s3://$WIDGET_BUCKET
    
    echo "✅ S3 bucket deleted successfully"
else
    echo "⚠️ S3 bucket not found or already deleted"
fi

# 3. Clean up any Elastic Beanstalk resources (if any exist)
echo "🗑️ Step 3: Checking for Elastic Beanstalk resources..."

cd api

# Check if EB is initialized
if [ -d ".elasticbeanstalk" ]; then
    echo "🏗️ Found Elastic Beanstalk configuration"
    
    # Terminate environment
    echo "🛑 Terminating Elastic Beanstalk environment..."
    eb terminate production --force 2>/dev/null || echo "⚠️ Environment may not exist or already terminated"
    
    echo "✅ Elastic Beanstalk environment terminated"
else
    echo "⚠️ No Elastic Beanstalk configuration found"
fi

# 4. Clean up any CloudFormation stacks (if created by EB)
echo "🗑️ Step 4: Checking for CloudFormation stacks..."

STACKS=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[?contains(StackName, '$APP_NAME')].StackName" --output text 2>/dev/null || echo "")

if [ ! -z "$STACKS" ]; then
    echo "🏗️ Found CloudFormation stacks: $STACKS"
    for stack in $STACKS; do
        echo "🗑️ Deleting stack: $stack"
        aws cloudformation delete-stack --stack-name $stack
    done
    echo "✅ CloudFormation stacks deletion initiated"
else
    echo "⚠️ No related CloudFormation stacks found"
fi

echo "🎉 Cleanup of AWS Mumbai region completed!"
echo ""
echo "📋 Cleanup Summary:"
echo "==================="
echo "🌍 Region: $AWS_REGION (Mumbai)"
echo "🗑️ CloudFront Distribution: $DISTRIBUTION_ID (deleted)"
echo "🗑️ S3 Bucket: $WIDGET_BUCKET (deleted)"
echo "🗑️ EB Environment: production (terminated)"
echo "🗑️ CloudFormation Stacks: deletion initiated"
echo ""
echo "✅ Your AWS Mumbai region resources have been cleaned up!"
echo "🚀 Ready for a fresh deployment!"

