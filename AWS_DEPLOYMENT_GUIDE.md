# ☁️ AWS Deployment Guide - Exotel Call Ribbon

## 🎯 **AWS Architecture Overview**

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                       │
│  CloudFront CDN (Global Edge Locations)                             │
│  • Widget files cached worldwide                                     │
│  • SSL/TLS certificate (free)                                        │
│  • DDoS protection                                                   │
│  https://d1234567890.cloudfront.net                                 │
│                                                                       │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────────┐
│                                                                       │
│  S3 Bucket (Widget Storage)                                          │
│  • Static files: HTML, CSS, JS                                       │
│  • Versioned deployments                                             │
│  • Cost: ~$0.50/month                                               │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘

                    Client Browsers
                            ↓
┌─────────────────────────────────────────────────────────────────────┐
│                                                                       │
│  Application Load Balancer                                           │
│  • SSL termination                                                   │
│  • Health checks                                                     │
│  • Auto-scaling support                                              │
│  https://api.yourcompany.com                                        │
│                                                                       │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────────┐
│                                                                       │
│  ECS/Fargate or EC2 (API Server)                                    │
│  • Node.js API server                                                │
│  • Auto-scaling                                                      │
│  • Cost: $10-50/month                                               │
│                                                                       │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────────┐
│                                                                       │
│  RDS PostgreSQL (Optional - for production data)                    │
│  • Client credentials                                                │
│  • Call logs                                                         │
│  • Cost: $15-50/month                                               │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 💰 **AWS Cost Breakdown**

### **Monthly Costs:**
```
Widget (S3 + CloudFront):
  - S3 Storage (1GB):           $0.50
  - CloudFront (10GB transfer): $1.00
  - Total:                      $1.50/month

API Server:
  - ECS Fargate (0.25 vCPU):    $10-15/month
  OR
  - EC2 t3.micro:               $8-10/month
  OR  
  - Elastic Beanstalk:          $10-15/month

Database (Optional):
  - RDS db.t3.micro:            $15-20/month
  OR
  - DynamoDB:                   $5-10/month (pay per use)

Load Balancer:
  - Application LB:             $16/month
  OR
  - API Gateway:                $3.50/million requests

SSL Certificates:
  - AWS Certificate Manager:    FREE

Total Estimated Cost:
  - Basic Setup:                $25-35/month
  - Production Setup:           $50-100/month
  - Enterprise Setup:           $100-200/month
```

---

## 🚀 **Deployment Options**

### **Option 1: Fully Managed (Easiest)** ⭐ Recommended for Beginners

**Widget**: S3 + CloudFront  
**API**: Elastic Beanstalk  
**Database**: RDS (managed)  

**Pros**: Easy to set up, managed services, auto-scaling  
**Cons**: Slightly more expensive  
**Time**: 30-45 minutes  

---

### **Option 2: Container-Based (Modern)** ⭐ Recommended for Scale

**Widget**: S3 + CloudFront  
**API**: ECS Fargate  
**Database**: RDS or DynamoDB  

**Pros**: Scalable, modern, easy updates  
**Cons**: Requires Docker knowledge  
**Time**: 45-60 minutes  

---

### **Option 3: Serverless (Most Cost-Effective)** ⭐ Recommended for Low Traffic

**Widget**: S3 + CloudFront  
**API**: Lambda + API Gateway  
**Database**: DynamoDB  

**Pros**: Pay per use, auto-scales to zero  
**Cons**: Cold start latency  
**Time**: 60-90 minutes  

---

## 📋 **Prerequisites**

