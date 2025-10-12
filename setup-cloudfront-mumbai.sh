#!/bin/bash

# Setup CloudFront distribution for Mumbai S3 bucket with custom domain
# This enables HTTPS and provides a stable DNS endpoint

set -e

REGION="ap-south-1"
BUCKET_NAME="intalksai-call-ribbon-widget-mumbai-1760280743"
CUSTOM_DOMAIN="callribbon.yourdomain.com"  # Update with your domain

echo "🌐 Setting up CloudFront for HTTPS access"
echo "=========================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found"
    exit 1
fi

echo "📋 Configuration:"
echo "   Bucket: $BUCKET_NAME"
echo "   Region: $REGION"
echo "   Custom Domain: $CUSTOM_DOMAIN (update if needed)"
echo ""

# Create CloudFront distribution
echo "🚀 Creating CloudFront distribution..."
echo "   This may take 15-20 minutes to deploy..."
echo ""

# Create distribution config
cat > /tmp/cloudfront-config.json <<EOF
{
    "CallerReference": "$(date +%s)",
    "Comment": "IntalksAI Call Ribbon - Mumbai",
    "Enabled": true,
    "DefaultRootObject": "index.html",
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3-${BUCKET_NAME}",
                "DomainName": "${BUCKET_NAME}.s3-website.${REGION}.amazonaws.com",
                "CustomOriginConfig": {
                    "HTTPPort": 80,
                    "HTTPSPort": 443,
                    "OriginProtocolPolicy": "http-only"
                }
            }
        ]
    },
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3-${BUCKET_NAME}",
        "ViewerProtocolPolicy": "redirect-to-https",
        "AllowedMethods": {
            "Quantity": 2,
            "Items": ["GET", "HEAD"]
        },
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {
                "Forward": "none"
            }
        },
        "MinTTL": 0,
        "DefaultTTL": 86400,
        "MaxTTL": 31536000,
        "Compress": true
    },
    "ViewerCertificate": {
        "CloudFrontDefaultCertificate": true,
        "MinimumProtocolVersion": "TLSv1.2_2021"
    }
}
EOF

echo "Creating distribution..."
DISTRIBUTION_OUTPUT=$(aws cloudfront create-distribution \
    --distribution-config file:///tmp/cloudfront-config.json \
    --output json)

DISTRIBUTION_ID=$(echo $DISTRIBUTION_OUTPUT | jq -r '.Distribution.Id')
DISTRIBUTION_DOMAIN=$(echo $DISTRIBUTION_OUTPUT | jq -r '.Distribution.DomainName')

echo ""
echo "✅ CloudFront distribution created!"
echo ""
echo "=========================================="
echo "📋 Distribution Details"
echo "=========================================="
echo ""
echo "Distribution ID: $DISTRIBUTION_ID"
echo "CloudFront Domain: $DISTRIBUTION_DOMAIN"
echo ""
echo "🌐 Access URLs:"
echo "   HTTP:  http://$DISTRIBUTION_DOMAIN"
echo "   HTTPS: https://$DISTRIBUTION_DOMAIN"
echo ""

# Save distribution info
cat > cloudfront-mumbai-info.txt <<EOF
CloudFront Distribution - Mumbai S3
====================================

Created: $(date)
Distribution ID: $DISTRIBUTION_ID
CloudFront Domain: $DISTRIBUTION_DOMAIN

Access URLs:
- HTTP:  http://$DISTRIBUTION_DOMAIN
- HTTPS: https://$DISTRIBUTION_DOMAIN

Status: Deploying (15-20 minutes)

To check status:
aws cloudfront get-distribution --id $DISTRIBUTION_ID

To invalidate cache:
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"

DNS Configuration for Hostinger:
=================================

For custom domain: callribbon.yourdomain.com

Option 1: CNAME (Recommended)
------------------------------
Type: CNAME
Name: callribbon
Value: $DISTRIBUTION_DOMAIN
TTL: 3600

Option 2: ALIAS (if supported)
-------------------------------
Type: ALIAS
Name: callribbon
Value: $DISTRIBUTION_DOMAIN
TTL: 3600

Note: Wait for CloudFront deployment to complete before testing!
EOF

echo "💾 Info saved to: cloudfront-mumbai-info.txt"
echo ""
echo "⏳ CloudFront is now deploying..."
echo "   Status: In Progress (takes 15-20 minutes)"
echo ""
echo "🔍 Check status:"
echo "   aws cloudfront get-distribution --id $DISTRIBUTION_ID | jq '.Distribution.Status'"
echo ""
echo "📝 For Hostinger DNS Configuration:"
echo "=========================================="
echo ""
echo "Add CNAME record in Hostinger:"
echo ""
echo "   Type:  CNAME"
echo "   Name:  callribbon"
echo "   Value: $DISTRIBUTION_DOMAIN"
echo "   TTL:   3600"
echo ""
echo "After DNS propagation, your site will be available at:"
echo "   https://callribbon.yourdomain.com"
echo ""
echo "⚠️  Important:"
echo "   1. Wait for CloudFront deployment (15-20 min)"
echo "   2. Test CloudFront URL first"
echo "   3. Then configure DNS"
echo "   4. DNS propagation takes 5-60 minutes"
echo ""
echo "✨ Done!"

