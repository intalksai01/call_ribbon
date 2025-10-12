# Hostinger DNS Setup Guide for Call Ribbon

## 🌐 Setting Up Custom Domain: callribbon.yourdomain.com

Since AWS S3 and Elastic Beanstalk don't provide static IP addresses, you need to use **CNAME records** instead of A records.

---

## 📋 **Current AWS Endpoints**

### Mumbai Frontend (S3)
```
Endpoint: intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com
Protocol: HTTP only (no HTTPS yet)
```

### Mumbai Backend API (Elastic Beanstalk)
```
Endpoint: production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
Protocol: HTTP only (no HTTPS yet)
```

---

## ⚠️ **Problem with Direct DNS Pointing:**

1. **No Static IPs** - AWS services use dynamic IPs
2. **No HTTPS** - Current setup is HTTP only
3. **CNAME Limitations** - Can't use CNAME for root domain

---

## ✅ **Recommended Solution: Two Options**

### **Option 1: CloudFront (Recommended for HTTPS)**

#### Step 1: Create CloudFront Distribution

```bash
# Run the setup script
chmod +x setup-cloudfront-mumbai.sh
./setup-cloudfront-mumbai.sh
```

This will:
- Create CloudFront distribution
- Enable HTTPS automatically
- Provide a CloudFront domain
- Give you a CNAME to use in Hostinger

#### Step 2: Configure in Hostinger

**For Frontend (Widget):**
```
Type: CNAME
Name: callribbon
Value: <CloudFront Domain from script>
TTL: 3600
```

**Result:** https://callribbon.yourdomain.com

---

### **Option 2: Direct CNAME (HTTP only, No SSL)**

If you don't need HTTPS immediately, use direct CNAME:

#### For Frontend Widget:

**In Hostinger DNS:**
```
Type: CNAME
Name: callribbon
Value: intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com
TTL: 3600
```

**Result:** http://callribbon.yourdomain.com (HTTP only)

#### For API Backend:

**In Hostinger DNS:**
```
Type: CNAME
Name: api
Value: production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
TTL: 3600
```

**Result:** http://api.yourdomain.com

---

## 🔧 **Step-by-Step: Hostinger Configuration**

### Step 1: Login to Hostinger

1. Go to https://hostinger.com
2. Login to your account
3. Go to **Domains** → Select your domain
4. Click **DNS / Nameservers**

### Step 2: Add CNAME Record for Frontend

```
Record Type: CNAME
Name/Host: callribbon
Value/Points to: intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com
TTL: 3600 (or Auto)
```

### Step 3: Add CNAME Record for API (Optional)

```
Record Type: CNAME
Name/Host: api-callribbon
Value/Points to: production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
TTL: 3600 (or Auto)
```

### Step 4: Save and Wait

- DNS propagation: 5-60 minutes
- Check status: https://dnschecker.org

---

## 🔒 **Adding HTTPS (Required for Production)**

### Option A: CloudFront (AWS)

**Pros:**
- Free SSL certificate via AWS
- Global CDN
- Better performance
- Easy to setup

**Setup:**
1. Run `./setup-cloudfront-mumbai.sh`
2. Wait 15-20 minutes for deployment
3. Update Hostinger CNAME to CloudFront domain
4. Access via HTTPS

### Option B: Hostinger SSL

**Pros:**
- Managed by Hostinger
- Simple configuration

**Cons:**
- May not work with CNAME to AWS
- Limited to Hostinger's capabilities

**Setup:**
1. In Hostinger, go to SSL
2. Select "Let's Encrypt" or purchase SSL
3. Apply to your subdomain

---

## 📝 **Complete Hostinger DNS Configuration**

Here's what your Hostinger DNS should look like:

```
Type    Name                Value                                                                           TTL
────────────────────────────────────────────────────────────────────────────────────────────────────────────────
CNAME   callribbon          intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1...       3600
CNAME   api-callribbon      production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com                3600
```

**Access:**
- Widget: http://callribbon.yourdomain.com
- API: http://api-callribbon.yourdomain.com

---

## 🧪 **Testing Your Configuration**

### Step 1: Check DNS Propagation

