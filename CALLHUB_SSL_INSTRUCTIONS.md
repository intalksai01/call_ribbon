# 🔒 callhub.intalksai.com - SSL Certificate Setup

## ✅ **Certificate Requested Successfully!**

Certificate ARN: `arn:aws:acm:us-east-1:844605843483:certificate/fa9fae7d-7fa0-4f6e-b06a-4d4e878047cd`

---

## 🎯 **ACTION REQUIRED: Add DNS Validation Record**

### **Go to Hostinger DNS Settings and ADD this CNAME record:**

```
Type: CNAME
Name: _2fd57b26579e6e2e4cf547d9b0249c43.callhub
Value: _cf32309fcbdbd876a393d89d4362351a.xlfgrmvvlj.acm-validations.aws.
TTL: 3600
```

### **Important Notes:**
- This is IN ADDITION to your existing callhub CNAME
- This record is for SSL certificate validation only
- AWS will check this record to verify you own the domain

---

## 📋 **Current DNS Configuration:**

### **Existing Record (keep this):**
```
Type: CNAME
Name: callhub
Value: d2t5fsybshqnye.cloudfront.net
TTL: 3600
```

### **New Record (add this):**
```
Type: CNAME
Name: _2fd57b26579e6e2e4cf547d9b0249c43.callhub
Value: _cf32309fcbdbd876a393d89d4362351a.xlfgrmvvlj.acm-validations.aws.
TTL: 3600
```

---

## ⏱️ **Timeline:**

1. **Add DNS Record** → 2 minutes (in Hostinger)
2. **DNS Propagation** → 5-10 minutes
3. **AWS Validation** → 5-30 minutes
4. **Update CloudFront** → 5 minutes (automated)
5. **CloudFront Deployment** → 15-20 minutes

**Total Time: ~30-60 minutes**

---

## 🔍 **Check Certificate Status:**

Run this command to check if validation is complete:

```bash
aws acm describe-certificate \
  --certificate-arn arn:aws:acm:us-east-1:844605843483:certificate/fa9fae7d-7fa0-4f6e-b06a-4d4e878047cd \
  --region us-east-1 | jq '.Certificate.Status'
```

**Status Values:**
- `"PENDING_VALIDATION"` - Waiting (keep waiting)
- `"ISSUED"` - Ready! ✅ (proceed to next step)
- `"FAILED"` - Error (contact support)

---

## 🚀 **Next Steps After Validation:**

### **Step 1: Wait for Certificate to be ISSUED**

Keep checking status every 5 minutes:
```bash
aws acm describe-certificate \
  --certificate-arn arn:aws:acm:us-east-1:844605843483:certificate/fa9fae7d-7fa0-4f6e-b06a-4d4e878047cd \
  --region us-east-1 | jq '.Certificate.Status'
```

### **Step 2: Update CloudFront (Automated)**

Once certificate shows `"ISSUED"`, run:
```bash
cd /Users/arun/cursor/call_control/exotel-call-ribbon
./update-cloudfront-with-ssl.sh
```

I'll create this script for you now...

---

## 🧪 **Testing:**

### **Before SSL (works now):**
```bash
# CloudFront direct domain
http://d2t5fsybshqnye.cloudfront.net
https://d2t5fsybshqnye.cloudfront.net ✅
```

### **After SSL (will work after setup):**
```bash
# Your custom domain
http://callhub.intalksai.com ✅
https://callhub.intalksai.com ✅
```

---

## 📞 **Quick Commands:**

```bash
# Check certificate status
aws acm describe-certificate --certificate-arn arn:aws:acm:us-east-1:844605843483:certificate/fa9fae7d-7fa0-4f6e-b06a-4d4e878047cd --region us-east-1 | jq '.Certificate.Status'

# Check DNS validation record
dig _2fd57b26579e6e2e4cf547d9b0249c43.callhub.intalksai.com CNAME +short

# Test CloudFront (works now)
curl -I https://d2t5fsybshqnye.cloudfront.net

# Test custom domain (will work after setup)
curl -I https://callhub.intalksai.com
```

---

## ✅ **Checklist:**

- [x] SSL certificate requested
- [ ] **→ Add DNS validation record in Hostinger** ← **DO THIS NOW**
- [ ] Wait for DNS propagation (5-10 min)
- [ ] Wait for AWS validation (5-30 min)
- [ ] Check certificate status (should be "ISSUED")
- [ ] Run update script to configure CloudFront
- [ ] Wait for CloudFront deployment (15-20 min)
- [ ] Test https://callhub.intalksai.com

---

## 📝 **Summary:**

**What to do RIGHT NOW:**
1. Login to Hostinger
2. Go to DNS settings for intalksai.com
3. Add new CNAME record:
   - Name: `_2fd57b26579e6e2e4cf547d9b0249c43.callhub`
   - Value: `_cf32309fcbdbd876a393d89d4362351a.xlfgrmvvlj.acm-validations.aws.`
4. Save
5. Wait and check status with the command above

---

*Detailed configuration saved in: callhub-ssl-setup.txt*

