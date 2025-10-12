#!/bin/bash

# IntalksAI Call Ribbon - AWS Mumbai Secure Deployment Script
# Deploys widget to S3 (private) + CloudFront and API to Elastic Beanstalk in ap-south-1 (Mumbai)

set -e

# Configuration
AWS_REGION="ap-south-1"
WIDGET_BUCKET_NAME="intalksai-call-ribbon-widget-mumbai-$(date +%s)"
APP_NAME="intalksai-call-ribbon"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting secure deployment to AWS Mumbai (ap-south-1)..."

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

# Check EB CLI
if ! command -v eb &> /dev/null; then
    echo "❌ EB CLI not found. Please install EB CLI first."
    exit 1
fi

# Set AWS region
export AWS_DEFAULT_REGION=$AWS_REGION
echo "📍 Using AWS Region: $AWS_REGION"

# 1. Deploy Widget to S3 (Private)
echo "📦 Step 1: Building and deploying widget to private S3..."

cd "$SCRIPT_DIR/widget"

# Build the widget
echo "🔨 Building React widget..."
npm run build

if [ ! -d "build" ]; then
    echo "❌ Build failed. No build directory found."
    exit 1
fi

# Create S3 bucket for widget (private)
echo "🪣 Creating private S3 bucket: $WIDGET_BUCKET_NAME"
aws s3 mb s3://$WIDGET_BUCKET_NAME --region $AWS_REGION

# Upload widget files
echo "📤 Uploading widget files to private S3..."
aws s3 sync build/ s3://$WIDGET_BUCKET_NAME/ --cache-control "public, max-age=31536000" --delete

# Configure S3 bucket for static website hosting (still works with private bucket)
echo "🌐 Configuring S3 for static website hosting..."
aws s3 website s3://$WIDGET_BUCKET_NAME/ --index-document index.html --error-document index.html

echo "✅ Widget deployed to private S3 successfully!"

# 2. Create CloudFront Distribution
echo "☁️ Step 2: Creating CloudFront distribution..."

# Create CloudFront distribution
echo "🌐 Creating CloudFront distribution..."
DISTRIBUTION_OUTPUT=$(aws cloudfront create-distribution --distribution-config "{
    \"CallerReference\": \"intalksai-ribbon-$(date +%s)\",
    \"Comment\": \"IntalksAI Call Ribbon Widget Distribution\",
    \"DefaultRootObject\": \"index.html\",
    \"Origins\": {
        \"Quantity\": 1,
        \"Items\": [
            {
                \"Id\": \"S3-$WIDGET_BUCKET_NAME\",
                \"DomainName\": \"$WIDGET_BUCKET_NAME.s3-website-$AWS_REGION.amazonaws.com\",
                \"CustomOriginConfig\": {
                    \"HTTPPort\": 80,
                    \"HTTPSPort\": 443,
                    \"OriginProtocolPolicy\": \"http-only\"
                }
            }
        ]
    },
    \"DefaultCacheBehavior\": {
        \"TargetOriginId\": \"S3-$WIDGET_BUCKET_NAME\",
        \"ViewerProtocolPolicy\": \"redirect-to-https\",
        \"MinTTL\": 0,
        \"ForwardedValues\": {
            \"QueryString\": false,
            \"Cookies\": {
                \"Forward\": \"none\"
            }
        }
    },
    \"Enabled\": true,
    \"PriceClass\": \"PriceClass_100\"
}")

# Extract distribution ID and domain name
DISTRIBUTION_ID=$(echo $DISTRIBUTION_OUTPUT | jq -r '.Distribution.Id')
DISTRIBUTION_DOMAIN=$(echo $DISTRIBUTION_OUTPUT | jq -r '.Distribution.DomainName')

echo "✅ CloudFront distribution created!"
echo "🆔 Distribution ID: $DISTRIBUTION_ID"
echo "🌐 Distribution Domain: $DISTRIBUTION_DOMAIN"

# Wait for distribution to be deployed
echo "⏳ Waiting for CloudFront distribution to be deployed (this may take 10-15 minutes)..."
aws cloudfront wait distribution-deployed --id $DISTRIBUTION_ID

