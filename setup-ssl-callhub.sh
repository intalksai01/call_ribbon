#!/bin/bash

# Setup SSL certificate for callhub.intalksai.com and update CloudFront
# This enables custom domain with HTTPS

set -e

DOMAIN="callhub.intalksai.com"
DISTRIBUTION_ID="E23RHJVEDGE3B2"
CLOUDFRONT_DOMAIN="d2t5fsybshqnye.cloudfront.net"

echo "🔒 Setting up SSL for $DOMAIN"
echo "================================"
echo ""

# Step 1: Request SSL Certificate in us-east-1 (required for CloudFront)
echo "📋 Step 1: Requesting SSL certificate..."
echo "   Region: us-east-1 (required for CloudFront)"
echo ""

CERT_ARN=$(aws acm request-certificate \
    --domain-name "$DOMAIN" \
    --validation-method DNS \
    --region us-east-1 \
    --output json | jq -r '.CertificateArn')

echo "✅ Certificate requested!"
echo "   Certificate ARN: $CERT_ARN"
echo ""

# Step 2: Get DNS validation records
echo "📋 Step 2: Getting DNS validation records..."
sleep 5  # Wait for AWS to process

VALIDATION_INFO=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region us-east-1 \
    --output json | jq '.Certificate.DomainValidationOptions[0].ResourceRecord')

VALIDATION_NAME=$(echo "$VALIDATION_INFO" | jq -r '.Name')
VALIDATION_VALUE=$(echo "$VALIDATION_INFO" | jq -r '.Value')

echo ""
echo "========================================="
echo "🎯 ACTION REQUIRED: Add DNS Record"
echo "========================================="
echo ""
echo "Go to Hostinger DNS and add this CNAME record:"
echo ""
echo "Type: CNAME"
echo "Name: ${VALIDATION_NAME%.intalksai.com.}"
echo "Value: $VALIDATION_VALUE"
echo "TTL: 3600"
echo ""
echo "⚠️  Important: Copy these values exactly!"
echo ""

# Save configuration
cat > callhub-ssl-setup.txt <<EOF
SSL Certificate Setup for callhub.intalksai.com
================================================

Date: $(date)
Domain: $DOMAIN
Certificate ARN: $CERT_ARN
CloudFront Distribution: $DISTRIBUTION_ID

STEP 1: Add DNS Validation Record in Hostinger
-----------------------------------------------
Go to Hostinger → DNS Settings for intalksai.com

Add NEW CNAME record:
Type: CNAME
Name: ${VALIDATION_NAME%.intalksai.com.}
Value: $VALIDATION_VALUE
TTL: 3600

STEP 2: Wait for Validation (5-30 minutes)
------------------------------------------
Check status:
aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1 | jq '.Certificate.Status'

When Status changes from "PENDING_VALIDATION" to "ISSUED", proceed to Step 3.

STEP 3: Update CloudFront Distribution
---------------------------------------
Run this script again with the --update flag:
./setup-ssl-callhub.sh --update

Or manually update CloudFront to use the certificate.

STEP 4: Test Your Domain
-------------------------
After CloudFront update (takes 15-20 minutes):
curl -I https://callhub.intalksai.com

Should return: HTTP/2 200

Current DNS Configuration:
--------------------------
CNAME for callhub:
Type: CNAME
Name: callhub
Value: $CLOUDFRONT_DOMAIN
TTL: 3600

DNS Validation Record (ADD THIS):
Type: CNAME  
Name: ${VALIDATION_NAME%.intalksai.com.}
Value: $VALIDATION_VALUE
TTL: 3600
EOF

echo "💾 Configuration saved to: callhub-ssl-setup.txt"
echo ""
echo "⏳ Next Steps:"
echo "   1. Add the DNS validation record in Hostinger"
echo "   2. Wait 5-30 minutes for validation"
echo "   3. Check certificate status:"
echo "      aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1 | jq '.Certificate.Status'"
echo "   4. When ISSUED, run: ./setup-ssl-callhub.sh --update"
echo ""
echo "✨ SSL setup initiated!"

