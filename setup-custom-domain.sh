#!/bin/bash

# Fix custom domain access for callribbon.intalksai.com
# S3 requires either bucket name match OR CloudFront

set -e

CUSTOM_DOMAIN="callribbon.intalksai.com"
BUCKET_NAME="intalksai-call-ribbon-widget-mumbai-1760280743"
REGION="ap-south-1"

echo "🔧 Fixing Custom Domain Access"
echo "================================"
echo ""
echo "Domain: $CUSTOM_DOMAIN"
echo "Bucket: $BUCKET_NAME"
echo ""

# Option 1: CloudFront (Recommended - Enables HTTPS)
echo "📋 Setting up CloudFront distribution..."
echo ""

# Create CloudFront origin config
ORIGIN_DOMAIN="${BUCKET_NAME}.s3-website.${REGION}.amazonaws.com"

# Create distribution
cat > /tmp/cloudfront-dist.json <<EOF
{
    "CallerReference": "callribbon-$(date +%s)",
    "Comment": "IntalksAI Call Ribbon - callribbon.intalksai.com",
    "Enabled": true,
    "DefaultRootObject": "index.html",
    "Aliases": {
        "Quantity": 0,
        "Items": []
    },
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3-Mumbai-Widget",
                "DomainName": "${ORIGIN_DOMAIN}",
                "CustomOriginConfig": {
                    "HTTPPort": 80,
                    "HTTPSPort": 443,
                    "OriginProtocolPolicy": "http-only",
                    "OriginSslProtocols": {
                        "Quantity": 3,
                        "Items": ["TLSv1", "TLSv1.1", "TLSv1.2"]
                    }
                }
            }
        ]
    },
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3-Mumbai-Widget",
        "ViewerProtocolPolicy": "allow-all",
        "AllowedMethods": {
            "Quantity": 2,
            "Items": ["GET", "HEAD"],
            "CachedMethods": {
                "Quantity": 2,
                "Items": ["GET", "HEAD"]
            }
        },
        "ForwardedValues": {
            "QueryString": true,
            "Cookies": {
                "Forward": "none"
            },
            "Headers": {
                "Quantity": 0
            }
        },
        "MinTTL": 0,
        "DefaultTTL": 86400,
        "MaxTTL": 31536000,
        "Compress": true,
        "TrustedSigners": {
            "Enabled": false,
            "Quantity": 0
        }
    },
    "ViewerCertificate": {
        "CloudFrontDefaultCertificate": true,
        "MinimumProtocolVersion": "TLSv1.2_2021"
    },
    "PriceClass": "PriceClass_All"
}
EOF

echo "Creating CloudFront distribution..."
DISTRIBUTION=$(aws cloudfront create-distribution \
    --distribution-config file:///tmp/cloudfront-dist.json \
    --output json)

DISTRIBUTION_ID=$(echo "$DISTRIBUTION" | jq -r '.Distribution.Id')
CLOUDFRONT_DOMAIN=$(echo "$DISTRIBUTION" | jq -r '.Distribution.DomainName')

echo ""
echo "✅ CloudFront distribution created!"
echo ""
echo "=========================================="
echo "📋 Your New Configuration"
echo "=========================================="
echo ""
echo "Distribution ID: $DISTRIBUTION_ID"
echo "CloudFront Domain: $CLOUDFRONT_DOMAIN"
echo ""
echo "🌐 Access URLs:"
echo "   HTTP:  http://$CLOUDFRONT_DOMAIN"
echo "   HTTPS: https://$CLOUDFRONT_DOMAIN"
echo ""
echo "⏳ Status: Deploying (15-20 minutes)"
echo ""

# Save configuration
cat > custom-domain-setup.txt <<EOF
Custom Domain Configuration
============================

Date: $(date)
Domain: $CUSTOM_DOMAIN
CloudFront Distribution: $DISTRIBUTION_ID
CloudFront Domain: $CLOUDFRONT_DOMAIN

Current Status: Deploying (wait 15-20 minutes)

Step 1: Wait for CloudFront Deployment
---------------------------------------
Check status:
aws cloudfront get-distribution --id $DISTRIBUTION_ID | jq '.Distribution.Status'

When Status = "Deployed", proceed to Step 2.

Step 2: Update Hostinger DNS
-----------------------------
Go to Hostinger DNS settings and UPDATE your CNAME record:

OLD (Not working):
Type: CNAME
Name: callribbon
Value: intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com

NEW (Will work):
Type: CNAME
Name: callribbon
Value: $CLOUDFRONT_DOMAIN
TTL: 3600

Step 3: Test
------------
After DNS update (wait 5-30 minutes):

Test HTTP:
curl -I http://callribbon.intalksai.com

Test via CloudFront directly:
curl -I http://$CLOUDFRONT_DOMAIN

Step 4: Enable HTTPS (Optional)
--------------------------------
To enable HTTPS for callribbon.intalksai.com:

1. Request SSL certificate in us-east-1:
   aws acm request-certificate \\
     --domain-name callribbon.intalksai.com \\
     --validation-method DNS \\
     --region us-east-1

2. Add validation CNAME to Hostinger DNS

3. Wait for certificate validation

4. Update CloudFront distribution with certificate

5. Access via: https://callribbon.intalksai.com

Invalidate Cache (if needed):
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
EOF

echo "💾 Configuration saved to: custom-domain-setup.txt"
echo ""
echo "🎯 Next Steps:"
echo ""
echo "1. ⏳ Wait 15-20 minutes for CloudFront deployment"
echo ""
echo "2. 🔍 Check deployment status:"
echo "   aws cloudfront get-distribution --id $DISTRIBUTION_ID | jq '.Distribution.Status'"
echo ""
echo "3. 📝 Update Hostinger DNS CNAME:"
echo "   Type: CNAME"
echo "   Name: callribbon"
echo "   Value: $CLOUDFRONT_DOMAIN"
echo "   (Replace the old S3 value)"
echo ""
echo "4. ⏱️  Wait 5-30 minutes for DNS propagation"
echo ""
echo "5. ✅ Test your domain:"
echo "   http://callribbon.intalksai.com"
echo ""
echo "✨ Done! Check custom-domain-setup.txt for detailed instructions."

