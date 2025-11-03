# 🔒 Setup HTTPS for API using Hostinger DNS

This guide shows you how to enable HTTPS for your Elastic Beanstalk API using Hostinger DNS and AWS Certificate Manager.

## 📋 Prerequisites

- Domain: `intalksai.com` (managed in Hostinger)
- Subdomain: `api.intalksai.com` (we'll use this for API)
- AWS Elastic Beanstalk environment: `production-mumbai`
- Region: Mumbai (ap-south-1)

## 🎯 Overview

Since your Beanstalk environment currently uses **Single Instance** (no load balancer), we have two options:

### **Option A: Request Certificate via Script (Recommended)**
Uses AWS CLI to request SSL certificate and guide you through DNS validation.

### **Option B: Manual AWS Console Setup**
Step-by-step manual setup using AWS Console.

---

## 📋 Option A: Automated Script

### Step 1: Run the Setup Script

```bash
chmod +x setup-eb-https.sh
./setup-eb-https.sh
```

This will:
1. Check if SSL certificate exists for `api.intalksai.com`
2. Request certificate if not exists
3. Show you DNS validation records
4. Guide you through Hostinger DNS configuration

### Step 2: Add DNS Validation to Hostinger

After running the script, you'll get DNS validation CNAME records like:

```
Name: _abc123def456.api.intalksai.com
Value: _xyz789.acm-validations.aws.
TTL: 3600
```

**In Hostinger:**
1. Login to Hostinger
2. Go to DNS Management for `intalksai.com`
3. Add CNAME record:
   - **Name:** `_abc123def456.api`
   - **Value:** `_xyz789.acm-validations.aws.`
   - **TTL:** 3600
4. Save and wait 5-30 minutes for validation

### Step 3: Check Certificate Status

```bash
# Get certificate ARN
CERT_ARN=$(cat .eb-cert-arn.txt)

# Check status
aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region ap-south-1 \
    --query 'Certificate.Status'
```

Wait until status shows `ISSUED`.

### Step 4: Configure Beanstalk for ALB

**Important:** Your current environment uses Single Instance. We need to add an Application Load Balancer.

**Option 4a: Upgrade Existing Environment (via AWS Console)**

1. Go to [Elastic Beanstalk Console](https://console.aws.amazon.com/elasticbeanstalk/home?region=ap-south-1#/environments)
2. Select environment: `production-mumbai`
3. Click **Configuration** → **Load balancer** → **Edit**
4. Change:
   - **Load balancer type:** Single Instance → Application Load Balancer
   - Click **Apply**
5. Wait 5-10 minutes for upgrade

**Option 4b: Create New Environment with ALB (Recommended)**

```bash
cd api

# Create new environment with ALB
eb create production-mumbai-alb \
    --region ap-south-1 \
    --elb-type application \
    --instance-type t3.micro
```

After environment is ready:
```bash
# Deploy your app to new environment
eb deploy production-mumbai-alb --region ap-south-1
```

### Step 5: Configure HTTPS Listener

Create `.ebextensions/01-https.config`:

```bash
cd api
mkdir -p .ebextensions

# Get certificate ARN
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

Resources:
  AWSEBAutoScalingGroup:
    Metadata:
      AWS::CloudFormation::Authentication:
        S3Auth:
          type: "s3"
          buckets: ["elasticbeanstalk-*"]
          roleName: "aws-elasticbeanstalk-ec2-role"
EOF

# Deploy
eb deploy production-mumbai-alb --region ap-south-1
```

### Step 6: Configure Hostinger DNS

Once Beanstalk is upgraded to ALB and HTTPS is configured:

```bash
# Get the environment CNAME
eb status production-mumbai-alb --region ap-south-1 | grep CNAME
```

**In Hostinger:**
1. Go to DNS Management
2. Add A record (or CNAME):
   - **Type:** CNAME (or A record with ALB IP)
   - **Name:** `api`
   - **Value:** `production-mumbai-alb.eba-xxxxx.ap-south-1.elasticbeanstalk.com`
   - **TTL:** 3600
3. Save and wait 5-30 minutes

### Step 7: Test

```bash
# Test HTTPS
curl -I https://api.intalksai.com/api/health

# Should return:
# HTTP/2 200
```

---

## 📋 Option B: Manual Setup via AWS Console

### Step 1: Request SSL Certificate

1. Go to [AWS Certificate Manager](https://console.aws.amazon.com/acm/home?region=ap-south-1)
2. Click **Request a certificate**
3. Select **Request a public certificate**
4. Enter domain: `api.intalksai.com`
5. Choose **DNS validation**
6. Click **Request**
7. Note the certificate ARN

### Step 2: Add DNS Validation to Hostinger

1. In ACM, click on your certificate
2. Under **Domains**, click **Create record in Route 53** (or **Show validation data**)
3. You'll see:
   ```
   Name: _abc123def456.api.intalksai.com
   Type: CNAME
   Value: _xyz789.acm-validations.aws.
   ```
4. In Hostinger, add this CNAME record
5. Wait for certificate validation

### Step 3: Upgrade Beanstalk to ALB

1. Go to [Elastic Beanstalk Console](https://console.aws.amazon.com/elasticbeanstalk/home?region=ap-south-1)
2. Select: `production-mumbai`
3. **Configuration** → **Load balancer** → **Edit**
4. Change to **Application Load Balancer**
5. Click **Apply**
6. Wait 5-10 minutes

### Step 4: Configure HTTPS Listener

1. Still in Beanstalk Configuration
2. **Load balancer** → **Edit**
3. Scroll to **Listeners**
4. Click **Add listener**
5. Configure:
   - **Port:** 443
   - **Protocol:** HTTPS
   - **SSL certificate:** Select your `api.intalksai.com` certificate
6. Click **Apply**
7. Wait 5-10 minutes

### Step 5: Configure Hostinger DNS

1. Go to Hostinger DNS Management
2. Add CNAME:
   - **Name:** `api`
   - **Value:** `production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com`
   - **TTL:** 3600

### Step 6: Test

```bash
curl https://api.intalksai.com/api/health
```

---

## 🔧 Troubleshooting

### Certificate Validation Failed
- Check DNS record is correct in Hostinger
- Wait longer (up to 30 minutes)
- Check record format (no extra spaces, correct TTL)

### ALB Upgrade Failing
- Single instance environments cannot be upgraded to ALB in place
- Create new environment with ALB instead
- Migrate traffic after testing

### HTTPS Not Working
- Check certificate is in same region as Beanstalk (ap-south-1)
- Verify listener is configured on port 443
- Check security groups allow inbound 443
- Wait 5-10 minutes after deployment

---

## 📝 Next Steps After HTTPS is Working

1. **Update Widget to Use HTTPS API:**
   ```javascript
   IntalksAICallRibbon.init({
     apiKey: 'your-key',
     apiUrl: 'https://api.intalksai.com',  // HTTPS!
     position: 'bottom'
   });
   ```

2. **Enable HTTP to HTTPS Redirect:**
   - Add listener rule in ALB to redirect HTTP (80) to HTTPS (443)

3. **Update CloudFront Widget URL:**
   - Use HTTPS widget URL: `https://api.intalksai.com/static/js/main.fd7646b7.js`
   - This resolves mixed content issues

---

## 💡 Quick Commands Reference

```bash
# Check certificate status
aws acm list-certificates --region ap-south-1

# Describe certificate
aws acm describe-certificate --certificate-arn <ARN> --region ap-south-1

# Check Beanstalk environment status
eb status production-mumbai --region ap-south-1

# Deploy changes
eb deploy production-mumbai --region ap-south-1

# View logs
eb logs production-mumbai --region ap-south-1

# Test API
curl https://api.intalksai.com/api/health
```

---

**Questions or Issues?** Contact AWS Support or refer to:
- [AWS ELB HTTPS Listener](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html)
- [ACM Certificate Request](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)
- [Beanstalk Load Balancer Configuration](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/config-lb-with-cli.html)

