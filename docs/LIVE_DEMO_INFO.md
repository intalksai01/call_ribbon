# 🚀 Live Demo Information

## 📍 Deployed Demo Applications

### Mumbai Region (Recommended for India)
**Live Demo URL:** [http://intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com](http://intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com)

**Region:** ap-south-1 (Asia Pacific - Mumbai)  
**Status:** ✅ **LIVE and ACTIVE**  
**Latency:** Lower latency for users in India/Asia

### US East Region
**Live Demo URL:** [https://intalksai-call-ribbon-widget-844605843483.s3.us-east-1.amazonaws.com/index.html](https://intalksai-call-ribbon-widget-844605843483.s3.us-east-1.amazonaws.com/index.html)

**Region:** us-east-1 (US East - N. Virginia)  
**Status:** ✅ **LIVE and ACTIVE**  
**Latency:** Lower latency for users in Americas/Europe

---

## 🔑 Demo API Key Configuration

The deployed demo uses the following configuration:

```javascript
ExotelCallRibbon.init({
  apiKey: 'demo-api-key-789',
  apiUrl: 'http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com',
  position: 'bottom',
  onCallEvent: function(event, data) {
    console.log('Call event:', event, data);
  }
});
```

### API Key Details

**Client API Key:** `demo-api-key-789`

**Configuration:**
- **Client Name:** Demo Client
- **Plan:** Trial
- **Features:** call, mute, hold, dtmf
- **Monthly Limit:** 100 calls
- **Allowed Domains:** `*` (ALL domains - perfect for demos!)
- **Current Usage:** Check at API endpoint

---

## 🌐 Infrastructure Details

### Widget Hosting (Frontend)

**Mumbai Deployment:**
```
Service: AWS S3 Static Website Hosting
Region: ap-south-1 (Mumbai)
Bucket: intalksai-call-ribbon-widget-mumbai-1760280743
URL: http://intalksai-call-ribbon-widget-mumbai-1760280743.s3-website.ap-south-1.amazonaws.com
Access: Public Read
Deployment: Automatic via deploy-mumbai.sh
```

**US East Deployment:**
```
Service: AWS S3 Static Website Hosting
Region: us-east-1 (US East)
Bucket: intalksai-call-ribbon-widget-844605843483
URL: https://intalksai-call-ribbon-widget-844605843483.s3.us-east-1.amazonaws.com/
Access: Public Read
```

### API Backend
```
Service: AWS Elastic Beanstalk
Region: us-east-1 (US East)
Environment: production
URL: http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com
API Endpoints: /api/ribbon/*
```

---

## 👥 Test Customers Available in Demo

The demo includes 6 pre-configured test customers:

### 1. John Doe
- **Phone:** +91 987 654 3210
- **Use Case:** Collections CRM
- **Details:** Outstanding $5,000 | 15 days overdue

### 2. Jane Smith
- **Phone:** +91 876 543 2109
- **Use Case:** Marketing CRM
- **Details:** Lead for Premium Plan | Hot prospect

### 3. Bob Johnson
- **Phone:** +91 765 432 1098
- **Use Case:** Support CRM
- **Details:** Ticket #1234: Login Issue | High priority

### 4. Alice Williams
- **Phone:** +91 998 877 6655
- **Use Case:** Enterprise Client
- **Details:** Enterprise Client | Annual contract

### 5. Charlie Brown
- **Phone:** +91 887 766 5544
- **Use Case:** Hot Lead
- **Details:** Hot Lead | Requested demo yesterday

### 6. Diana Prince
- **Phone:** +91 776 655 4433
- **Use Case:** VIP Customer
- **Details:** VIP Customer | Lifetime value: $50K

---

## 🧪 How to Test the Demo

### Step 1: Open the Demo
Visit: [https://intalksai-call-ribbon-widget-844605843483.s3.us-east-1.amazonaws.com/index.html](https://intalksai-call-ribbon-widget-844605843483.s3.us-east-1.amazonaws.com/index.html)

### Step 2: Wait for Widget Load
- The page will show "Loading widget..."
- Widget initializes with API key `demo-api-key-789`
- Look for the call control ribbon at the bottom

### Step 3: Select a Customer
Click on any customer card to:
- Load customer details into the ribbon
- Pre-fill phone number
- Enable dial button

### Step 4: Test Call Features
1. **Dial** - Click the dial button or press Ctrl+D
2. **Mute** - Toggle mute during call
3. **Hold** - Put call on hold
4. **DTMF** - Open keypad for DTMF tones
5. **Drag** - Drag the ribbon to reposition
6. **Hangup** - End the call

### Step 5: Check Console
Open browser DevTools (F12) to see:
- Widget initialization logs
- Call event logs
- API request/response logs

---

## 🔌 API Endpoints for Demo

### Base URL
```
http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com
```

### Available Endpoints

#### 1. Initialize Ribbon
```bash
POST /api/ribbon/init
Content-Type: application/json

{
  "apiKey": "demo-api-key-789",
  "domain": "amazonaws.com"
}
```

#### 2. Log Call Events
```bash
POST /api/ribbon/log-call
Content-Type: application/json

{
  "apiKey": "demo-api-key-789",
  "event": "connected",
  "data": {...},
  "timestamp": "2024-01-15T10:30:00Z",
  "domain": "amazonaws.com"
}
```

#### 3. Get Configuration
```bash
GET /api/ribbon/config
X-API-Key: demo-api-key-789
```

#### 4. Get Analytics
```bash
GET /api/ribbon/analytics
X-API-Key: demo-api-key-789
```

#### 5. Health Check
```bash
GET /health
```

---

## 🔐 Security Features in Demo

### What's Secure
✅ API key used: `demo-api-key-789` (safe for public demos)
✅ Domain restriction: `*` (allows testing from anywhere)
✅ Usage limit: 100 calls/month (prevents abuse)
✅ Exotel credentials: Managed server-side (never exposed)
✅ HTTPS for widget: S3 serves over HTTPS
✅ Call logging: All events tracked

### What to Note
⚠️ Backend API URL is HTTP (for demo only)
⚠️ Demo API key is public (intentional for testing)
⚠️ Usage limit: 100 calls/month (may reset or hit limit)

**For Production:** 
- Use HTTPS for API endpoints
- Use private Client API keys
- Configure domain restrictions
- Set appropriate usage limits

---

## 📊 Testing Checklist

Use this checklist when testing the demo:

- [ ] **Page Loads:** Demo page loads without errors
- [ ] **Widget Init:** Ribbon appears at bottom of page
- [ ] **Customer Select:** Clicking customer loads phone number
- [ ] **Dial Button:** Dial button becomes active
- [ ] **Call Connect:** Clicking dial initiates demo call
- [ ] **Call Timer:** Timer starts and counts up
- [ ] **Mute Toggle:** Mute button works (visual feedback)
- [ ] **Hold Toggle:** Hold button works (visual feedback)
- [ ] **DTMF Keypad:** Keypad shows when clicked
- [ ] **Drag Feature:** Ribbon can be dragged around screen
- [ ] **Hangup:** Hangup button ends call
- [ ] **Console Logs:** No JavaScript errors in console
- [ ] **API Calls:** Network tab shows successful API calls

---

## 🐛 Known Issues & Limitations

### Current Limitations
1. **Demo Mode Only:** Widget runs in demo mode (no real Exotel calls)
2. **HTTP Backend:** API backend uses HTTP (not HTTPS) for simplicity
3. **Shared API Key:** Same demo key used by all testers
4. **Call Limit:** 100 calls/month shared across all users
5. **No Persistence:** Call logs don't persist (in-memory only)

### Expected Behavior
- Call connects after 2-second delay (simulated)
- Timer runs locally (not real call duration)
- All buttons work with visual feedback
- Events logged to console and backend

### Not a Bug
- "Demo mode" messages in console - **Expected**
- Simulated call connection - **Expected**
- No real audio - **Expected** (demo mode)
- Fast call connection - **Expected** (no real telephony)

---

## 🔄 Updating the Demo

### To Update Widget Code
1. Make changes in `/widget/src/`
2. Build: `cd widget && npm run build`
3. Deploy: Upload `widget/build/*` to S3 bucket
4. Clear browser cache to see changes

### To Update Backend
1. Make changes in `/api/server.js`
2. Deploy to Elastic Beanstalk:
   ```bash
   cd api
   eb deploy production
   ```
3. Verify at: http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com/health

### Cache Busting
The demo uses cache-busting query parameters:
```html
<script src="/static/js/main.17ec7931.js?v=1759690234"></script>
```
Increment version number when updating.

---

## 📱 Mobile Testing

The demo is mobile responsive. Test on:

### Browsers
- ✅ Chrome (Desktop & Mobile)
- ✅ Safari (Desktop & Mobile)
- ✅ Firefox (Desktop & Mobile)
- ✅ Edge (Desktop)

### Devices
- ✅ Desktop (1920x1080, 1366x768)
- ✅ Tablet (iPad, 768x1024)
- ✅ Mobile (iPhone, Android, 375x667)

### Mobile Features
- Touch-friendly buttons
- Drag support (touch events)
- Responsive layout
- Auto-minimize on small screens

---

## 🎯 Demo Use Cases

### For Sales Demos
1. Show live widget integration
2. Demonstrate call controls
3. Highlight security (client API key only)
4. Show event callbacks
5. Demonstrate mobile responsiveness

### For Client Onboarding
1. Let clients test before integration
2. Show expected behavior
3. Verify phone number formats
4. Test on their devices/browsers
5. Review call events

### For Development Testing
1. Test widget changes before production
2. Verify API endpoint responses
3. Debug integration issues
4. Test new features
5. Performance testing

---

## 📞 Support & Resources

### Documentation
- **Integration Guide:** `/docs/CLIENT_INTEGRATION_GUIDE.md`
- **Architecture:** `/docs/ARCHITECTURE_DIAGRAM.md`
- **Deployment:** `/docs/DEPLOYMENT.md`

### API Endpoints
- **Widget Demo:** [https://intalksai-call-ribbon-widget-844605843483.s3.us-east-1.amazonaws.com/index.html](https://intalksai-call-ribbon-widget-844605843483.s3.us-east-1.amazonaws.com/index.html)
- **Backend API:** http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com
- **Health Check:** http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com/health

### Quick Test cURL Commands

```bash
# Test health endpoint
curl http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com/health

# Test init endpoint
curl -X POST http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com/api/ribbon/init \
  -H "Content-Type: application/json" \
  -d '{"apiKey":"demo-api-key-789","domain":"amazonaws.com"}'

# Get configuration
curl http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com/api/ribbon/config \
  -H "X-API-Key: demo-api-key-789"

# Get analytics
curl http://production.eba-tpbtmere.us-east-1.elasticbeanstalk.com/api/ribbon/analytics \
  -H "X-API-Key: demo-api-key-789"
```

---

## 🚀 Next Steps

### For Clients
1. ✅ Test the live demo
2. ✅ Review integration guide
3. ✅ Get your production API key
4. ✅ Configure domain whitelist
5. ✅ Integrate into your CRM

### For Development
1. Test on different browsers/devices
2. Verify all API endpoints
3. Check error handling
4. Monitor usage metrics
5. Prepare for production migration

### For Production
1. Migrate to HTTPS backend
2. Set up CloudFront CDN
3. Configure custom domain
4. Enable monitoring/logging
5. Set up billing/usage tracking

---

## 📝 Quick Reference

```
┌────────────────────────────────────────────────────────────┐
│  IntalksAI Call Control Ribbon - Live Demo                 │
├────────────────────────────────────────────────────────────┤
│  Demo URL:                                                  │
│  https://intalksai-call-ribbon-widget-844605843483         │
│  .s3.us-east-1.amazonaws.com/index.html                     │
│                                                              │
│  API Key: demo-api-key-789                                  │
│  Backend: production.eba-tpbtmere.us-east-1                │
│           .elasticbeanstalk.com                             │
│                                                              │
│  Features:                                                   │
│  ✅ 6 Test customers                                        │
│  ✅ Full call controls (dial, mute, hold, DTMF)            │
│  ✅ Drag & drop positioning                                 │
│  ✅ Mobile responsive                                       │
│  ✅ Event logging                                           │
│  ✅ Demo mode (no real calls)                              │
│                                                              │
│  Usage Limit: 100 calls/month                               │
│  Domain Restriction: None (works everywhere)                │
└────────────────────────────────────────────────────────────┘
```

---

*Last updated: January 2024*
*Demo Environment: AWS us-east-1*