CLOUDFRONT_URL="https://$DISTRIBUTION_DOMAIN"
echo "✅ CloudFront distribution is ready!"
echo "🔗 CloudFront URL: $CLOUDFRONT_URL"

# 3. Deploy API to Elastic Beanstalk
echo "📡 Step 3: Deploying API to Elastic Beanstalk..."

cd "$SCRIPT_DIR/api"

# Initialize EB (if not already initialized)
if [ ! -d ".elasticbeanstalk" ]; then
    echo "🔧 Initializing Elastic Beanstalk..."
    eb init $APP_NAME-api --platform "Node.js 22 running on 64bit Amazon Linux 2023" --region $AWS_REGION
fi

# Create environment (if not exists)
echo "🏗️ Creating Elastic Beanstalk environment..."
eb create production --platform "Node.js 22 running on 64bit Amazon Linux 2023" --region $AWS_REGION || echo "⚠️ Environment may already exist"

# Deploy API
echo "🚀 Deploying API to Elastic Beanstalk..."
eb deploy

# Get API URL
API_URL=$(eb status | grep "CNAME" | awk '{print $2}')
if [ -z "$API_URL" ]; then
    echo "❌ Failed to get API URL"
    exit 1
fi

API_FULL_URL="http://$API_URL"
echo "✅ API deployed successfully!"
echo "🔗 API URL: $API_FULL_URL"

# 4. Update widget configuration with new API URL
echo "🔧 Step 4: Updating widget configuration..."

cd "$SCRIPT_DIR/widget/public"

# Update the API URL in index.html
sed -i.bak "s|http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com|$API_FULL_URL|g" index.html

# Rebuild and redeploy widget with updated API URL
cd "$SCRIPT_DIR/widget"
npm run build
aws s3 sync build/ s3://$WIDGET_BUCKET_NAME/ --cache-control "public, max-age=31536000" --delete

# Invalidate CloudFront cache to ensure updated content is served
echo "🔄 Invalidating CloudFront cache..."
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"

echo "✅ Widget updated with new API URL!"

# 5. Test deployments
echo "🧪 Step 5: Testing deployments..."

# Wait a moment for CloudFront to serve the updated content
echo "⏳ Waiting for CloudFront cache invalidation..."
sleep 30

# Test API health
echo "🔍 Testing API health..."
if curl -s "$API_FULL_URL/health" | grep -q "healthy"; then
    echo "✅ API health check passed"
else
    echo "⚠️ API health check failed"
fi

# Test widget loading
echo "🔍 Testing widget loading..."
if curl -s "$CLOUDFRONT_URL" | grep -q "IntalksAI"; then
    echo "✅ Widget loading test passed"
else
    echo "⚠️ Widget loading test failed"
fi

echo "🎉 Secure deployment to Mumbai completed successfully!"
echo ""
echo "📋 Deployment Summary:"
echo "====================="
echo "🌍 Region: $AWS_REGION (Mumbai)"
echo "🔗 Widget URL (CloudFront): $CLOUDFRONT_URL"
echo "🔗 API URL: $API_FULL_URL"
echo "🪣 S3 Bucket: $WIDGET_BUCKET_NAME (private)"
echo "☁️ CloudFront Distribution: $DISTRIBUTION_ID"
echo "🏗️ EB Application: $APP_NAME-api"
echo "🏗️ EB Environment: production"
echo ""
echo "🧪 Test your deployment:"
echo "1. Visit: $CLOUDFRONT_URL"
echo "2. API Health: $API_FULL_URL/health"
echo "3. API Init: $API_FULL_URL/api/ribbon/init"
echo ""
echo "📝 Next Steps:"
echo "- Update your DNS/domain to point to the CloudFront URL"
echo "- Update any client integrations with the new API URL"
echo "- CloudFront provides HTTPS and global CDN benefits"
echo ""
echo "🔒 Security Features:"
echo "- Private S3 bucket (no public access)"
echo "- CloudFront provides HTTPS and global CDN"
echo "- Secure API deployment on Elastic Beanstalk"

