# 🚀 call-ribbon.intalksai.com - Setup Guide

## 📋 **Your Domain:** call-ribbon.intalksai.com

---

## ✅ **What You Need to Do in Hostinger:**

### Update CNAME Record:

```
Type: CNAME
Name: call-ribbon
Value: d2t5fsybshqnye.cloudfront.net
TTL: 3600
```

### Current Status:
```
❌ Current Value: intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com
✅ Change To: d2t5fsybshqnye.cloudfront.net
```

---

## 📝 **Step-by-Step Instructions**

### Step 1: Login to Hostinger

1. Go to https://hostinger.com
2. Login to your account
3. Navigate to **Domains**
4. Select **intalksai.com**
5. Click **DNS Zone** or **DNS Settings**

### Step 2: Edit CNAME Record

1. Find the CNAME record for **call-ribbon**
2. Click **Edit** or **Modify**
3. Change the **Value** field from:
   ```
   intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com
   ```
   To:
   ```
   d2t5fsybshqnye.cloudfront.net
   ```
4. Keep **TTL** as 3600 (or Auto)
5. Click **Save** or **Update**

### Step 3: Wait for DNS Propagation

- **Time:** 5-30 minutes (usually 5-10 minutes)
- **Check progress:** https://dnschecker.org

### Step 4: Verify

```bash
# Check DNS
dig call-ribbon.intalksai.com CNAME +short

# Should show:
d2t5fsybshqnye.cloudfront.net
```

---

## 🧪 **Testing Your Domain**

### After DNS Update:

```bash
# Test HTTP
curl -I http://call-ribbon.intalksai.com

# Test HTTPS
curl -I https://call-ribbon.intalksai.com

# Open in browser
open http://call-ribbon.intalksai.com
```

**Expected Result:** Demo page with 6 test customers

---

## 📊 **CloudFront Details**

```
Distribution ID: E23RHJVEDGE3B2
CloudFront Domain: d2t5fsybshqnye.cloudfront.net
Status: Deployed ✅

Your Custom Domain: call-ribbon.intalksai.com
Backend API: http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
```

---

## 🔒 **HTTPS Support**

Good news! HTTPS is already enabled:
- ✅ http://call-ribbon.intalksai.com
- ✅ https://call-ribbon.intalksai.com

Both will work after DNS update!

---

## 🎯 **Visual Guide: What to Change in Hostinger**

```
==================================================
Hostinger DNS Manager
==================================================

BEFORE (Current - Not Working):
--------------------------------------------------
Record Type: CNAME
Name/Host: call-ribbon
Points to: intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com
TTL: 3600
--------------------------------------------------

AFTER (Change To - Will Work):
--------------------------------------------------
Record Type: CNAME
Name/Host: call-ribbon
Points to: d2t5fsybshqnye.cloudfront.net
TTL: 3600
--------------------------------------------------
```

---

## ⏱️ **Timeline**

### Right Now:
- CloudFront: ✅ Deployed and ready
- DNS: ❌ Still pointing to old S3 address

### After You Update DNS:
- DNS Update: Immediate in Hostinger
- Propagation: 5-30 minutes
- Testing: ✅ Can access call-ribbon.intalksai.com

---

## 🔍 **How to Check If It's Working**

### Method 1: Command Line
```bash
dig call-ribbon.intalksai.com CNAME +short
```
**Should return:** `d2t5fsybshqnye.cloudfront.net`

### Method 2: Online Tool
1. Visit: https://dnschecker.org
2. Enter: `call-ribbon.intalksai.com`
3. Select: `CNAME`
4. Check if it shows CloudFront domain globally

### Method 3: Browser Test
```
http://call-ribbon.intalksai.com
```
**Should show:** IntalksAI Call Ribbon Demo page

---

## 🎊 **What You'll Get After Setup**

### Working URLs:
```
✅ http://call-ribbon.intalksai.com
✅ https://call-ribbon.intalksai.com
```

### Features:
- 6 Test customers
- Full call controls (dial, mute, hold, DTMF)
- Drag & drop positioning
- Mobile responsive
- Demo mode (no real calls)

### Performance:
- Fast loading via CloudFront CDN
- HTTPS encrypted
- Low latency globally
- Cached content

---

## 🐛 **Troubleshooting**

### Issue: Still getting "NoSuchBucket" error

**Cause:** DNS not updated yet or propagation pending

**Fix:**
1. Verify you changed the CNAME in Hostinger
2. Wait 5-30 minutes
3. Clear browser cache
4. Try incognito/private mode

### Issue: DNS not resolving

**Cause:** Propagation delay or typo in CloudFront domain

**Fix:**
1. Double-check the value: `d2t5fsybshqnye.cloudfront.net`
2. Wait longer (up to 48 hours max)
3. Check on https://dnschecker.org

### Issue: Works on HTTP but not HTTPS

**Cause:** Browser certificate warning

**Fix:** This is normal with CloudFront default cert. Click "Advanced" → "Proceed" or setup custom SSL certificate

---

## 📞 **Quick Commands**

```bash
# Check DNS
dig call-ribbon.intalksai.com CNAME

# Test domain
curl -I http://call-ribbon.intalksai.com

# Check CloudFront status
aws cloudfront get-distribution --id E23RHJVEDGE3B2 | jq '.Distribution.Status'

# Clear CloudFront cache (if needed)
aws cloudfront create-invalidation --distribution-id E23RHJVEDGE3B2 --paths "/*"
```

---

## ✅ **Checklist**

- [x] CloudFront distribution created (E23RHJVEDGE3B2)
- [x] CloudFront deployed and ready
- [ ] **Update Hostinger DNS CNAME** ← YOU ARE HERE
- [ ] Wait 5-30 minutes for DNS propagation
- [ ] Test http://call-ribbon.intalksai.com
- [ ] Test https://call-ribbon.intalksai.com
- [ ] Share link with team/clients

---

## 📋 **Summary**

**Domain:** call-ribbon.intalksai.com  
**Action Needed:** Update Hostinger CNAME value  
**Change To:** d2t5fsybshqnye.cloudfront.net  
**Time:** 5 minutes to update, 5-30 min DNS propagation  
**Result:** Working demo with HTTPS support  

---

## 🎯 **Copy-Paste Values for Hostinger**

```
Name: call-ribbon
Value: d2t5fsybshqnye.cloudfront.net
```

---

*Once DNS is updated, access your demo at: http://call-ribbon.intalksai.com*

