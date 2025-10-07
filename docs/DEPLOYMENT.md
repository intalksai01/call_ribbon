# 🚀 Deployment Guide - Exotel Call Ribbon

**For Providers Only** - This guide is for deploying and managing the Call Control Ribbon as a service.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [One-Time Setup](#one-time-setup)
3. [Build Widget](#build-widget)
4. [Deploy to CDN](#deploy-to-cdn)
5. [Deploy API Server](#deploy-api-server)
6. [Client Onboarding](#client-onboarding)
7. [Monitoring & Maintenance](#monitoring--maintenance)
8. [Scaling](#scaling)

---

## ✅ Prerequisites

### **Required:**
- Node.js 14+ installed
- AWS Account (for S3/CloudFront) OR Netlify/Vercel account
- Domain name for API server
- SSL certificate (Let's Encrypt or AWS Certificate Manager)
- Exotel account with API access

### **Recommended:**
- PostgreSQL or MongoDB for production
- Redis for caching
- Monitoring tool (Datadog, New Relic, or CloudWatch)
- CI/CD pipeline (GitHub Actions, GitLab CI)

---

## 🎬 One-Time Setup

### **Step 1: Clone and Install**

```bash
# Clone the repository
git clone https://github.com/yourcompany/exotel-call-ribbon.git
cd exotel-call-ribbon

# Install widget dependencies
cd widget
npm install

# Install API dependencies
cd ../api
npm install
```

### **Step 2: Environment Configuration**

Create environment files:

```bash
# Widget environment (.env)
cd widget
cat > .env << EOF
NODE_ENV=production
CDN_URL=https://cdn.yourcompany.com
EOF

# API environment (.env)
cd ../api
cat > .env << EOF
NODE_ENV=production
PORT=3000
API_URL=https://api.yourcompany.com
DATABASE_URL=postgresql://user:pass@host:5432/ribbon_db
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-super-secret-jwt-key
CORS_ORIGINS=https://cdn.yourcompany.com,https://yourcompany.com
EOF
```

---

## 🏗️ Build Widget

### **Development Build:**

```bash
cd widget
npm run start
# Test at http://localhost:3000
```

### **Production Build:**

```bash
cd widget
npm run build

# Output in dist/ folder:
# - dist/ribbon.js
# - dist/ribbon.css
# - dist/ribbon.min.js (minified)
# - dist/ribbon.min.css (minified)
```

### **Verify Build:**

```bash
# Check file sizes
ls -lh dist/

# Test build locally
npx http-server dist -p 8080
# Open http://localhost:8080/test.html
```

---

## ☁️ Deploy to CDN

### **Option 1: AWS S3 + CloudFront (Recommended)**

#### **1.1 Create S3 Bucket:**

```bash
# Create bucket
aws s3 mb s3://yourcompany-call-ribbon --region us-east-1

# Enable static website hosting
aws s3 website s3://yourcompany-call-ribbon \
  --index-document index.html
```

#### **1.2 Upload Files:**

```bash
cd widget/dist

# Upload files
aws s3 sync . s3://yourcompany-call-ribbon/v1/ \
  --acl public-read \
  --cache-control "max-age=31536000" \
  --exclude "*.map"

# Verify upload
aws s3 ls s3://yourcompany-call-ribbon/v1/
```

#### **1.3 Create CloudFront Distribution:**

```bash
# Via AWS Console:
# 1. Go to CloudFront → Create Distribution
# 2. Origin Domain: yourcompany-call-ribbon.s3.amazonaws.com
# 3. Origin Path: /v1
# 4. Enable HTTPS only
# 5. Custom domain: cdn.yourcompany.com
# 6. SSL Certificate: Use ACM

# Or via CLI:
aws cloudfront create-distribution \
  --origin-domain-name yourcompany-call-ribbon.s3.amazonaws.com \
  --default-root-object ribbon.js
```

#### **1.4 Configure DNS:**

```bash
# Add CNAME record:
# cdn.yourcompany.com → d111111abcdef8.cloudfront.net
```

**Your URLs:**
- `https://cdn.yourcompany.com/ribbon.js`
- `https://cdn.yourcompany.com/ribbon.css`

---

### **Option 2: Netlify (Fastest)**

```bash
cd widget/dist

# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Deploy
netlify deploy --prod --dir=.

# Output:
# Website URL: https://yourapp.netlify.app
# 
# Use custom domain:
# netlify domains:add cdn.yourcompany.com
```

---

### **Option 3: Vercel**

```bash
cd widget/dist

# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
vercel --prod

# Add custom domain via Vercel dashboard
```

---

## 🖥️ Deploy API Server

### **Option 1: Heroku (Easiest)**

```bash
cd api

# Create Heroku app
heroku create yourcompany-ribbon-api

# Add PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Add Redis
heroku addons:create heroku-redis:hobby-dev

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=$(openssl rand -base64 32)
heroku config:set CORS_ORIGINS=https://cdn.yourcompany.com

# Deploy
git init
git add .
git commit -m "Initial API deployment"
git push heroku main

# Your API URL: https://yourcompany-ribbon-api.herokuapp.com
```

---

### **Option 2: AWS EC2 (Full Control)**

#### **2.1 Launch EC2 Instance:**

```bash
# Create EC2 instance (t3.medium recommended)
# Ubuntu 22.04 LTS
# Security Group: Allow ports 80, 443, 22

# SSH into instance
ssh -i your-key.pem ubuntu@your-ec2-ip
```

#### **2.2 Setup Server:**

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2
sudo npm install -g pm2

# Install Nginx
sudo apt install -y nginx

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Install Redis
sudo apt install -y redis-server
```

#### **2.3 Deploy Application:**

```bash
# Clone repository
cd /var/www
sudo git clone https://github.com/yourcompany/exotel-call-ribbon.git
cd exotel-call-ribbon/api

# Install dependencies
sudo npm install --production

# Create .env file
sudo nano .env
# (Add environment variables)

# Start with PM2
sudo pm2 start server.js --name ribbon-api
sudo pm2 startup
sudo pm2 save
```

#### **2.4 Configure Nginx:**

```bash
sudo nano /etc/nginx/sites-available/ribbon-api

# Add configuration:
server {
    listen 80;
    server_name api.yourcompany.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/ribbon-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### **2.5 Setup SSL (Let's Encrypt):**

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.yourcompany.com
```

**Your API URL:** `https://api.yourcompany.com`

---

### **Option 3: Docker (Portable)**

```bash
cd api

# Create Dockerfile (already included)
# Build image
docker build -t ribbon-api:latest .

# Run container
docker run -d \
  --name ribbon-api \
  -p 3000:3000 \
  --env-file .env \
  --restart unless-stopped \
  ribbon-api:latest

# Or use Docker Compose
docker-compose up -d
```

---

## 👥 Client Onboarding

### **Step 1: Generate API Key**

```bash
# Add client to api/server.js:

const clients = {
  'client-abc-123-xyz': {
    clientId: 'client-001',
    name: 'ABC Collections CRM',
    exotelToken: 'their_exotel_token',
    exotelUserId: 'their_user_id',
    allowedDomains: ['collections.abccompany.com'],
    monthlyCallLimit: 10000,
    plan: 'enterprise',
    features: ['call', 'mute', 'hold', 'dtmf', 'transfer']
  }
};
```

### **Step 2: Provide Client Package**

Send client:
1. **API Key**: `client-abc-123-xyz`
2. **CDN URLs**:
   - CSS: `https://cdn.yourcompany.com/ribbon.css`
   - JS: `https://cdn.yourcompany.com/ribbon.js`
3. **Integration Guide**: [CLIENT_GUIDE.md](CLIENT_GUIDE.md)
4. **Support Contact**: support@yourcompany.com

### **Step 3: Test Integration**

```bash
# Test client's integration
curl https://api.yourcompany.com/api/ribbon/init \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"apiKey": "client-abc-123-xyz", "domain": "collections.abccompany.com"}'

# Expected response:
# {
#   "exotelToken": "...",
#   "userId": "...",
#   "features": [...],
#   "clientInfo": {...}
# }
```

---

## 📊 Monitoring & Maintenance

### **1. Health Checks**

```bash
# Setup monitoring endpoints
curl https://api.yourcompany.com/health

# Response:
# {
#   "status": "healthy",
#   "uptime": 3600,
#   "version": "1.0.0"
# }
```

### **2. Log Monitoring**

```bash
# PM2 logs
pm2 logs ribbon-api

# Or use monitoring service:
# - Datadog: https://www.datadoghq.com/
# - New Relic: https://newrelic.com/
# - CloudWatch: AWS native
```

### **3. Database Backups**

```bash
# PostgreSQL backup
pg_dump ribbon_db > backup-$(date +%Y%m%d).sql

# Automated daily backups
crontab -e
# Add: 0 2 * * * /usr/bin/pg_dump ribbon_db > /backups/backup-$(date +\%Y\%m\%d).sql
```

### **4. Update Widget**

```bash
# Build new version
cd widget
npm version patch  # or minor, major
npm run build

# Deploy to CDN
aws s3 sync dist/ s3://yourcompany-call-ribbon/v1/ \
  --acl public-read \
  --cache-control "max-age=31536000"

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR_DIST_ID \
  --paths "/v1/*"
```

---

## 📈 Scaling

### **Horizontal Scaling (API)**

```bash
# Add more API servers behind load balancer
# AWS: Use Elastic Load Balancer
# Nginx: Configure upstream servers

# Example Nginx configuration:
upstream ribbon_api {
    server api1.yourcompany.com:3000;
    server api2.yourcompany.com:3000;
    server api3.yourcompany.com:3000;
}

server {
    listen 443 ssl;
    server_name api.yourcompany.com;
    
    location / {
        proxy_pass http://ribbon_api;
    }
}
```

### **Database Scaling**

```bash
# Add read replicas
# Enable connection pooling
# Implement caching with Redis
```

### **CDN Scaling**

```bash
# CloudFront automatically scales
# Consider multiple CDN providers:
# - Cloudflare (global)
# - Fastly (real-time purge)
# - Akamai (enterprise)
```

---

## ✅ Deployment Checklist

### **Pre-Launch:**
- [ ] Widget builds successfully
- [ ] API server running
- [ ] Database configured
- [ ] CDN hosting setup
- [ ] SSL certificates installed
- [ ] Monitoring configured
- [ ] Backup system in place
- [ ] Test with 2-3 pilot clients

### **Launch:**
- [ ] DNS records updated
- [ ] API endpoints tested
- [ ] Widget loads from CDN
- [ ] Client documentation ready
- [ ] Support system ready
- [ ] Billing system configured

### **Post-Launch:**
- [ ] Monitor performance
- [ ] Collect client feedback
- [ ] Track usage metrics
- [ ] Plan feature updates

---

## 🆘 Troubleshooting

### **Widget not loading:**
```bash
# Check CDN
curl -I https://cdn.yourcompany.com/ribbon.js

# Check CORS
curl -H "Origin: https://client-domain.com" \
  https://cdn.yourcompany.com/ribbon.js -I
```

### **API errors:**
```bash
# Check logs
pm2 logs ribbon-api

# Check database connection
psql -U user -d ribbon_db -c "SELECT 1;"
```

### **Performance issues:**
```bash
# Check API response time
curl -w "@curl-format.txt" -o /dev/null -s https://api.yourcompany.com/health

# Monitor database
pg_stat_statements
```

---

## 📞 Support

For deployment issues:
- 📧 Email: devops@yourcompany.com
- 💬 Slack: #ribbon-deployment
- 📖 Docs: This guide

---

**You're now ready to deploy and manage the Exotel Call Ribbon!** 🚀


