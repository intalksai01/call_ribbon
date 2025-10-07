#!/bin/bash

##############################################################################
# IntalksAI Call Ribbon - AWS Deployment Script
# 
# This script deploys:
# - Widget to S3 + CloudFront
# - API to Elastic Beanstalk
#
# Prerequisites:
# - AWS CLI configured
# - Node.js installed
##############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AWS_ACCOUNT_ID="844605843483"
AWS_REGION="${AWS_REGION:-us-east-1}"
WIDGET_BUCKET_NAME="intalksai-call-ribbon-widget-${AWS_ACCOUNT_ID}"
APP_NAME="intalksai-call-ribbon"
ENVIRONMENT="production"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║        🚀 IntalksAI Call Ribbon - AWS Deployment         ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}AWS Account:${NC} ${AWS_ACCOUNT_ID}"
echo -e "${BLUE}Region:${NC} ${AWS_REGION}"
echo -e "${BLUE}Widget Bucket:${NC} ${WIDGET_BUCKET_NAME}"
echo ""

# Function to print section headers
print_section() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

##############################################################################
# Step 1: Verify Prerequisites
##############################################################################

print_section "Step 1: Verifying Prerequisites"

if ! command_exists aws; then
    echo -e "${RED}❌ AWS CLI not found. Please install it first.${NC}"
    echo "   Install: brew install awscli"
    exit 1
fi
echo -e "${GREEN}✅ AWS CLI installed${NC}"

if ! command_exists node; then
    echo -e "${RED}❌ Node.js not found. Please install it first.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Node.js installed${NC}"

# Check AWS credentials
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    echo "   Run: aws configure"
    exit 1
fi
echo -e "${GREEN}✅ AWS credentials configured${NC}"

##############################################################################
# Step 2: Build Widget
##############################################################################

print_section "Step 2: Building Widget"

cd widget

if [ ! -d "node_modules" ]; then
    echo "📦 Installing widget dependencies..."
    npm install
fi

echo "🔨 Building widget..."
npm run build

if [ ! -d "build" ]; then
    echo -e "${RED}❌ Build failed - build directory not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Widget built successfully${NC}"
cd ..

##############################################################################
# Step 3: Deploy Widget to S3
##############################################################################

print_section "Step 3: Deploying Widget to S3"

