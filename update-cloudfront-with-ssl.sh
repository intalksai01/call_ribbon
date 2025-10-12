#!/bin/bash

# Update CloudFront distribution with SSL certificate for callhub.intalksai.com

set -e

DOMAIN="callhub.intalksai.com"
DISTRIBUTION_ID="E23RHJVEDGE3B2"
CERT_ARN="arn:aws:acm:us-east-1:844605843483:certificate/fa9fae7d-7fa0-4f6e-b06a-4d4e878047cd"

echo "🔄 Updating CloudFront with SSL Certificate"
echo "==========================================="
echo ""

# Check certificate status
echo "📋 Checking certificate status..."
CERT_STATUS=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region us-east-1 \
    --output json | jq -r '.Certificate.Status')

echo "   Certificate Status: $CERT_STATUS"
echo ""

if [ "$CERT_STATUS" != "ISSUED" ]; then
    echo "❌ Certificate not yet issued!"
    echo "   Current status: $CERT_STATUS"
    echo ""
    echo "Please wait for certificate validation to complete."
    echo "Check status with:"
    echo "   aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1 | jq '.Certificate.Status'"
    exit 1
fi

echo "✅ Certificate is ISSUED! Proceeding with CloudFront update..."
echo ""

# Get current distribution config
echo "📥 Fetching current CloudFront configuration..."
aws cloudfront get-distribution-config --id "$DISTRIBUTION_ID" > /tmp/cf-current.json
ETAG=$(cat /tmp/cf-current.json | jq -r '.ETag')
cat /tmp/cf-current.json | jq '.DistributionConfig' > /tmp/cf-config-current.json

echo "✅ Configuration fetched (ETag: $ETAG)"
echo ""

# Update configuration with SSL certificate and alias
echo "🔧 Updating configuration..."
cat /tmp/cf-config-current.json | jq --arg domain "$DOMAIN" --arg cert "$CERT_ARN" '
  .Aliases.Quantity = 1 |
  .Aliases.Items = [$domain] |
  .ViewerCertificate = {
    "ACMCertificateArn": $cert,
    "SSLSupportMethod": "sni-only",
    "MinimumProtocolVersion": "TLSv1.2_2021",
    "Certificate": $cert,
    "CertificateSource": "acm"
  }
' > /tmp/cf-config-updated.json

echo "✅ Configuration updated"
echo ""

# Apply the update
echo "🚀 Applying update to CloudFront..."
UPDATE_RESULT=$(aws cloudfront update-distribution \
    --id "$DISTRIBUTION_ID" \
    --if-match "$ETAG" \
    --distribution-config file:///tmp/cf-config-updated.json \
    --output json)

NEW_STATUS=$(echo "$UPDATE_RESULT" | jq -r '.Distribution.Status')

echo ""
echo "==========================================="
echo "✅ CloudFront Update Complete!"
echo "==========================================="
echo ""
echo "Distribution ID: $DISTRIBUTION_ID"
echo "Status: $NEW_STATUS"
echo "Custom Domain: $DOMAIN"
echo "Certificate: $CERT_ARN"
echo ""

# Save completion info
cat > callhub-deployment-complete.txt <<EOF
callhub.intalksai.com - Deployment Complete
============================================

Date: $(date)
Domain: $DOMAIN
CloudFront Distribution: $DISTRIBUTION_ID
Certificate ARN: $CERT_ARN
Status: $NEW_STATUS

Access URLs:
- HTTP:  http://callhub.intalksai.com
- HTTPS: https://callhub.intalksai.com

CloudFront is now deploying the changes.
This will take 15-20 minutes.

Check deployment status:
aws cloudfront get-distribution --id $DISTRIBUTION_ID | jq '.Distribution.Status'

When Status = "Deployed", test your domain:
curl -I https://callhub.intalksai.com

EOF

echo "💾 Deployment info saved to: callhub-deployment-complete.txt"
echo ""
echo "⏳ CloudFront is now deploying..."
echo "   This will take 15-20 minutes"
echo ""
echo "🔍 Check status:"
echo "   aws cloudfront get-distribution --id $DISTRIBUTION_ID | jq '.Distribution.Status'"
echo ""
echo "✅ When Status = 'Deployed', your domain will be live!"
echo ""
echo "🧪 Test URLs:"
echo "   http://callhub.intalksai.com"
echo "   https://callhub.intalksai.com"
echo ""
echo "✨ Done!"

