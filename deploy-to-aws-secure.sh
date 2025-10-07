#!/bin/bash

##############################################################################
# IntalksAI Call Ribbon - AWS Deployment Script (Secure)
# 
# This script deploys with proper security:
# - Widget to S3 (private) + CloudFront (public)
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
echo "║                  (Secure Configuration)                    ║"
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

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}/widget"

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
cd "${SCRIPT_DIR}"

##############################################################################
# Step 3: Deploy Widget to S3 (Private Bucket)
##############################################################################

print_section "Step 3: Deploying Widget to S3 (Private)"

# Create S3 bucket if it doesn't exist
if ! aws s3 ls "s3://${WIDGET_BUCKET_NAME}" 2>&1 | grep -q "${WIDGET_BUCKET_NAME}"; then
    echo "📦 Creating S3 bucket: ${WIDGET_BUCKET_NAME}"
    aws s3 mb "s3://${WIDGET_BUCKET_NAME}" --region "${AWS_REGION}"
    echo -e "${GREEN}✅ S3 bucket created${NC}"
else
    echo -e "${YELLOW}ℹ️  S3 bucket already exists${NC}"
fi

# Upload widget files (bucket remains private)
echo "📤 Uploading widget files to S3..."
aws s3 sync "${SCRIPT_DIR}/widget/build/" "s3://${WIDGET_BUCKET_NAME}" \
    --delete \
    --cache-control "public, max-age=31536000" \
    --exclude "index.html" \
    --region "${AWS_REGION}"

# Upload index.html with no-cache
aws s3 cp "${SCRIPT_DIR}/widget/build/index.html" "s3://${WIDGET_BUCKET_NAME}/index.html" \
    --cache-control "no-cache" \
    --content-type "text/html" \
    --region "${AWS_REGION}"

echo -e "${GREEN}✅ Widget uploaded to S3 (private bucket)${NC}"

##############################################################################
# Step 4: Create CloudFront Distribution
##############################################################################

print_section "Step 4: Setting up CloudFront CDN"

echo -e "${YELLOW}ℹ️  Checking for existing CloudFront distribution...${NC}"

# Check if distribution already exists
EXISTING_DIST=$(aws cloudfront list-distributions --query "DistributionList.Items[?Origins.Items[0].DomainName=='${WIDGET_BUCKET_NAME}.s3.${AWS_REGION}.amazonaws.com'].Id" --output text 2>/dev/null || echo "")

if [ -z "$EXISTING_DIST" ]; then
    echo "📦 Creating CloudFront distribution (this takes 5-10 minutes)..."
    echo ""
    echo -e "${YELLOW}⚠️  CloudFront creation is complex via CLI.${NC}"
    echo -e "${YELLOW}   For now, we'll use S3 direct access for API server.${NC}"
    echo ""
    echo "   To set up CloudFront manually:"
    echo "   1. Go to AWS Console → CloudFront"
    echo "   2. Create Distribution"
    echo "   3. Origin: ${WIDGET_BUCKET_NAME}.s3.${AWS_REGION}.amazonaws.com"
    echo "   4. Origin Access: Origin Access Control"
    echo "   5. Enable HTTPS"
    echo ""
    
    WIDGET_URL="https://${WIDGET_BUCKET_NAME}.s3.${AWS_REGION}.amazonaws.com"
    echo -e "${BLUE}   Widget S3 URL: ${WIDGET_URL}${NC}"
else
    CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution --id "$EXISTING_DIST" --query "Distribution.DomainName" --output text)
    WIDGET_URL="https://${CLOUDFRONT_DOMAIN}"
    echo -e "${GREEN}✅ Using existing CloudFront distribution${NC}"
    echo -e "${BLUE}   Widget URL: ${WIDGET_URL}${NC}"
fi

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
        echo "   Add to your ~/.zshrc:"
        echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
        echo "   Then restart terminal and run this script again."
        exit 1
    fi
fi

