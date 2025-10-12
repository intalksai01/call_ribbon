#!/bin/bash

# IntalksAI Call Ribbon - AWS East Region Cleanup Script
# Removes all resources from us-east-1 region

set -e

# Configuration
AWS_REGION="us-east-1"
OLD_WIDGET_BUCKET="intalksai-call-ribbon-widget-844605843483"
OLD_APP_NAME="intalksai-call-ribbon"

echo "🧹 Starting cleanup of AWS East region (us-east-1) resources..."

# Set AWS region
export AWS_DEFAULT_REGION=$AWS_REGION
echo "📍 Using AWS Region: $AWS_REGION"

# 1. Clean up S3 Bucket
echo "🗑️ Step 1: Cleaning up S3 bucket..."

if aws s3 ls "s3://$OLD_WIDGET_BUCKET" 2>/dev/null; then
    echo "📦 Found S3 bucket: $OLD_WIDGET_BUCKET"
    
    # Remove all objects
    echo "🗑️ Removing all objects from bucket..."
    aws s3 rm s3://$OLD_WIDGET_BUCKET --recursive
    
    # Remove bucket policy
    echo "🔓 Removing bucket policy..."
    aws s3api delete-bucket-policy --bucket $OLD_WIDGET_BUCKET 2>/dev/null || echo "⚠️ No bucket policy found"
    
    # Remove website configuration
    echo "🌐 Removing website configuration..."
    aws s3api delete-bucket-website --bucket $OLD_WIDGET_BUCKET 2>/dev/null || echo "⚠️ No website configuration found"
    
    # Delete bucket
    echo "🗑️ Deleting S3 bucket..."
    aws s3 rb s3://$OLD_WIDGET_BUCKET
    
    echo "✅ S3 bucket deleted successfully"
else
    echo "⚠️ S3 bucket not found or already deleted"
fi

# 2. Clean up Elastic Beanstalk
echo "🗑️ Step 2: Cleaning up Elastic Beanstalk..."

cd api

# Check if EB is initialized
if [ -d ".elasticbeanstalk" ]; then
    echo "🏗️ Found Elastic Beanstalk configuration"
    
    # Terminate environment
    echo "🛑 Terminating Elastic Beanstalk environment..."
    eb terminate production --force 2>/dev/null || echo "⚠️ Environment may not exist or already terminated"
    
    # Wait for termination
    echo "⏳ Waiting for environment termination..."
    sleep 30
    
    echo "✅ Elastic Beanstalk environment terminated"
else
    echo "⚠️ No Elastic Beanstalk configuration found"
fi

# 3. Clean up any CloudFormation stacks (if created by EB)
echo "🗑️ Step 3: Checking for CloudFormation stacks..."

STACKS=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[?contains(StackName, '$OLD_APP_NAME')].StackName" --output text 2>/dev/null || echo "")

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

# 4. Clean up any IAM roles (if created by EB)
echo "🗑️ Step 4: Checking for IAM roles..."

ROLES=$(aws iam list-roles --query "Roles[?contains(RoleName, '$OLD_APP_NAME')].RoleName" --output text 2>/dev/null || echo "")

if [ ! -z "$ROLES" ]; then
    echo "🔑 Found IAM roles: $ROLES"
    for role in $ROLES; do
        echo "🔍 Checking if role can be deleted: $role"
        # Note: We won't delete IAM roles as they might be used by other resources
        echo "⚠️ IAM role $role found but not deleted (may be used by other resources)"
    done
else
    echo "⚠️ No related IAM roles found"
fi

# 5. Clean up any Security Groups (if created by EB)
echo "🗑️ Step 5: Checking for Security Groups..."

SECURITY_GROUPS=$(aws ec2 describe-security-groups --query "SecurityGroups[?contains(GroupName, '$OLD_APP_NAME')].GroupId" --output text 2>/dev/null || echo "")

if [ ! -z "$SECURITY_GROUPS" ]; then
    echo "🔒 Found Security Groups: $SECURITY_GROUPS"
    for sg in $SECURITY_GROUPS; do
        echo "🔍 Checking if security group can be deleted: $sg"
        # Note: We won't delete security groups as they might be used by other resources
        echo "⚠️ Security Group $sg found but not deleted (may be used by other resources)"
    done
else
    echo "⚠️ No related Security Groups found"
fi

echo "🎉 Cleanup of AWS East region completed!"
echo ""
echo "📋 Cleanup Summary:"
echo "==================="
echo "🌍 Region: $AWS_REGION (US East)"
echo "🗑️ S3 Bucket: $OLD_WIDGET_BUCKET (deleted)"
echo "🗑️ EB Environment: production (terminated)"
echo "🗑️ CloudFormation Stacks: deletion initiated"
echo ""
echo "⚠️ Note: Some resources like IAM roles and Security Groups were not deleted"
echo "   as they might be used by other resources. Please review manually if needed."
echo ""
echo "✅ Your AWS East region resources have been cleaned up!"

