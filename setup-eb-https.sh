#!/bin/bash

# Setup HTTPS for Elastic Beanstalk environment
# This configures an Application Load Balancer with SSL certificate

set -e

REGION="ap-south-1"
ENV_NAME="production-mumbai"
DOMAIN_NAME="api.intalksai.com"  # Your Hostinger domain for API
APP_NAME="intalksai-call-ribbon-api"

echo "🔒 Setting up HTTPS for Elastic Beanstalk"
echo "=========================================="
echo ""
echo "Environment: $ENV_NAME"
echo "Region: $REGION"
echo "Domain: $DOMAIN_NAME"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found"
    exit 1
fi

# Check if EB CLI is installed
if ! command -v eb &> /dev/null; then
    echo "❌ EB CLI not found. Install with: pip install awsebcli"
    exit 1
fi

echo "📋 Step 1: Request SSL Certificate in ACM"
echo "========================================="
echo ""

# Get certificate ARN (or request one if not exists)
CERT_ARN=$(aws acm list-certificates \
    --region $REGION \
    --query "CertificateSummaryList[?DomainName=='$DOMAIN_NAME'].CertificateArn" \
    --output text 2>/dev/null || echo "")

if [ -z "$CERT_ARN" ]; then
    echo "⚠️  No certificate found for $DOMAIN_NAME"
    echo ""
    echo "Requesting SSL certificate..."
    CERT_ARN=$(aws acm request-certificate \
        --domain-name "$DOMAIN_NAME" \
        --validation-method DNS \
        --region $REGION \
        --output text --query 'CertificateArn')
    
    echo "✅ Certificate requested: $CERT_ARN"
    echo ""
    echo "📝 Next steps:"
    echo "1. Get DNS validation records:"
    echo "   aws acm describe-certificate --certificate-arn $CERT_ARN --region $REGION"
    echo ""
    echo "2. Add DNS validation CNAME to your DNS provider"
    echo ""
    echo "3. Wait for certificate validation (usually 5-30 minutes)"
    echo ""
    echo "4. Re-run this script after validation completes"
    echo ""
    
    # Save certificate ARN
    echo "$CERT_ARN" > .eb-cert-arn.txt
    exit 0
else
    echo "✅ Certificate found: $CERT_ARN"
    
    # Check certificate status
    CERT_STATUS=$(aws acm describe-certificate \
        --certificate-arn "$CERT_ARN" \
        --region $REGION \
        --query 'Certificate.Status' \
        --output text)
    
    echo "   Status: $CERT_STATUS"
    echo ""
    
    if [ "$CERT_STATUS" != "ISSUED" ]; then
        echo "⚠️  Certificate not yet issued. Current status: $CERT_STATUS"
        echo "   Wait for validation to complete and re-run this script"
        exit 1
    fi
    
    echo "$CERT_ARN" > .eb-cert-arn.txt
fi

echo ""
echo "📋 Step 2: Check Load Balancer Configuration"
echo "============================================="
echo ""

cd api

# Check if environment has ALB
HAS_ALB=$(eb status $ENV_NAME --region $REGION | grep -i "environment type" | grep -i "load" || echo "no")

if [ "$HAS_ALB" = "no" ]; then
    echo "⚠️  Environment does not have an Application Load Balancer"
    echo ""
    echo "You need to upgrade to ALB-enabled environment:"
    echo ""
    echo "Option 1: Create new environment with ALB"
    echo "   eb create $ENV_NAME-alb --elb-type application"
    echo ""
    echo "Option 2: AWS Console"
    echo "   1. Go to Elastic Beanstalk Console"
    echo "   2. Select environment: $ENV_NAME"
    echo "   3. Configuration → Modify Load Balancer"
    echo "   4. Change to Application Load Balancer"
    echo ""
    exit 1
fi

echo "✅ Environment has Application Load Balancer"
echo ""

echo "📋 Step 3: Configure HTTPS Listener"
echo "====================================="
echo ""

# Create .ebextensions/01-https.config
mkdir -p .ebextensions

cat > .ebextensions/01-https.config <<EOF
option_settings:
  aws:elbv2:listener:443:
    Protocol: HTTPS
    SSLCertificateArns: $CERT_ARN
    DefaultProcess: default
  aws:elbv2:listener:default:
    DefaultProcess: default
    Protocol: HTTP

# Redirect HTTP to HTTPS
Resources:
  AWSEBAutoScalingGroup:
    Metadata:
      AWS::CloudFormation::Authentication:
        S3Auth:
          type: "s3"
          buckets: ["elasticbeanstalk-*"]
          roleName: "aws-elasticbeanstalk-ec2-role"
EOF

echo "✅ Created HTTPS configuration file: .ebextensions/01-https.config"
echo ""

echo "📋 Step 4: Deploy Configuration"
echo "================================="
echo ""

eb deploy $ENV_NAME --region $REGION

echo ""
echo "✅ Deployment complete!"
echo ""

echo "📋 Step 5: Test HTTPS Endpoint"
echo "==============================="
echo ""

# Get environment URL
ENV_URL=$(eb status $ENV_NAME --region $REGION | grep "CNAME" | awk '{print $2}')

if [ -n "$ENV_URL" ]; then
    echo "Testing HTTPS endpoint..."
    echo ""
    
    # Test HTTPS
    if curl -sf -I "https://$ENV_URL/api/health" > /dev/null; then
        echo "✅ HTTPS is working!"
        curl -s "https://$ENV_URL/api/health" | jq . || curl -s "https://$ENV_URL/api/health"
    else
        echo "⚠️  HTTPS not yet working. May take a few minutes to propagate"
    fi
    
    echo ""
    echo "🌐 Your endpoints:"
    echo "   HTTP:  http://$ENV_URL"
    echo "   HTTPS: https://$ENV_URL"
    echo ""
    
    # Save configuration
    cd ..
    cat > eb-https-setup.txt <<EOF
Elastic Beanstalk HTTPS Configuration
=====================================

Date: $(date)
Region: $REGION
Environment: $ENV_NAME
Application: $APP_NAME

Certificate ARN: $CERT_ARN
Status: ISSUED

Endpoints:
- HTTP:  http://$ENV_URL
- HTTPS: https://$ENV_URL

Configuration Files:
- .ebextensions/01-https.config (HTTPS listener on port 443)

Testing:
curl -k https://$ENV_URL/api/health

Next Steps (Optional):
1. Setup custom domain pointing to $ENV_URL
2. Update DNS A record for $DOMAIN_NAME
3. Request new certificate for $DOMAIN_NAME if needed

Invalidate Environment Cache (if needed):
cd api && eb deploy $ENV_NAME --region $REGION
EOF
    
    echo "💾 Configuration saved to: eb-https-setup.txt"
fi

cd ..

echo ""
echo "✨ HTTPS setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Update widget to use HTTPS API URL"
echo "2. Test end-to-end calling"
echo "3. Optional: Setup custom domain"
echo ""

