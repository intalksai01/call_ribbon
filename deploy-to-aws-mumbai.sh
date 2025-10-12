#!/bin/bash

# IntalksAI Call Ribbon - AWS Mumbai Deployment Script
# Deploys widget to S3 and API to Elastic Beanstalk in ap-south-1 (Mumbai)

set -e

# Configuration
AWS_REGION="ap-south-1"
WIDGET_BUCKET_NAME="intalksai-call-ribbon-widget-mumbai-$(date +%s)"
APP_NAME="intalksai-call-ribbon"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting deployment to AWS Mumbai (ap-south-1)..."

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

# 1. Deploy Widget to S3
echo "📦 Step 1: Building and deploying widget to S3..."

cd "$SCRIPT_DIR/widget"

# Build the widget
echo "🔨 Building React widget..."
npm run build

if [ ! -d "build" ]; then
    echo "❌ Build failed. No build directory found."
    exit 1
fi

# Create S3 bucket for widget
echo "🪣 Creating S3 bucket: $WIDGET_BUCKET_NAME"
aws s3 mb s3://$WIDGET_BUCKET_NAME --region $AWS_REGION

# Upload widget files
echo "📤 Uploading widget files to S3..."
aws s3 sync build/ s3://$WIDGET_BUCKET_NAME/ --cache-control "public, max-age=31536000" --delete

# Configure S3 bucket for static website hosting
echo "🌐 Configuring S3 for static website hosting..."
aws s3 website s3://$WIDGET_BUCKET_NAME/ --index-document index.html --error-document index.html

# Make bucket public
echo "🔓 Making S3 bucket public..."
aws s3api put-bucket-policy --bucket $WIDGET_BUCKET_NAME --policy "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
        {
            \"Sid\": \"PublicReadGetObject\",
            \"Effect\": \"Allow\",
            \"Principal\": \"*\",
            \"Action\": \"s3:GetObject\",
            \"Resource\": \"arn:aws:s3:::$WIDGET_BUCKET_NAME/*\"
        }
    ]
}"

WIDGET_URL="http://$WIDGET_BUCKET_NAME.s3-website-$AWS_REGION.amazonaws.com"
echo "✅ Widget deployed successfully!"
echo "🔗 Widget URL: $WIDGET_URL"

# 2. Deploy API to Elastic Beanstalk
echo "📡 Step 2: Deploying API to Elastic Beanstalk..."

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

# 3. Test deployments
echo "🧪 Step 3: Testing deployments..."

# Test API health
echo "🔍 Testing API health..."
if curl -s "$API_FULL_URL/health" | grep -q "healthy"; then
    echo "✅ API health check passed"
else
    echo "⚠️ API health check failed"
fi

# Test widget loading
echo "🔍 Testing widget loading..."
if curl -s "$WIDGET_URL" | grep -q "IntalksAI"; then
    echo "✅ Widget loading test passed"
else
    echo "⚠️ Widget loading test failed"
fi

# 4. Update widget configuration
echo "🔧 Step 4: Updating widget configuration..."

cd "$SCRIPT_DIR/widget/public"

# Update the API URL in index.html
sed -i.bak "s|http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com|$API_FULL_URL|g" index.html

# Rebuild and redeploy widget with updated API URL
cd "$SCRIPT_DIR/widget"
npm run build
aws s3 sync build/ s3://$WIDGET_BUCKET_NAME/ --cache-control "public, max-age=31536000" --delete

echo "🎉 Deployment to Mumbai completed successfully!"
echo ""
echo "📋 Deployment Summary:"
echo "====================="
echo "🌍 Region: $AWS_REGION (Mumbai)"
echo "🔗 Widget URL: $WIDGET_URL"
echo "🔗 API URL: $API_FULL_URL"
echo "🪣 S3 Bucket: $WIDGET_BUCKET_NAME"
echo "🏗️ EB Application: $APP_NAME-api"
echo "🏗️ EB Environment: production"
echo ""
echo "🧪 Test your deployment:"
echo "1. Visit: $WIDGET_URL"
echo "2. API Health: $API_FULL_URL/health"
echo "3. API Init: $API_FULL_URL/api/ribbon/init"
echo ""
echo "📝 Next Steps:"
echo "- Update your DNS/domain to point to the new URLs"
echo "- Update any client integrations with the new API URL"
echo "- Consider setting up CloudFront for better performance"

