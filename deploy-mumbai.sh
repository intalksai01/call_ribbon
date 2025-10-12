#!/bin/bash

# Deploy IntalksAI Call Ribbon Widget to AWS Mumbai (ap-south-1)
# This script creates S3 bucket and deploys the widget

set -e

REGION="ap-south-1"
TIMESTAMP=$(date +%s)
BUCKET_NAME="intalksai-call-ribbon-widget-mumbai-${TIMESTAMP}"

echo "🚀 Deploying to AWS Mumbai (ap-south-1)"
echo "========================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first."
    exit 1
fi

# Check AWS credentials
echo "✅ Checking AWS credentials..."
aws sts get-caller-identity --region $REGION > /dev/null 2>&1 || {
    echo "❌ AWS credentials not configured"
    exit 1
}

# Create S3 bucket in Mumbai region
echo ""
echo "📦 Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION

echo "✅ Bucket created successfully"

# Disable Block Public Access settings
echo ""
echo "🔓 Configuring bucket public access..."
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

echo "✅ Public access configured"

# Enable static website hosting
echo ""
echo "🌐 Enabling static website hosting..."
aws s3 website s3://$BUCKET_NAME/ \
    --region $REGION \
    --index-document index.html \
    --error-document index.html

echo "✅ Static website hosting enabled"

# Set bucket policy for public read
echo ""
echo "📝 Setting bucket policy..."
cat > /tmp/bucket-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${BUCKET_NAME}/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --policy file:///tmp/bucket-policy.json

echo "✅ Bucket policy set"

# Upload widget files
echo ""
echo "📤 Uploading widget files..."
cd widget/build

# Upload all files with proper content types
aws s3 sync . s3://$BUCKET_NAME/ \
    --region $REGION \
    --delete \
    --cache-control "max-age=31536000" \
    --exclude "*.html" \
    --exclude "*.json"

# Upload HTML files with no-cache
aws s3 sync . s3://$BUCKET_NAME/ \
    --region $REGION \
    --exclude "*" \
    --include "*.html" \
    --cache-control "no-cache" \
    --content-type "text/html"

# Upload JSON files
aws s3 sync . s3://$BUCKET_NAME/ \
    --region $REGION \
    --exclude "*" \
    --include "*.json" \
    --cache-control "no-cache" \
    --content-type "application/json"

cd ../..

echo "✅ Files uploaded successfully"

# Get the website URL
WEBSITE_URL="http://${BUCKET_NAME}.s3-website.${REGION}.amazonaws.com"

echo ""
echo "========================================="
echo "✅ Deployment Complete!"
echo "========================================="
echo ""
echo "📍 Region: Mumbai (ap-south-1)"
echo "🪣 Bucket: $BUCKET_NAME"
echo "🌐 Website URL: $WEBSITE_URL"
echo ""
echo "🔗 Access your demo at:"
echo "   $WEBSITE_URL"
echo ""
echo "📝 Save this information:"
echo "   Bucket Name: $BUCKET_NAME"
echo "   Region: $REGION"
echo ""

# Save deployment info
cat > mumbai-deployment-info.txt <<EOF
IntalksAI Call Ribbon - Mumbai Deployment
=========================================

Deployment Date: $(date)
Region: Mumbai (ap-south-1)
Bucket Name: $BUCKET_NAME
Website URL: $WEBSITE_URL

API Configuration:
- API Key: demo-api-key-789
- Backend URL: http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com

Test Customers:
1. John Doe: +919876543210
2. Jane Smith: +918765432109
3. Bob Johnson: +917654321098
4. Alice Williams: +919988776655
5. Charlie Brown: +918877665544
6. Diana Prince: +917766554433

Features:
- Call controls (dial, mute, hold, DTMF)
- Drag and drop positioning
- Mobile responsive
- Event logging
- Demo mode active

To update deployment:
cd widget && npm run build && cd ..
aws s3 sync widget/build/ s3://$BUCKET_NAME/ --region $REGION --delete

To delete deployment:
aws s3 rb s3://$BUCKET_NAME --region $REGION --force
EOF

echo "💾 Deployment info saved to: mumbai-deployment-info.txt"
echo ""
echo "🎯 Next Steps:"
echo "   1. Open the website URL in your browser"
echo "   2. Click on a test customer"
echo "   3. Test the call controls"
echo "   4. Check browser console for logs"
echo ""
echo "✨ Done!"

