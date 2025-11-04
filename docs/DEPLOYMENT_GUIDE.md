# 🚀 Complete Deployment Guide - IntalksAI Call Ribbon

This comprehensive guide documents all steps for deploying the IntalksAI Call Ribbon to AWS, including certificate creation, HTTPS setup, and DNS configuration.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Overview](#overview)
3. [API Deployment](#api-deployment)
   - [Step 1: Request SSL Certificate for API](#step-1-request-ssl-certificate-for-api)
   - [Step 2: Validate Certificate via DNS](#step-2-validate-certificate-via-dns)
   - [Step 3: Deploy API to Elastic Beanstalk](#step-3-deploy-api-to-elastic-beanstalk)
   - [Step 4: Configure HTTPS on Load Balancer](#step-4-configure-https-on-load-balancer)
   - [Step 5: Configure DNS for API](#step-5-configure-dns-for-api)
4. [Widget Deployment](#widget-deployment)
   - [Step 1: Build Widget](#step-1-build-widget)
   - [Step 2: Deploy Widget to S3](#step-2-deploy-widget-to-s3)
   - [Step 3: Create CloudFront Distribution](#step-3-create-cloudfront-distribution)
   - [Step 4: Request SSL Certificate for Widget](#step-4-request-ssl-certificate-for-widget)
   - [Step 5: Configure CloudFront with Custom Domain](#step-5-configure-cloudfront-with-custom-domain)
   - [Step 6: Configure DNS for Widget](#step-6-configure-dns-for-widget)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)
7. [Quick Reference](#quick-reference)

---

## Prerequisites

### Required Tools

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install EB CLI
pip install awsebcli

# Install jq (JSON parser)
# macOS
brew install jq
# Ubuntu
sudo apt-get install jq
```

### AWS Account Requirements

- AWS account with appropriate permissions
- Domain name registered (e.g., `intalksai.com`)
- DNS managed by Hostinger (or another DNS provider)
- Access to create:
  - Elastic Beanstalk environments
  - S3 buckets
  - CloudFront distributions
  - ACM certificates
  - Route 53 records (if using Route 53)

### Domain Configuration

**API Domain:** `api.intalksai.com`  
**Widget Domain:** `callhub.intalksai.com`

---

## Overview

The deployment consists of two main components:

1. **API Backend** (Elastic Beanstalk)
   - Deployed in Mumbai region (ap-south-1)
   - Uses Application Load Balancer (ALB)
   - HTTPS via ACM certificate
   - Custom domain: `api.intalksai.com`

2. **Widget Frontend** (S3 + CloudFront)
   - S3 bucket in Mumbai (ap-south-1)
   - CloudFront distribution for CDN and HTTPS
   - HTTPS via ACM certificate (must be in us-east-1)
   - Custom domain: `callhub.intalksai.com`

---

## API Deployment

### Step 1: Request SSL Certificate for API

The API certificate must be requested in the **Mumbai region (ap-south-1)** where Elastic Beanstalk is deployed.

#### Option A: Using AWS CLI (Recommended)

```bash
# Request certificate
CERT_ARN=$(aws acm request-certificate \
    --domain-name api.intalksai.com \
    --validation-method DNS \
    --region ap-south-1 \
    --output text --query 'CertificateArn')

echo "Certificate ARN: $CERT_ARN"

# Save ARN for later use
echo "$CERT_ARN" > .eb-cert-arn.txt
```

#### Option B: Using Automated Script

```bash
chmod +x setup-eb-https.sh
./setup-eb-https.sh
```

The script will:
- Check if certificate already exists
- Request certificate if needed
- Display DNS validation records
- Save certificate ARN to `.eb-cert-arn.txt`

#### Get DNS Validation Records

After requesting the certificate, get the DNS validation CNAME:

```bash
CERT_ARN=$(cat .eb-cert-arn.txt)

aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region ap-south-1 \
    --query 'Certificate.DomainValidationOptions[0].ResourceRecord' \
    --output json
```

**Output example:**
```json
{
  "Name": "_f888ad30bf0a37205e7e0dcd0fb103d7.api.intalksai.com",
  "Type": "CNAME",
  "Value": "_xyz789.acm-validations.aws."
}
```

---

### Step 2: Validate Certificate via DNS

#### In Hostinger DNS

1. Login to [Hostinger Control Panel](https://hpanel.hostinger.com)
2. Navigate to **Domains** → Your Domain → **DNS / Name Servers**
3. Click **Manage DNS Records**
4. Add **CNAME Record**:
   - **Name:** `_f888ad30bf0a37205e7e0dcd0fb103d7.api`
     - ⚠️ **Important:** Only include the part before `.intalksai.com`
     - Full record name is `_f888ad30bf0a37205e7e0dcd0fb103d7.api.intalksai.com`
   - **Value:** `_xyz789.acm-validations.aws.`
     - ⚠️ **Important:** Include the trailing dot (`.`)
   - **TTL:** 3600 (or default)
5. Click **Save**

#### Verify Certificate Status

Wait 5-30 minutes for DNS propagation, then check:

```bash
CERT_ARN=$(cat .eb-cert-arn.txt)

aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region ap-south-1 \
    --query 'Certificate.Status' \
    --output text
```

Status should change from `PENDING_VALIDATION` to `ISSUED`.

**Monitor status:**
```bash
# Watch certificate status
watch -n 30 'aws acm describe-certificate --certificate-arn $(cat .eb-cert-arn.txt) --region ap-south-1 --query "Certificate.Status" --output text'
```

---

### Step 3: Deploy API to Elastic Beanstalk

#### Check Prerequisites

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Verify EB CLI
eb --version
```

#### Deploy Using Script

```bash
chmod +x deploy-api-mumbai.sh
./deploy-api-mumbai.sh
```

#### Manual Deployment

```bash
cd api

# Initialize Elastic Beanstalk (first time only)
eb init intalksai-call-ribbon-api \
    --region ap-south-1 \
    --platform "node.js-22"

# Create or update environment
# If creating new environment with ALB:
eb create production-mumbai \
    --region ap-south-1 \
    --instance-type t3.micro \
    --elb-type application \
    --envvars NODE_ENV=production

# If environment exists, just deploy:
eb deploy production-mumbai --region ap-south-1

# Get environment URL
eb status production-mumbai --region ap-south-1 | grep CNAME
```

**Expected Output:**
```
CNAME: production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
```

**Important:** Ensure the environment uses **Application Load Balancer (ALB)**, not Single Instance.

---

### Step 4: Configure HTTPS on Load Balancer

#### Verify Certificate is Issued

```bash
CERT_ARN=$(cat .eb-cert-arn.txt)

aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region ap-south-1 \
    --query 'Certificate.Status' \
    --output text
# Must show: ISSUED
```

#### Create HTTPS Configuration

```bash
cd api
mkdir -p .ebextensions

CERT_ARN=$(cat ../.eb-cert-arn.txt)

cat > .ebextensions/01-https.config <<EOF
option_settings:
  aws:elbv2:listener:443:
    Protocol: HTTPS
    SSLCertificateArns: $CERT_ARN
    DefaultProcess: default
  aws:elbv2:listener:default:
    DefaultProcess: default
    Protocol: HTTP
EOF
```

#### Deploy HTTPS Configuration

```bash
eb deploy production-mumbai --region ap-south-1
```

This may take 5-10 minutes.

#### Add Security Group Rule for HTTPS

Find the ALB security group:

```bash
# Get environment details
ENV_NAME="production-mumbai"
REGION="ap-south-1"

# Find ALB security group
aws elasticbeanstalk describe-environment-resources \
    --environment-name "$ENV_NAME" \
    --region "$REGION" \
    --query 'EnvironmentResources.LoadBalancers[0].Name' \
    --output text
```

Then add HTTPS rule:

```bash
# Get ALB ARN
ALB_ARN=$(aws elasticbeanstalk describe-environment-resources \
    --environment-name "$ENV_NAME" \
    --region "$REGION" \
    --query 'EnvironmentResources.LoadBalancers[0].Name' \
    --output text)

# Get security group ID
SG_ID=$(aws elbv2 describe-load-balancers \
    --load-balancer-arns "$ALB_ARN" \
    --region "$REGION" \
    --query 'LoadBalancers[0].SecurityGroups[0]' \
    --output text)

# Add HTTPS rule
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 \
    --region "$REGION"
```

#### Test HTTPS Endpoint

```bash
ENV_URL="production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com"

# Test HTTPS
curl -I https://$ENV_URL/api/health

# Should return: HTTP/2 200
```

---

### Step 5: Configure DNS for API

#### In Hostinger DNS

1. Login to [Hostinger Control Panel](https://hpanel.hostinger.com)
2. Navigate to **Domains** → Your Domain → **DNS / Name Servers**
3. Click **Manage DNS Records**
4. Add **CNAME Record**:
   - **Type:** CNAME
   - **Name:** `api`
   - **Value:** `production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com`
     - Replace with your actual Beanstalk CNAME
   - **TTL:** 3600 (or default)
5. Click **Save**

#### Wait for DNS Propagation

DNS changes can take 5-30 minutes to propagate globally.

#### Verify DNS

```bash
# Check DNS resolution
dig api.intalksai.com +short

# Should resolve to your ALB's IP address

# Test HTTPS endpoint
curl -I https://api.intalksai.com/api/health

# Should return: HTTP/2 200
```

---

## Widget Deployment

### Step 1: Build Widget

```bash
cd widget

# Install dependencies (if not already done)
npm install

# Build for production
npm run build

cd ..
```

This creates the production build in `widget/build/`.

---

### Step 2: Deploy Widget to S3

#### Create S3 Bucket (First Time Only)

```bash
REGION="ap-south-1"
BUCKET_NAME="intalksai-call-ribbon-widget-mumbai-$(date +%s)"

# Create bucket
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Enable static website hosting
aws s3 website s3://$BUCKET_NAME \
    --index-document index.html \
    --error-document index.html

# Set bucket policy for public read access
cat > /tmp/bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy file:///tmp/bucket-policy.json

echo "Bucket: $BUCKET_NAME"
echo "Website URL: http://$BUCKET_NAME.s3-website.$REGION.amazonaws.com"
```

Save the bucket name for later steps.

#### Upload Widget Files

```bash
BUCKET_NAME="intalksai-call-ribbon-widget-mumbai-1760280743"  # Your bucket name
REGION="ap-south-1"

# Sync widget build to S3
aws s3 sync widget/build/ s3://$BUCKET_NAME/ \
    --region $REGION \
    --delete \
    --cache-control "public, max-age=31536000"

# Verify upload
aws s3 ls s3://$BUCKET_NAME/ --recursive
```

---

### Step 3: Create CloudFront Distribution

#### Create Distribution

```bash
BUCKET_NAME="intalksai-call-ribbon-widget-mumbai-1760280743"
REGION="ap-south-1"

# Create distribution config
cat > /tmp/cloudfront-config.json <<EOF
{
    "CallerReference": "$(date +%s)",
    "Comment": "IntalksAI Call Ribbon Widget",
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

# Create distribution
aws cloudfront create-distribution \
    --distribution-config file:///tmp/cloudfront-config.json \
    --output json > /tmp/cloudfront-output.json

DISTRIBUTION_ID=$(cat /tmp/cloudfront-output.json | jq -r '.Distribution.Id')
DOMAIN_NAME=$(cat /tmp/cloudfront-output.json | jq -r '.Distribution.DomainName')

echo "Distribution ID: $DISTRIBUTION_ID"
echo "CloudFront Domain: $DOMAIN_NAME"
echo "$DISTRIBUTION_ID" > .cloudfront-distribution-id.txt
```

**Important:** CloudFront distributions take 15-20 minutes to deploy.

---

### Step 4: Request SSL Certificate for Widget

**⚠️ Critical:** CloudFront requires certificates to be in **us-east-1** (N. Virginia) region, regardless of where your S3 bucket is located.

#### Request Certificate

```bash
DOMAIN="callhub.intalksai.com"

# Request certificate in us-east-1 (required for CloudFront)
CERT_ARN=$(aws acm request-certificate \
    --domain-name "$DOMAIN" \
    --validation-method DNS \
    --region us-east-1 \
    --output text --query 'CertificateArn')

echo "Certificate ARN: $CERT_ARN"
echo "$CERT_ARN" > .cloudfront-cert-arn.txt
```

#### Get DNS Validation Records

```bash
CERT_ARN=$(cat .cloudfront-cert-arn.txt)

aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region us-east-1 \
    --query 'Certificate.DomainValidationOptions[0].ResourceRecord' \
    --output json
```

#### Add DNS Validation to Hostinger

1. Login to Hostinger
2. Add CNAME record:
   - **Name:** `_abc123def456.callhub`
     - Only the part before `.intalksai.com`
   - **Value:** `_xyz789.acm-validations.aws.`
     - Include trailing dot
   - **TTL:** 3600
3. Wait for validation (5-30 minutes)

#### Verify Certificate Status

```bash
CERT_ARN=$(cat .cloudfront-cert-arn.txt)

aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region us-east-1 \
    --query 'Certificate.Status' \
    --output text
# Should show: ISSUED
```

---

### Step 5: Configure CloudFront with Custom Domain

#### Update CloudFront Distribution

```bash
DOMAIN="callhub.intalksai.com"
DISTRIBUTION_ID=$(cat .cloudfront-distribution-id.txt)
CERT_ARN=$(cat .cloudfront-cert-arn.txt)

# Verify certificate is issued
CERT_STATUS=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region us-east-1 \
    --query 'Certificate.Status' \
    --output text)

if [ "$CERT_STATUS" != "ISSUED" ]; then
    echo "❌ Certificate not yet issued! Current status: $CERT_STATUS"
    exit 1
fi

# Get current distribution config
aws cloudfront get-distribution-config --id "$DISTRIBUTION_ID" > /tmp/cf-current.json
ETAG=$(cat /tmp/cf-current.json | jq -r '.ETag')
cat /tmp/cf-current.json | jq '.DistributionConfig' > /tmp/cf-config-current.json

# Update configuration
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

# Apply update
aws cloudfront update-distribution \
    --id "$DISTRIBUTION_ID" \
    --if-match "$ETAG" \
    --distribution-config file:///tmp/cf-config-updated.json

echo "✅ CloudFront updated! This may take 15-20 minutes to deploy."
```

#### Using Automated Script

```bash
chmod +x update-cloudfront-with-ssl.sh
./update-cloudfront-with-ssl.sh
```

---

### Step 6: Configure DNS for Widget

#### In Hostinger DNS

1. Login to Hostinger
2. Navigate to DNS Management
3. Add **CNAME Record**:
   - **Type:** CNAME
   - **Name:** `callhub`
   - **Value:** `d2t5fsybshqnye.cloudfront.net`
     - Replace with your actual CloudFront domain name
     - Get it from: `aws cloudfront get-distribution --id $(cat .cloudfront-distribution-id.txt) --query 'Distribution.DomainName' --output text`
   - **TTL:** 3600
4. Click **Save**

#### Wait for DNS Propagation

Wait 5-30 minutes for DNS changes to propagate.

#### Verify DNS

```bash
# Check DNS resolution
dig callhub.intalksai.com +short

# Should resolve to CloudFront edge server

# Test HTTPS endpoint
curl -I https://callhub.intalksai.com

# Should return: HTTP/2 200
```

---

## Verification

### API Verification

```bash
# Test HTTP endpoint
curl http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/health

# Test HTTPS endpoint (Beanstalk)
curl https://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/health

# Test custom domain (HTTPS)
curl https://api.intalksai.com/api/health

# Expected response:
# {"status":"ok","timestamp":"2024-10-12T10:30:00.000Z"}
```

### Widget Verification

```bash
# Test S3 endpoint (HTTP)
curl -I http://intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com

# Test CloudFront endpoint (HTTPS)
curl -I https://d2t5fsybshqnye.cloudfront.net

# Test custom domain (HTTPS)
curl -I https://callhub.intalksai.com

# Expected response:
# HTTP/2 200
```

### End-to-End Test

1. Open browser: `https://callhub.intalksai.com`
2. Open browser console
3. Verify widget loads without errors
4. Verify API calls go to `https://api.intalksai.com`
5. Test making a call

---

## Troubleshooting

### Certificate Validation Issues

**Problem:** Certificate stuck in `PENDING_VALIDATION`

**Solutions:**
1. Verify DNS record is correct (no typos, correct format)
2. Check DNS record includes trailing dot (`.`) in value
3. Verify TTL is not too high (use 3600 or lower)
4. Wait longer (up to 30 minutes)
5. Check DNS propagation: `dig _validation-record.api.intalksai.com CNAME`

### CloudFront Certificate Must Be in us-east-1

**Problem:** `Certificate ARN must be in us-east-1`

**Solution:** Always request CloudFront certificates in `us-east-1` region, even if your S3 bucket is in another region.

### HTTPS Not Working After Deployment

**Problem:** HTTPS returns connection refused or timeout

**Solutions:**
1. Check security group allows inbound port 443
2. Verify certificate is in the same region as ALB (ap-south-1 for API)
3. Check ALB listener is configured for HTTPS on port 443
4. Wait 5-10 minutes after deployment for changes to propagate

### DNS Not Resolving

**Problem:** Domain not resolving to correct IP

**Solutions:**
1. Verify DNS record type (CNAME for ALB/CloudFront)
2. Check DNS record value is correct
3. Flush local DNS cache:
   ```bash
   # macOS
   sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
   
   # Linux
   sudo systemd-resolve --flush-caches
   ```
4. Check DNS propagation: `dig api.intalksai.com +short`

### Mixed Content Errors

**Problem:** Browser blocks HTTP requests from HTTPS page

**Solution:** Ensure both API and Widget use HTTPS:
- API: `https://api.intalksai.com`
- Widget: `https://callhub.intalksai.com`

---

## Quick Reference

### Certificate ARNs

```bash
# API Certificate (ap-south-1)
cat .eb-cert-arn.txt
# Output: arn:aws:acm:ap-south-1:844605843483:certificate/c2affef8-43bb-4671-b04a-c4f209d914aa

# Widget Certificate (us-east-1)
cat .cloudfront-cert-arn.txt
# Output: arn:aws:acm:us-east-1:844605843483:certificate/fa9fae7d-7fa0-4f6e-b06a-4d4e878047cd
```

### Distribution IDs

```bash
# CloudFront Distribution
cat .cloudfront-distribution-id.txt
# Output: E23RHJVEDGE3B2
```

### Common Commands

```bash
# Check API certificate status
aws acm describe-certificate \
    --certificate-arn $(cat .eb-cert-arn.txt) \
    --region ap-south-1 \
    --query 'Certificate.Status' \
    --output text

# Check Widget certificate status
aws acm describe-certificate \
    --certificate-arn $(cat .cloudfront-cert-arn.txt) \
    --region us-east-1 \
    --query 'Certificate.Status' \
    --output text

# Deploy API
cd api && eb deploy production-mumbai --region ap-south-1

# Deploy Widget
aws s3 sync widget/build/ s3://intalksai-call-ribbon-widget-mumbai-1760280743/ \
    --region ap-south-1 --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
    --distribution-id $(cat .cloudfront-distribution-id.txt) \
    --paths "/*"

# Check Beanstalk environment status
eb status production-mumbai --region ap-south-1

# View Beanstalk logs
eb logs production-mumbai --region ap-south-1
```

### Production URLs

**API:**
- HTTPS: `https://api.intalksai.com`
- HTTP: `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com`

**Widget:**
- HTTPS (Custom Domain): `https://callhub.intalksai.com`
- HTTPS (CloudFront): `https://d2t5fsybshqnye.cloudfront.net`
- HTTP (S3): `http://intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com`

---

## Next Steps

After successful deployment:

1. **Update Documentation:**
   - Update `docs/CRM_INTEGRATION_FINAL.md` with production URLs
   - Update `DEPLOYMENT_READY.md` with deployment status

2. **Test End-to-End:**
   - Test widget loading
   - Test API endpoints
   - Test call functionality
   - Verify analytics collection

3. **Monitor:**
   - Set up CloudWatch alarms
   - Monitor API logs
   - Track CloudFront distribution metrics

4. **Security:**
   - Review security group rules
   - Enable AWS WAF if needed
   - Set up rate limiting
   - Review IAM roles and policies

---

**Questions or Issues?** Refer to:
- [AWS Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS Certificate Manager Documentation](https://docs.aws.amazon.com/acm/)

---

**Last Updated:** October 2024  
**Version:** 1.0