```bash
# Check if DNS is resolving
dig callribbon.yourdomain.com CNAME

# Or use online tool
# Visit: https://dnschecker.org
```

### Step 2: Test HTTP Access

```bash
# Test frontend
curl -I http://callribbon.yourdomain.com

# Test API
curl http://api-callribbon.yourdomain.com/health
```

### Step 3: Browser Test

1. Open browser
2. Visit: http://callribbon.yourdomain.com
3. Click a test customer
4. Verify call controls work

---

## ⚡ **Quick Setup (No CloudFront)**

If you want to test quickly without HTTPS:

### 1. Run this command to get exact DNS values:

```bash
echo "Frontend CNAME: intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com"
echo "API CNAME: production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com"
```

### 2. In Hostinger, add these CNAME records:

| Type | Name | Value |
|------|------|-------|
| CNAME | callribbon | intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com |
| CNAME | api-callribbon | production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com |

### 3. Wait 5-30 minutes for DNS propagation

### 4. Test:
```
http://callribbon.yourdomain.com
```

---

## 🚀 **Production-Ready Setup (With HTTPS)**

### Step 1: Create CloudFront Distribution

```bash
chmod +x setup-cloudfront-mumbai.sh
./setup-cloudfront-mumbai.sh
```

**Output will give you:**
- CloudFront Domain (e.g., `d123abc.cloudfront.net`)
- CNAME value to use

### Step 2: Request SSL Certificate (AWS Certificate Manager)

```bash
# Request certificate for your domain
aws acm request-certificate \
  --domain-name callribbon.yourdomain.com \
  --validation-method DNS \
  --region us-east-1
```

**Note:** Certificates for CloudFront must be in `us-east-1` region!

### Step 3: Verify Domain

1. AWS will provide DNS records to add
2. Add these to Hostinger DNS
3. Wait for validation (5-30 minutes)

### Step 4: Update CloudFront with Certificate

```bash
# Associate certificate with distribution
# (Use AWS Console or CLI)
```

### Step 5: Update Hostinger DNS

```
Type: CNAME
Name: callribbon
Value: <your-cloudfront-domain>.cloudfront.net
TTL: 3600
```

### Step 6: Access via HTTPS

```
https://callribbon.yourdomain.com
```

---

## 🎯 **What I Recommend Right Now:**

### For Testing (Quick - 10 minutes):

1. **Add CNAME in Hostinger:**
   ```
   Name: callribbon
   Value: intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com
   ```

2. **Wait 5-30 minutes**

3. **Test:** http://callribbon.yourdomain.com

### For Production (Proper - 1 hour):

1. **Run CloudFront setup script**
2. **Get CloudFront domain**
3. **Request SSL certificate**
4. **Update DNS with CloudFront**
5. **Access via HTTPS**

---

## 📞 **Need Help?**

### Check Current Setup:

```bash
# Check what's currently deployed
curl -I http://intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com

# Check API
curl http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/health
```

### Common Issues:

**DNS not resolving:**
- Wait longer (up to 48 hours, usually 5-30 min)
- Check DNS propagation: https://dnschecker.org
- Verify CNAME value is correct

**SSL errors:**
- Use CloudFront for HTTPS
- Direct S3 doesn't support custom SSL

**API CORS errors:**
- Update backend CORS to allow your domain
- Redeploy API with new domain in allowed origins

---

## 📋 **Summary: What You Need to Do**

1. **Choose your domain** (e.g., `callribbon.yourdomain.com`)

2. **Add in Hostinger DNS:**
   ```
   Type: CNAME
   Name: callribbon  
   Value: intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com
   TTL: 3600
   ```

3. **Wait** 5-30 minutes for DNS propagation

4. **Test:** http://callribbon.yourdomain.com

5. **For HTTPS** (optional but recommended):
   - Run `./setup-cloudfront-mumbai.sh`
   - Update CNAME to CloudFront domain
   - Request SSL certificate

---

**Note:** Since S3 and Elastic Beanstalk don't provide static IPs, you **cannot use A records**. You **must use CNAME records** in Hostinger.

Would you like me to help you set up CloudFront for HTTPS, or would you prefer to start with the simple HTTP CNAME setup first?

