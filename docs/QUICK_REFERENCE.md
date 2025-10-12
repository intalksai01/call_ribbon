# IntalksAI Call Ribbon - Quick Reference Card

## 🚀 Initialization

```javascript
ExotelCallRibbon.init({
    apiKey: 'your-api-key',
    apiUrl: 'https://api.callribbon.intalksai.com',
    position: 'bottom',
    onCallEvent: (event, data) => { /* handle events */ },
    onReady: () => { /* ready */ }
});
```

---

## 📞 Make a Call (Required Fields)

```javascript
ExotelCallRibbon.setCustomer({
    // ✅ REQUIRED
    phoneNumber: '+919876543210',
    name: 'Customer Name',
    customerId: 'YOUR-CRM-ID',
    
    // ⭐ HIGHLY RECOMMENDED FOR ANALYTICS
    context: { /* any business data */ },
    callType: 'collections', // or 'sales', 'support'
    agentId: 'AGT001',
    agentName: 'Agent Name',
    metadata: { campaign: 'campaign_name' }
});
```

---

## 🎯 Context Object Examples

### Collections
```javascript
context: {
    loanType: 'Business Loan',
    loanAmount: 500000,
    outstandingBalance: 150000,
    daysOverdue: 45,
    emiAmount: 15000
}
```

### Sales
```javascript
context: {
    leadSource: 'Website',
    productInterest: 'Premium Plan',
    expectedValue: 75000,
    leadScore: 85
}
```

### Support
```javascript
context: {
    ticketId: 'TICKET-1234',
    issueType: 'Technical',
    severity: 'High',
    productName: 'Enterprise Plan'
}
```

---

## 📊 API Endpoints

### Get Call Logs
```bash
GET /api/ribbon/call-logs?page=1&pageSize=50
Headers: x-api-key: your-key
```

### Get Customer History
```bash
GET /api/ribbon/customer/{customerId}/calls
Headers: x-api-key: your-key
```

### Get Analytics
```bash
GET /api/ribbon/analytics
GET /api/ribbon/analytics/detailed
Headers: x-api-key: your-key
```

### Export Data
```bash
GET /api/ribbon/export/calls?format=csv
Headers: x-api-key: your-key
```

---

## 📈 What You Send → What You Get

| You Send | You Get Analytics On |
|----------|---------------------|
| `context.loanAmount` | Call patterns by loan size |
| `context.daysOverdue` | Success rates by overdue bucket |
| `callType` | Performance by call type |
| `agentId` | Agent performance metrics |
| `metadata.campaign` | Campaign effectiveness |
| `customer phone` | Call history per customer |

---

## ⚡ Response Format

```json
{
  "session_id": "uuid",
  "customer_name": "Name",
  "customer_phone": "+91...",
  "customer_id_external": "YOUR-ID",
  "customer_context": { /* your data */ },
  "call_type": "collections",
  "call_status": "completed",
  "duration": 270,
  "initiated_at": "2024-10-12T10:30:00Z",
  "agent_name": "Agent Name",
  "metadata": { /* your metadata */ }
}
```

---

## 🎨 Call Types

- `collections`
- `sales`
- `customer_service`
- `support`
- `follow_up`

Use consistently for best analytics!

---

## 🔑 API Keys

Get your key from: https://dashboard.callribbon.intalksai.com

Test with: `demo-api-key-789` (100 calls/month limit)

---

## 📞 Support

- 📧 contact@intalksai.com
- 📚 https://docs.callribbon.intalksai.com
- 💬 Slack Community

---

## ✅ Integration Checklist

- [ ] Got API key
- [ ] Widget initialized
- [ ] Sending `context` object
- [ ] Including `callType`
- [ ] Including `agentId`
- [ ] Using `metadata` for campaigns
- [ ] Tested API endpoints
- [ ] Verified analytics data

**Done? You're ready to go!** 🎉