# Create S3 bucket if it doesn't exist
if aws s3 ls "s3://${WIDGET_BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "📦 Creating S3 bucket: ${WIDGET_BUCKET_NAME}"
    aws s3 mb "s3://${WIDGET_BUCKET_NAME}" --region "${AWS_REGION}"
    
    # Enable static website hosting
    aws s3 website "s3://${WIDGET_BUCKET_NAME}" \
        --index-document index.html \
        --error-document index.html
    
    # Set bucket policy for public read
    cat > /tmp/bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${WIDGET_BUCKET_NAME}/*"
        }
    ]
}
EOF
    
    aws s3api put-bucket-policy \
        --bucket "${WIDGET_BUCKET_NAME}" \
        --policy file:///tmp/bucket-policy.json
    
    echo -e "${GREEN}✅ S3 bucket created${NC}"
else
    echo -e "${YELLOW}ℹ️  S3 bucket already exists${NC}"
fi

# Upload widget files
echo "📤 Uploading widget files to S3..."
aws s3 sync widget/build/ "s3://${WIDGET_BUCKET_NAME}" \
    --delete \
    --cache-control "public, max-age=31536000" \
    --exclude "index.html" \
    --region "${AWS_REGION}"

# Upload index.html with no-cache
aws s3 cp widget/build/index.html "s3://${WIDGET_BUCKET_NAME}/index.html" \
    --cache-control "no-cache" \
    --content-type "text/html" \
    --region "${AWS_REGION}"

WIDGET_URL="http://${WIDGET_BUCKET_NAME}.s3-website-${AWS_REGION}.amazonaws.com"
echo -e "${GREEN}✅ Widget deployed to S3${NC}"
echo -e "${BLUE}   URL: ${WIDGET_URL}${NC}"

##############################################################################
# Step 4: Create CloudFront Distribution (Optional but Recommended)
##############################################################################

print_section "Step 4: Setting up CloudFront CDN (Optional)"

echo -e "${YELLOW}ℹ️  CloudFront setup requires manual configuration via AWS Console${NC}"
echo "   Or run: aws cloudfront create-distribution (see AWS_DEPLOYMENT_GUIDE.md)"
echo ""
echo "   For now, you can use the S3 website URL: ${WIDGET_URL}"
echo ""
read -p "Press Enter to continue with API deployment..."

##############################################################################
# Step 5: Install Elastic Beanstalk CLI
##############################################################################

print_section "Step 5: Setting up Elastic Beanstalk CLI"

if ! command_exists eb; then
    echo "📦 Installing Elastic Beanstalk CLI..."
    if command_exists pip3; then
        pip3 install awsebcli --upgrade --user
    elif command_exists pip; then
        pip install awsebcli --upgrade --user
    else
        echo -e "${RED}❌ pip not found. Please install Python first.${NC}"
        exit 1
    fi
    
    # Add to PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    if ! command_exists eb; then
        echo -e "${YELLOW}⚠️  EB CLI installed but not in PATH${NC}"
        echo "   Add to your ~/.zshrc or ~/.bashrc:"
        echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
        read -p "Press Enter after adding to PATH and restarting terminal..."
    fi
fi

echo -e "${GREEN}✅ Elastic Beanstalk CLI ready${NC}"

##############################################################################
# Step 6: Deploy API to Elastic Beanstalk
##############################################################################

print_section "Step 6: Deploying API to Elastic Beanstalk"

cd api

# Initialize EB if not already done
if [ ! -d ".elasticbeanstalk" ]; then
    echo "🔧 Initializing Elastic Beanstalk..."
    eb init "${APP_NAME}-api" \
        --platform node.js-18 \
        --region "${AWS_REGION}"
    echo -e "${GREEN}✅ EB initialized${NC}"
fi

# Create environment if it doesn't exist
if ! eb list | grep -q "${ENVIRONMENT}"; then
    echo "🚀 Creating Elastic Beanstalk environment..."
    echo "   This may take 5-10 minutes..."
    
    eb create "${ENVIRONMENT}" \
        --instance-type t3.micro \
        --envvars NODE_ENV=production,CORS_ORIGINS="${WIDGET_URL}"
    
    echo -e "${GREEN}✅ EB environment created${NC}"
else
    echo -e "${YELLOW}ℹ️  Environment already exists, deploying update...${NC}"
    eb deploy "${ENVIRONMENT}"
fi

# Get API URL
API_URL=$(eb status "${ENVIRONMENT}" | grep "CNAME" | awk '{print $2}')
echo -e "${GREEN}✅ API deployed successfully${NC}"
echo -e "${BLUE}   URL: http://${API_URL}${NC}"

cd ..

##############################################################################
# Step 7: Update Widget Configuration
##############################################################################

print_section "Step 7: Updating Widget Configuration"

echo "📝 Updating widget to use production API URL..."

# Update widget-entry.js with production API URL
if [ -f "widget/src/widget-entry.js" ]; then
    sed -i.bak "s|const apiUrl = config.apiUrl.*|const apiUrl = config.apiUrl || 'http://${API_URL}';|" widget/src/widget-entry.js
    echo -e "${GREEN}✅ Widget configuration updated${NC}"
    
    # Rebuild and redeploy widget
    echo "🔨 Rebuilding widget with new API URL..."
    cd widget
    npm run build
    cd ..
    
    echo "📤 Re-uploading widget..."
    aws s3 sync widget/build/ "s3://${WIDGET_BUCKET_NAME}" \
        --delete \
        --cache-control "public, max-age=31536000" \
        --exclude "index.html" \
        --region "${AWS_REGION}"
    
    aws s3 cp widget/build/index.html "s3://${WIDGET_BUCKET_NAME}/index.html" \
        --cache-control "no-cache" \
        --content-type "text/html" \
        --region "${AWS_REGION}"
    
    echo -e "${GREEN}✅ Widget redeployed with updated configuration${NC}"
fi

##############################################################################
# Deployment Complete!
##############################################################################

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║        ✅ DEPLOYMENT SUCCESSFUL! 🎉                       ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Your IntalksAI Call Ribbon is now live!${NC}"
echo ""
echo "📱 Widget URL:"
echo -e "   ${BLUE}${WIDGET_URL}${NC}"
echo ""
echo "🔧 API URL:"
echo -e "   ${BLUE}http://${API_URL}${NC}"
echo ""
echo "🧪 Test your deployment:"
echo "   1. Open widget URL in browser"
echo "   2. Click on any customer card"
echo "   3. Try making a test call"
echo ""
echo "📋 Next Steps:"
echo "   1. Set up CloudFront for global CDN (see AWS_DEPLOYMENT_GUIDE.md)"
echo "   2. Configure custom domain (optional)"
echo "   3. Update Exotel credentials in api/server.js"
echo "   4. Share widget URL with your clients"
echo ""
echo "📚 Documentation:"
echo "   - AWS_DEPLOYMENT_GUIDE.md - Complete AWS guide"
echo "   - PRODUCTION_DEPLOYMENT_CHECKLIST.md - Production checklist"
echo "   - docs/CLIENT_GUIDE.md - Client integration guide"
echo ""
echo -e "${GREEN}Happy calling! 📞${NC}"
echo ""

# Save deployment info
cat > deployment-info.txt << EOF
Deployment Date: $(date)
AWS Account: ${AWS_ACCOUNT_ID}
AWS Region: ${AWS_REGION}

Widget:
  S3 Bucket: ${WIDGET_BUCKET_NAME}
  URL: ${WIDGET_URL}

API:
  Environment: ${ENVIRONMENT}
  URL: http://${API_URL}

Next Steps:
1. Test deployment at: ${WIDGET_URL}
2. Set up CloudFront (optional but recommended)
3. Configure custom domain (optional)
4. Update Exotel credentials
EOF

echo -e "${BLUE}ℹ️  Deployment info saved to: deployment-info.txt${NC}"
echo ""