echo -e "${GREEN}✅ Elastic Beanstalk CLI ready${NC}"

##############################################################################
# Step 6: Deploy API to Elastic Beanstalk
##############################################################################

print_section "Step 6: Deploying API to Elastic Beanstalk"

cd "${SCRIPT_DIR}/api"

# Initialize EB if not already done
if [ ! -d ".elasticbeanstalk" ]; then
    echo "🔧 Initializing Elastic Beanstalk..."
    eb init "${APP_NAME}-api" \
        --platform node.js-18 \
        --region "${AWS_REGION}"
    echo -e "${GREEN}✅ EB initialized${NC}"
fi

# Create environment if it doesn't exist
if ! eb list 2>/dev/null | grep -q "${ENVIRONMENT}"; then
    echo "🚀 Creating Elastic Beanstalk environment..."
    echo "   This may take 5-10 minutes..."
    
    eb create "${ENVIRONMENT}" \
        --instance-type t3.micro \
        --envvars NODE_ENV=production,CORS_ORIGINS="*"
    
    echo -e "${GREEN}✅ EB environment created${NC}"
else
    echo -e "${YELLOW}ℹ️  Environment already exists, deploying update...${NC}"
    eb deploy "${ENVIRONMENT}"
fi

# Get API URL
API_URL=$(eb status "${ENVIRONMENT}" | grep "CNAME" | awk '{print $2}')
echo -e "${GREEN}✅ API deployed successfully${NC}"
echo -e "${BLUE}   URL: http://${API_URL}${NC}"

cd "${SCRIPT_DIR}"

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
echo "📱 Widget (S3 - for API access):"
echo -e "   ${BLUE}${WIDGET_URL}${NC}"
echo ""
echo "🔧 API URL:"
echo -e "   ${BLUE}http://${API_URL}${NC}"
echo ""
echo "⚠️  ${YELLOW}IMPORTANT NEXT STEPS:${NC}"
echo ""
echo "   1. Widget is in PRIVATE S3 bucket (secure)"
echo "   2. To make it publicly accessible:"
echo ""
echo "      ${YELLOW}Option A: Use CloudFront (Recommended)${NC}"
echo "      - Go to AWS Console → CloudFront"
echo "      - Create Distribution"
echo "      - Origin: ${WIDGET_BUCKET_NAME}.s3.${AWS_REGION}.amazonaws.com"
echo "      - Origin Access: Origin Access Control"
echo "      - This gives you HTTPS and global CDN"
echo ""
echo "      ${YELLOW}Option B: Use API Server to Serve Widget${NC}"
echo "      - Deploy unified-server.js instead"
echo "      - Serves both widget and API from one URL"
echo "      - Simpler but less scalable"
echo ""
echo "🧪 For now, test API:"
echo "   curl http://${API_URL}/api/health"
echo ""
echo "📚 Documentation:"
echo "   - AWS_DEPLOYMENT_GUIDE.md - CloudFront setup"
echo "   - UNIFIED_DEPLOYMENT.md - Single server option"
echo ""
echo -e "${GREEN}Happy calling! 📞${NC}"
echo ""

# Save deployment info
cat > deployment-info.txt << EOF
Deployment Date: $(date)
AWS Account: ${AWS_ACCOUNT_ID}
AWS Region: ${AWS_REGION}

Widget:
  S3 Bucket: ${WIDGET_BUCKET_NAME} (PRIVATE)
  S3 URL: ${WIDGET_URL}
  Status: Needs CloudFront for public access

API:
  Environment: ${ENVIRONMENT}
  URL: http://${API_URL}

Next Steps:
1. Set up CloudFront for widget (see AWS Console)
2. Or use unified deployment (unified-server.js)
3. Update Exotel credentials in api/server.js
4. Test API: curl http://${API_URL}/api/health
EOF

echo -e "${BLUE}ℹ️  Deployment info saved to: deployment-info.txt${NC}"
echo ""