### **Required:**
- [ ] AWS Account (create at https://aws.amazon.com)
- [ ] AWS CLI installed
- [ ] Domain name (optional, but recommended)
- [ ] Exotel production credentials

### **Install AWS CLI:**
```bash
# macOS
brew install awscli

# Or download from:
# https://aws.amazon.com/cli/

# Configure AWS CLI
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format: json
```

---

## 🎯 **OPTION 1: Elastic Beanstalk Deployment (Easiest)**

### **Step 1: Deploy Widget to S3 + CloudFront (15 minutes)**

```bash
# Navigate to widget directory
cd /Users/arun/cursor/call_control/exotel-call-ribbon/widget

# Build the widget
npm run build

# Create S3 bucket (replace 'your-unique-bucket-name')
aws s3 mb s3://exotel-call-ribbon-widget-prod

# Enable static website hosting
aws s3 website s3://exotel-call-ribbon-widget-prod \
  --index-document index.html \
  --error-document index.html

# Upload build files
aws s3 sync build/ s3://exotel-call-ribbon-widget-prod \
  --acl public-read \
  --cache-control "public, max-age=31536000"

# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name exotel-call-ribbon-widget-prod.s3.amazonaws.com \
  --default-root-object index.html

# Note the CloudFront URL (e.g., d1234567890.cloudfront.net)
```

### **Step 2: Deploy API to Elastic Beanstalk (15 minutes)**

```bash
# Navigate to API directory
cd /Users/arun/cursor/call_control/exotel-call-ribbon/api

# Install EB CLI
pip install awsebcli

# Initialize Elastic Beanstalk
eb init -p node.js-18 exotel-call-ribbon-api --region us-east-1

# Create environment and deploy
eb create production-env

# Open your API
eb open

# Get your API URL
eb status
# Note the CNAME (e.g., production-env.us-east-1.elasticbeanstalk.com)
```

### **Step 3: Configure CORS and Environment Variables**

```bash
# Set environment variables
eb setenv \
  NODE_ENV=production \
  CORS_ORIGINS=https://d1234567890.cloudfront.net

# Update and redeploy
eb deploy
```

---

## 🐳 **OPTION 2: ECS Fargate Deployment (Modern)**

### **Step 1: Deploy Widget (Same as Option 1)**

```bash
# Same S3 + CloudFront steps as above
cd /Users/arun/cursor/call_control/exotel-call-ribbon/widget
npm run build
aws s3 sync build/ s3://exotel-call-ribbon-widget-prod --acl public-read
```

### **Step 2: Create Docker Image for API**

```bash
# Navigate to API directory
cd /Users/arun/cursor/call_control/exotel-call-ribbon/api

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.env
.git
EOF

# Build Docker image
docker build -t exotel-call-ribbon-api .

# Test locally
docker run -p 3000:3000 exotel-call-ribbon-api
```

### **Step 3: Push to Amazon ECR**

```bash
# Create ECR repository
aws ecr create-repository --repository-name exotel-call-ribbon-api

# Get login token
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Tag image
docker tag exotel-call-ribbon-api:latest \
  YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/exotel-call-ribbon-api:latest

# Push image
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/exotel-call-ribbon-api:latest
```

### **Step 4: Deploy to ECS Fargate**

```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name exotel-ribbon-cluster

# Create task definition (save as task-definition.json)
cat > task-definition.json << 'EOF'
{
  "family": "exotel-ribbon-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "api",
      "image": "YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/exotel-call-ribbon-api:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ]
    }
  ]
}
EOF

# Register task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Create service
aws ecs create-service \
  --cluster exotel-ribbon-cluster \
  --service-name exotel-ribbon-api-service \
  --task-definition exotel-ribbon-api \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"
```

---

## ⚡ **OPTION 3: Serverless Deployment (Most Cost-Effective)**

### **Step 1: Deploy Widget (Same as Options 1 & 2)**

### **Step 2: Deploy API to Lambda**

```bash
# Install Serverless Framework
npm install -g serverless

# Navigate to API directory
cd /Users/arun/cursor/call_control/exotel-call-ribbon/api

# Create serverless.yml
cat > serverless.yml << 'EOF'
service: exotel-call-ribbon-api

provider:
  name: aws
  runtime: nodejs18.x
  region: us-east-1
  environment:
    NODE_ENV: production

functions:
  api:
    handler: lambda.handler
    events:
      - http:
          path: /{proxy+}
          method: ANY
          cors: true

plugins:
  - serverless-offline
EOF

# Create Lambda handler
cat > lambda.js << 'EOF'
const serverless = require('serverless-http');
const app = require('./server');

module.exports.handler = serverless(app);
EOF

# Install dependencies
npm install serverless-http serverless-offline

# Deploy
serverless deploy

# Get your API URL from output
```

---

## 🔐 **Security Configuration**

### **1. Set up SSL/TLS Certificates**

```bash
# Request certificate from AWS Certificate Manager (FREE)
aws acm request-certificate \
  --domain-name api.yourcompany.com \
  --validation-method DNS

# For widget (CloudFront)
aws acm request-certificate \
  --domain-name widget.yourcompany.com \
  --validation-method DNS \
  --region us-east-1
```

### **2. Configure Security Groups**

```bash
# Create security group for API server
aws ec2 create-security-group \
  --group-name exotel-ribbon-api-sg \
  --description "Security group for Exotel Call Ribbon API"

# Allow HTTPS traffic
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# Allow HTTP traffic (for health checks)
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```

### **3. Set up IAM Roles**

```bash
# Create IAM role for ECS task
aws iam create-role \
  --role-name exotel-ribbon-ecs-task-role \
  --assume-role-policy-document file://trust-policy.json

# Attach policies
aws iam attach-role-policy \
  --role-name exotel-ribbon-ecs-task-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

---

## 🗄️ **Database Setup (Optional)**

### **Option A: RDS PostgreSQL**

```bash
# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier exotel-ribbon-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password YOUR_SECURE_PASSWORD \
  --allocated-storage 20 \
  --backup-retention-period 7 \
  --publicly-accessible false

# Get connection string
aws rds describe-db-instances \
  --db-instance-identifier exotel-ribbon-db \
  --query 'DBInstances[0].Endpoint.Address'
```

### **Option B: DynamoDB (Serverless)**

```bash
# Create DynamoDB table for clients
aws dynamodb create-table \
  --table-name exotel-ribbon-clients \
  --attribute-definitions \
    AttributeName=apiKey,AttributeType=S \
  --key-schema \
    AttributeName=apiKey,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Create table for call logs
aws dynamodb create-table \
  --table-name exotel-ribbon-call-logs \
  --attribute-definitions \
    AttributeName=logId,AttributeType=S \
    AttributeName=timestamp,AttributeType=N \
  --key-schema \
    AttributeName=logId,KeyType=HASH \
    AttributeName=timestamp,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST
```

---

## 🔄 **CI/CD Pipeline with AWS CodePipeline**

### **Automated Deployment Setup**

```bash
# Create buildspec.yml for widget
cat > widget/buildspec.yml << 'EOF'
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 18
  pre_build:
    commands:
      - npm install
  build:
    commands:
      - npm run build
  post_build:
    commands:
      - aws s3 sync build/ s3://exotel-call-ribbon-widget-prod --delete
      - aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"

artifacts:
  files:
    - '**/*'
  base-directory: build
EOF

# Create buildspec.yml for API
cat > api/buildspec.yml << 'EOF'
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
  build:
    commands:
      - echo Build started on `date`
      - docker build -t exotel-call-ribbon-api .
      - docker tag exotel-call-ribbon-api:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/exotel-call-ribbon-api:latest
  post_build:
    commands:
      - echo Build completed on `date`
      - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/exotel-call-ribbon-api:latest
EOF
```

---

## 📊 **Monitoring & Logging**

### **CloudWatch Setup**

```bash
# Create log group
aws logs create-log-group --log-group-name /aws/ecs/exotel-ribbon-api

# Set retention
aws logs put-retention-policy \
  --log-group-name /aws/ecs/exotel-ribbon-api \
  --retention-in-days 30

# Create CloudWatch dashboard
aws cloudwatch put-dashboard \
  --dashboard-name ExotelRibbonDashboard \
  --dashboard-body file://dashboard.json
```

### **Set up Alarms**

```bash
# High error rate alarm
aws cloudwatch put-metric-alarm \
  --alarm-name exotel-ribbon-high-error-rate \
  --alarm-description "Alert when error rate is high" \
  --metric-name 5XXError \
  --namespace AWS/ApplicationELB \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold

# High latency alarm
aws cloudwatch put-metric-alarm \
  --alarm-name exotel-ribbon-high-latency \
  --alarm-description "Alert when latency is high" \
  --metric-name TargetResponseTime \
  --namespace AWS/ApplicationELB \
  --statistic Average \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold
```

---

## 🌐 **Custom Domain Setup**

### **Route 53 Configuration**

```bash
# Create hosted zone
aws route53 create-hosted-zone \
  --name yourcompany.com \
  --caller-reference $(date +%s)

# Create A record for API
aws route53 change-resource-record-sets \
  --hosted-zone-id YOUR_ZONE_ID \
  --change-batch file://api-record.json

# api-record.json
{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "api.yourcompany.com",
      "Type": "A",
      "AliasTarget": {
        "HostedZoneId": "YOUR_ALB_ZONE_ID",
        "DNSName": "your-alb.us-east-1.elb.amazonaws.com",
        "EvaluateTargetHealth": false
      }
    }
  }]
}

