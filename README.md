# 📞 IntalksAI Call Ribbon

> Embeddable call control widget for CRM applications powered by Exotel

[![Status](https://img.shields.io/badge/status-production-brightgreen)]()
[![Version](https://img.shields.io/badge/version-1.0.0-blue)]()
[![Region](https://img.shields.io/badge/region-Mumbai_(ap--south--1)-orange)]()

---

## 🎯 What is Call Ribbon?

IntalksAI Call Ribbon is a plug-and-play widget that adds professional calling capabilities to any web application. Perfect for CRMs, helpdesks, and customer management systems.

### Key Features:
- ✅ **One-line integration** - Add to any webpage
- ✅ **Automatic call analytics** - Track every call with rich context
- ✅ **No credential management** - We handle Exotel tokens securely
- ✅ **Flexible context tracking** - Send any business data you need
- ✅ **Professional UI** - Modern, draggable call controls
- ✅ **Mobile responsive** - Works on all devices

---

## 🚀 Quick Start (3 Minutes)

### 1. Include the Widget

```html
<script src="https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js"></script>
```

### 2. Initialize

```javascript
ExotelCallRibbon.init({
  apiKey: 'your-api-key',
  apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
  position: 'bottom'
});
```

### 3. Set Customer & Call

```javascript
ExotelCallRibbon.setCustomer({
  phoneNumber: '+919876543210',
  name: 'Rajesh Kumar',
  customerId: 'LOAN001',
  context: {
    loanType: 'Business Loan',
    outstandingBalance: 150000
  }
});
```

**Done! You now have integrated calling.** 🎉

---

## 📊 Live Demo

**Try it now:** https://d2t5fsybshqnye.cloudfront.net

**Test API Key:** `demo-api-key-789`

---

## 💡 Use Cases

### Collections CRM
Track loan accounts, overdue amounts, payment promises:
```javascript
context: {
  loanType: 'Business Loan',
  outstandingBalance: 150000,
  daysOverdue: 45,
  emiAmount: 15000
}
```

### Sales CRM
Track leads, deal value, conversion stages:
```javascript
context: {
  leadSource: 'Website',
  productInterest: 'Premium Plan',
  expectedValue: 75000,
  leadScore: 85
}
```

### Support CRM
Track tickets, issue types, resolution times:
```javascript
context: {
  ticketId: 'SUPPORT-1234',
  issueType: 'Technical',
  severity: 'High'
}
```

---

## 📚 Documentation

### For Developers:
- **[CRM Integration Guide](docs/CRM_INTEGRATION_FINAL.md)** - Complete integration examples
- **[API Guide](docs/CLIENT_API_GUIDE.md)** - All API endpoints
- **[Quick Reference](docs/QUICK_REFERENCE.md)** - Cheat sheet

### For DevOps:
- **[Getting Started](GETTING_STARTED.md)** - Setup instructions
- **[Deployment Guide](docs/DEPLOYMENT.md)** - AWS deployment

### For Database:
- **[Database Overview](database/README.md)** - Schema & setup
- **[Schema Comparison](database/SCHEMA_COMPARISON.md)** - Design decisions

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│  Your CRM Application                       │
│  (Sends: customer context + metadata)       │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│  Call Ribbon Widget (Frontend)              │
│  CloudFront + S3 (Mumbai)                   │
│  Status: ✅ LIVE                            │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│  Backend API (Elastic Beanstalk)            │
│  - Authenticates with API key               │
│  - Manages Exotel credentials               │
│  - Logs calls with context                  │
│  Status: ✅ LIVE                            │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│  PostgreSQL Database (RDS)                  │
│  - 6 tables (simplified schema)             │
│  - Call history + context                   │
│  - Analytics data                           │
│  Status: ✅ LIVE                            │
└─────────────────────────────────────────────┘
```

---

## 🗄️ Database Schema (Simplified)

We use a **lean, focused schema** - 6 tables:

1. **clients** - Your account info
2. **call_sessions** - Every call with context ⭐
3. **call_events** - Detailed event log
4. **call_notes** - Agent notes
5. **usage_tracking** - Billing data
6. **api_logs** - Debugging

**Philosophy:** *"We own the call, not the customer"*

See [Schema Comparison](database/SCHEMA_COMPARISON.md) for details.

---

## 📡 API Endpoints

### Client Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/ribbon/init` | POST | Get credentials |
| `/api/ribbon/config` | GET | Get configuration |
| `/api/ribbon/call-logs` | GET | Get call history |
| `/api/ribbon/customer/:id/calls` | GET | Customer call history |
| `/api/ribbon/analytics` | GET | Basic analytics |
| `/api/ribbon/analytics/detailed` | GET | Detailed analytics |
| `/api/ribbon/export/calls` | GET | Export to CSV/JSON |
| `/api/ribbon/active-calls` | GET | Active calls |

### Admin Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/admin/clients` | GET | List all clients |
| `/api/admin/analytics/all` | GET | All clients analytics |

Full API docs: [CLIENT_API_GUIDE.md](docs/CLIENT_API_GUIDE.md)

---

## 🔑 API Keys

Contact us to get your API key: **contact@intalksai.com**

**Test Key (Available Now):**
```
API Key: demo-api-key-789
Limit: 100 calls/month
```

---

## 💰 Pricing

| Plan | Monthly Calls | Price | Features |
|------|--------------|-------|----------|
| Trial | 100 | Free | Basic calling |
| Starter | 1,000 | ₹2,999/mo | + Analytics |
| Professional | 5,000 | ₹9,999/mo | + API access |
| Enterprise | 20,000+ | Custom | + Dedicated support |

---

## 🌐 Production URLs

- **Widget CDN:** https://d2t5fsybshqnye.cloudfront.net
- **API Server:** http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
- **Region:** Asia Pacific (Mumbai) - ap-south-1

---

## 🛠️ Technology Stack

### Frontend
- React 18
- Modern ES6+ JavaScript
- Responsive CSS
- CloudFront + S3

### Backend
- Node.js + Express
- PostgreSQL (RDS)
- Elastic Beanstalk
- Mumbai region (low latency)

---

## 📦 Project Structure

```
exotel-call-ribbon/
├── README.md                    # This file
├── GETTING_STARTED.md          # Setup guide
│
├── widget/                     # Frontend widget
│   ├── src/
│   │   ├── CallControlRibbon.jsx
│   │   ├── CallControlRibbon.css
│   │   └── widget-entry.js
│   └── public/
│       └── index.html          # Demo page
│
├── api/                        # Backend API
│   ├── server.js              # Express server
│   ├── database.js            # PostgreSQL module
│   └── package.json
│
├── database/                   # Database
│   ├── README.md
│   ├── schema-simplified.sql  # Current schema
│   └── init-simplified-test-data.sql
│
└── docs/                       # Documentation
    ├── CRM_INTEGRATION_FINAL.md
    ├── CLIENT_API_GUIDE.md
    ├── QUICK_REFERENCE.md
    └── DEPLOYMENT.md
```

---

## 🚀 Deployment

### Frontend (CloudFront + S3)
```bash
cd widget
npm run build
aws s3 sync build/ s3://your-bucket/ --region ap-south-1
```

### Backend (Elastic Beanstalk)
```bash
cd api
eb deploy production-mumbai --region ap-south-1
```

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for details.

---

## 🧪 Testing

### Run Demo Locally

```bash
# Frontend
cd widget
npm install
npm start

# Backend
cd api
npm install
npm start
```

### Test Endpoints

```bash
cd database
./test-simplified-endpoints.sh
```

---

## 📞 Support

- 📧 Email: contact@intalksai.com
- 📚 Documentation: https://docs.callribbon.intalksai.com
- 💬 Slack: (invite link)

---

## 📄 License

Commercial license. Contact us for terms.

---

## 🙏 Credits

Built with ❤️ by IntalksAI

© 2024 IntalksAI. All rights reserved.
