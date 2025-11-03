# 🚀 AWS Deployment Ready

## Production-Ready Version

All changes have been made to deploy the updated production version to AWS.

### ✅ Changes Made

1. **Updated `api/package.json`**
   - Main entry point: `unified-server.js` (was `server.js`)
   - Start command: `node unified-server.js`
   - All analytics endpoints implemented

2. **Widget Rebuilt**
   - Latest production build created
   - New Exotel credentials (`arunbecs`) integrated
   - All demo/test code removed

3. **Analytics APIs Implemented**
   - ✅ `/api/ribbon/analytics` - Summary analytics
   - ✅ `/api/ribbon/analytics/detailed` - Detailed analytics
   - ✅ `/api/ribbon/call-logs` - Paginated call logs
   - ✅ `/api/ribbon/customer/:customerId/calls` - Customer history
   - ✅ `/api/ribbon/export/calls` - CSV/JSON export
   - ✅ `/api/health` - Health check
   - ✅ `/api/admin/stats` - Admin dashboard

4. **Exotel Integration**
   - Working credentials: `laksh` + virtual number `08044318948`
   - SIP registration working ✅
   - Calls successfully connecting ✅
   - Firewall whitelisting documented ✅
   - Deployed to AWS Mumbai ✅

5. **Documentation**
   - Exotel firewall whitelist requirements documented
   - TRAI DND error troubleshooting added
   - Testing procedures documented

---

## Deploy to AWS Mumbai

### Option 1: Using Deployment Script

```bash
cd /Users/arun/cursor/MIT/call_ribbon
./deploy-api-mumbai.sh
```

### Option 2: Manual Deployment

```bash
cd api
eb init intalksai-call-ribbon-api --region ap-south-1 --platform "Node.js 18 running on 64bit Amazon Linux 2023"
eb deploy production-mumbai --region ap-south-1
```

---

## Current AWS Configuration

- **Region:** Mumbai (ap-south-1)
- **Application:** `intalksai-call-ribbon-api`
- **Environment:** `production-mumbai`
- **URL:** `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com`

### Existing Environment Variables
- `NODE_ENV=production`
- `CORS_ORIGINS=*`
- `PORT` (set automatically by EB)

---

## Test After Deployment

### 1. Health Check
```bash
curl http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/health
```

### 2. Analytics API
```bash
curl -H "x-api-key: demo-api-key-999" \
  http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics
```

### 3. Call Logs
```bash
curl -H "x-api-key: demo-api-key-999" \
  http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/call-logs
```

### 4. Widget Demo
Visit: `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com`

---

## Available API Keys (Production)

1. **demo-api-key-999** - Real Exotel Test
   - User ID: `laksh`
   - Virtual Number: `08044318948`
   - Limit: 5000 calls/month
   - All domains

2. **real-exotel-api-key** - Real Exotel Client
   - User ID: `laksh`
   - Virtual Number: `08044318948`
   - Limit: 5000 calls/month
   - All domains

3. **collections-crm-api-key-123** - Enterprise
   - Limit: 10000 calls/month
   - Allowed domains: collections-crm.com, localhost

4. **marketing-leads-api-key-456** - Professional
   - Limit: 5000 calls/month
   - Allowed domains: marketing-crm.com, localhost

---

## What's New vs Old Version

### Old Version (Current in AWS)
- Used `server.js` with limited endpoints
- No analytics APIs
- No customer call history
- No export functionality

### New Version (Ready to Deploy)
- ✅ Unified server (`unified-server.js`)
- ✅ Widget integrated in same server
- ✅ Complete analytics suite
- ✅ Customer call history
- ✅ CSV/JSON export
- ✅ Working Exotel integration
- ✅ Enhanced logging
- ✅ All test code removed

---

## Management Commands

```bash
# View logs
eb logs production-mumbai --region ap-south-1

# Check status
eb status production-mumbai --region ap-south-1

# SSH access
eb ssh production-mumbai --region ap-south-1

# Deploy update (after making changes)
eb deploy production-mumbai --region ap-south-1

# Terminate (if needed)
eb terminate production-mumbai --region ap-south-1
```

---

## Database Integration (Optional)

**Status:** PostgreSQL RDS database created and ready  
**Endpoint:** `intalksai-call-ribbon-db.cviea4aicss0.ap-south-1.rds.amazonaws.com:5432`  
**Database:** `call_ribbon_db`  
**Schema:** `schema-simplified.sql`

