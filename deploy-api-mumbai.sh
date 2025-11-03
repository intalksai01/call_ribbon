#!/bin/bash

# Deploy IntalksAI Call Ribbon API Backend to AWS Mumbai (ap-south-1)
# This script deploys the Node.js API server to Elastic Beanstalk in Mumbai

set -e

REGION="ap-south-1"
APP_NAME="intalksai-call-ribbon-api"
ENV_NAME="production-mumbai"
PLATFORM="node.js-20"

echo "🚀 Deploying API Backend to AWS Mumbai (ap-south-1)"
echo "===================================================="
echo ""

# Check if AWS CLI and EB CLI are installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first."
    exit 1
fi

if ! command -v eb &> /dev/null; then
    echo "❌ EB CLI not found. Please install it first."
    echo "   Run: pip install awsebcli"
    exit 1
fi

# Check AWS credentials
echo "✅ Checking AWS credentials..."
aws sts get-caller-identity --region $REGION > /dev/null 2>&1 || {
    echo "❌ AWS credentials not configured"
    exit 1
}

# Navigate to API directory
cd api

echo "✅ AWS credentials validated"
echo ""

# Initialize Elastic Beanstalk (if not already initialized)
if [ ! -d ".elasticbeanstalk" ]; then
    echo "📦 Initializing Elastic Beanstalk application..."
    eb init $APP_NAME \
        --region $REGION \
        --platform "$PLATFORM"
    echo "✅ EB application initialized"
else
    echo "✅ EB application already initialized"
fi

# Check if environment already exists
if eb list | grep -q "$ENV_NAME"; then
    echo ""
    echo "⚠️  Environment '$ENV_NAME' already exists"
    echo "   Updating existing environment..."
    echo ""
    
    # Deploy to existing environment
    eb deploy $ENV_NAME --region $REGION
else
    echo ""
    echo "🏗️  Creating new Elastic Beanstalk environment..."
    echo "   This may take 5-10 minutes..."
    echo ""
    
    # Create new environment
    eb create $ENV_NAME \
        --region $REGION \
        --instance-type t3.micro \
        --envvars NODE_ENV=production,CORS_ORIGINS="*"
fi

echo ""
echo "✅ Deployment initiated"
echo ""

# Wait for environment to be ready
echo "⏳ Waiting for environment to be ready..."
eb status $ENV_NAME --region $REGION

# Get the environment URL
ENV_URL=$(eb status $ENV_NAME --region $REGION | grep "CNAME" | awk '{print $2}')

if [ -z "$ENV_URL" ]; then
    echo "⚠️  Could not retrieve environment URL automatically"
    echo "   Run: eb status $ENV_NAME"
else
    API_URL="http://$ENV_URL"
    
    echo ""
    echo "===================================================="
    echo "✅ API Backend Deployment Complete!"
    echo "===================================================="
    echo ""
    echo "📍 Region: Mumbai (ap-south-1)"
    echo "🏢 Application: $APP_NAME"
    echo "🌍 Environment: $ENV_NAME"
    echo "🔗 API URL: $API_URL"
    echo ""
    echo "🧪 Testing endpoints:"
    echo "   Health: $API_URL/health"
    echo "   Init: $API_URL/api/ribbon/init"
    echo ""
    
    # Test health endpoint
    echo "🏥 Testing health endpoint..."
    if curl -f -s "$API_URL/health" > /dev/null 2>&1; then
        echo "✅ Health endpoint responding"
        curl -s "$API_URL/health" | jq . 2>/dev/null || curl -s "$API_URL/health"
    else
        echo "⚠️  Health endpoint not responding yet (may take a few more minutes)"
    fi
fi

cd ..

# Save deployment info
cat > mumbai-api-deployment-info.txt <<EOF
IntalksAI Call Ribbon API - Mumbai Deployment
==============================================

Deployment Date: $(date)
Region: Mumbai (ap-south-1)
Application Name: $APP_NAME
Environment Name: $ENV_NAME
API URL: $API_URL

Endpoints:
- POST $API_URL/api/ribbon/init
- POST $API_URL/api/ribbon/log-call
- GET  $API_URL/api/ribbon/config
- GET  $API_URL/api/ribbon/analytics
- GET  $API_URL/health

Environment Variables:
- NODE_ENV=production
- CORS_ORIGINS=*

Available API Keys:
1. demo-api-key-789 (Demo/Testing - All domains)
2. collections-crm-api-key-123 (Enterprise)
3. marketing-leads-api-key-456 (Professional)

Management Commands:
- View logs: eb logs $ENV_NAME --region $REGION
- Check status: eb status $ENV_NAME --region $REGION
- SSH access: eb ssh $ENV_NAME --region $REGION
- Update app: eb deploy $ENV_NAME --region $REGION
- Terminate: eb terminate $ENV_NAME --region $REGION

Next Steps:
1. Update Mumbai frontend to use: $API_URL
2. Test all API endpoints
3. Update documentation with new API URL
EOF

echo ""
echo "💾 Deployment info saved to: mumbai-api-deployment-info.txt"
echo ""
echo "🎯 Next Steps:"
echo "   1. Test the API health endpoint"
echo "   2. Update Mumbai frontend to use Mumbai API"
echo "   3. Test the demo with local API"
echo ""
echo "📝 To update the frontend:"
echo "   Edit widget/public/index.html"
echo "   Change apiUrl to: $API_URL"
echo "   Rebuild and redeploy widget"
echo ""
echo "✨ Done!"