# Create A record for widget (CloudFront)
aws route53 change-resource-record-sets \
  --hosted-zone-id YOUR_ZONE_ID \
  --change-batch file://widget-record.json
```

---

## 🎯 **Quick Start (Recommended Path)**

### **For Beginners - Elastic Beanstalk:**

```bash
# 1. Deploy Widget
cd widget && npm run build
aws s3 mb s3://exotel-call-ribbon-widget-$(date +%s)
aws s3 sync build/ s3://exotel-call-ribbon-widget-$(date +%s) --acl public-read

# 2. Deploy API
cd ../api
eb init -p node.js-18 exotel-call-ribbon-api
eb create production

# Done! Get URLs:
# Widget: Check S3 bucket properties
# API: Run 'eb status'
```

---

## 💡 **Best Practices**

### **Security:**
- ✅ Use AWS Secrets Manager for Exotel credentials
- ✅ Enable CloudTrail for audit logging
- ✅ Use VPC for API server
- ✅ Enable WAF for DDoS protection
- ✅ Rotate credentials regularly

### **Performance:**
- ✅ Use CloudFront for widget (global CDN)
- ✅ Enable gzip compression
- ✅ Set proper cache headers
- ✅ Use Auto Scaling for API
- ✅ Enable CloudFront caching

### **Cost Optimization:**
- ✅ Use Reserved Instances for predictable workloads
- ✅ Enable S3 lifecycle policies
- ✅ Use CloudFront price class
- ✅ Monitor with Cost Explorer
- ✅ Set up billing alarms

---

## 📋 **Deployment Checklist**

- [ ] AWS account created and configured
- [ ] AWS CLI installed and configured
- [ ] Widget built (`npm run build`)
- [ ] S3 bucket created for widget
- [ ] CloudFront distribution created
- [ ] API deployed (EB/ECS/Lambda)
- [ ] SSL certificates configured
- [ ] Custom domains set up (optional)
- [ ] Environment variables configured
- [ ] CORS configured
- [ ] Database set up (if needed)
- [ ] Monitoring and alarms configured
- [ ] Tested with real Exotel credentials
- [ ] Documentation updated with URLs

---

## 🆘 **Troubleshooting**

### **Common Issues:**

**Widget not loading:**
```bash
# Check S3 bucket policy
aws s3api get-bucket-policy --bucket exotel-call-ribbon-widget-prod

# Check CloudFront distribution
aws cloudfront get-distribution --id YOUR_DIST_ID
```

**API not responding:**
```bash
# Check ECS service
aws ecs describe-services --cluster exotel-ribbon-cluster --services exotel-ribbon-api-service

# Check logs
aws logs tail /aws/ecs/exotel-ribbon-api --follow
```

**CORS errors:**
```bash
# Update CORS in API
# Add your CloudFront URL to CORS_ORIGINS environment variable
eb setenv CORS_ORIGINS=https://d1234567890.cloudfront.net
```

---

## 🎉 **You're Ready!**

**Your AWS deployment will give you:**
- ✅ Global CDN for fast widget loading
- ✅ Auto-scaling API server
- ✅ Production-grade security
- ✅ 99.99% uptime SLA
- ✅ Professional infrastructure

**Estimated setup time:** 45-60 minutes  
**Monthly cost:** $25-50 (basic) to $100-200 (production)

**Need help?** AWS has excellent documentation and support!