### To Enable Database

1. **Set environment variable in Elastic Beanstalk:**
   ```bash
   eb setenv DATABASE_URL="postgresql://call_ribbon_admin:9AYVOZVXas6tiAz3vYAqZM1NS@intalksai-call-ribbon-db.cviea4aicss0.ap-south-1.rds.amazonaws.com:5432/call_ribbon_db" --region ap-south-1
   ```

2. **Initialize schema (if not done):**
   ```bash
   psql -h intalksai-call-ribbon-db.cviea4aicss0.ap-south-1.rds.amazonaws.com -U call_ribbon_admin -d call_ribbon_db -f database/schema-simplified.sql
   ```

3. **Redeploy:**
   ```bash
   eb deploy production-mumbai --region ap-south-1
   ```

**Note:** The server will automatically detect the database and switch from in-memory to database-backed storage.

---

## Next Steps

1. ✅ Code is production-ready
2. ⏳ Deploy to AWS using one of the methods above
3. ⏳ Test all endpoints after deployment
4. ⏳ Optional: Enable database integration
5. ⏳ Update any client code to use new analytics APIs
6. ⏳ Monitor logs for any issues

---

## Rollback Plan

If deployment has issues, you can:
1. Check logs: `eb logs production-mumbai --region ap-south-1`
2. SSH into instance: `eb ssh production-mumbai --region ap-south-1`
3. Revert deployment: `eb deploy production-mumbai --version LABEL --region ap-south-1`

---

---

## 🎉 Deployment Complete!

**Status:** ✅ **Successfully Deployed to Production**

### Production URLs

#### Widget (CloudFront + S3)
- **S3 Bucket:** `intalksai-call-ribbon-widget-mumbai-1760280743`
- **CloudFront URL:** `https://d2t5fsybshqnye.cloudfront.net` ⚠️ **HTTPS - Has mixed content issue**
- **S3 Website URL:** `http://intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com` ✅ **Use This for Testing (HTTP only)**

#### API (Elastic Beanstalk)
- **Environment:** `production-mumbai`
- **URL:** `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com`
- **Health:** ✅ Green
- **Platform:** Node.js 22
- **Version:** `app-251102_145942314120`

### Test the Deployment

1. **Widget Demo (Use S3 HTTP URL for Testing):**
   ```bash
   open http://intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com
   ```
   
   ⚠️ **IMPORTANT - HTTPS Mixed Content Issue:**
- ✅ **API Health Fixed:** Elastic Beanstalk health check now working
- ⚠️ **Widget Issue:** Widget runs on HTTPS but API is HTTP
- Browsers block HTTP API calls from HTTPS widget pages
- **Solution:** Enable HTTPS on Elastic Beanstalk (requires ALB + SSL certificate)

**Next Steps:**
1. Request SSL certificate for Elastic Beanstalk in AWS Console
2. Configure Application Load Balancer with HTTPS listener
3. Update widget API URL to use HTTPS

**✅ WORKAROUND:** Use the S3 Website URL (`http://intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com`) to avoid mixed content issues.

2. **Health Check:**
   ```bash
   curl http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/health
   ```

3. **Analytics API:**
   ```bash
   curl -H "x-api-key: demo-api-key-999" \
     http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics
   ```

---

## ⚠️ Important: Firewall Whitelisting Required

For Exotel WebRTC calls to work properly, the following firewall rules must be configured:

**See:** [docs/EXOTEL_FIREWALL_WHITELIST.md](docs/EXOTEL_FIREWALL_WHITELIST.md) for complete details.

### Quick Reference:
| Type | Port/Endpoint |
|------|---------------|
| HTTP | tcp/80 |
| HTTPS / TLS | tcp/443 |
| SIP Gateway | `voip.in1.exotel.com` |
| Media Server Ports | udp/10000 - 40000 |
| Media Server IP - Mumbai | `182.76.143.61`, `122.15.8.18` |
| API | `integrationscore.mum1.exotel.com` |

**Reference:** [Exotel Documentation](https://support.exotel.com/support/solutions/articles/3000120566-ip-pstn-intermix-customer-onboarding-and-webrtc-sdk-integration)

---

**✅ Production Deployment Complete! 🚀**

