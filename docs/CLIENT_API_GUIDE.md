# IntalksAI Call Ribbon - Client API Guide

## Overview

This guide explains how to integrate the IntalksAI Call Ribbon into your application and what data you need to send to enable comprehensive call analytics.

---

## 🔑 Authentication

All API requests require your unique API key. You'll receive this when you sign up.

```
API Key Format: yourcompany-api-key-2024
```

---

## 📞 Core Integration Flow

### 1. Initialize the Widget

When your page loads, initialize the call ribbon widget:

```javascript
IntalksAICallRibbon.init({
    apiKey: 'your-api-key-here',
    apiUrl: 'https://api.callribbon.intalksai.com',
    position: 'bottom',
    onCallEvent: function(event, data) {
        console.log('Call Event:', event, data);
        // Handle call events
    },
    onReady: function() {
        console.log('Ribbon ready!');
    }
});
```

### 2. Set Customer Context Before Each Call

**This is critical for analytics!** Before initiating a call, pass the customer context:

```javascript
IntalksAICallRibbon.setCustomer({
    // Required Fields
    phoneNumber: '+919876543210',
    name: 'Rajesh Kumar',
    customerId: 'LOAN001',  // YOUR CRM's customer ID
    
    // Optional but Recommended for Analytics
    context: {
        // Add ANY data relevant to your business
        loanType: 'Business Loan',
        loanAmount: 500000,
        outstandingBalance: 150000,
        daysOverdue: 45,
        emiAmount: 15000,
        
        // Or for sales:
        // leadSource: 'Website',
        // productInterest: 'Premium Plan',
        // expectedValue: 50000,
        
        // Or for support:
        // ticketId: 'TICKET-1234',
        // issueType: 'Technical',
        // priority: 'High'
    },
    
    // Agent Information (if available)
    agentId: 'AGT001',
    agentName: 'Suresh Kumar',
    
    // Call Type (helps with analytics)
    callType: 'collections', // or 'sales', 'support', 'customer_service'
    
    // Additional Metadata
    metadata: {
        campaign: 'overdue_45days',
        attempt: 4,
        department: 'Collections'
    }
});
```

### 3. Initiate the Call

The widget handles the call automatically once customer context is set. You can also programmatically trigger it:

```javascript
IntalksAICallRibbon.makeCall();
```

---

## 📊 Data You Send = Analytics You Get

### What You Send:

| Field | Type | Required | Purpose |
|-------|------|----------|---------|
| `phoneNumber` | String | ✅ Yes | Customer phone number |
| `name` | String | ✅ Yes | Customer display name |
| `customerId` | String | ✅ Yes | Your CRM's customer ID (for linking) |
| `context` | Object | ⭐ Recommended | Flexible JSONB - any business data |
| `callType` | String | ⭐ Recommended | Collections, sales, support, etc. |
| `agentId` | String | Optional | Agent identifier |
| `agentName` | String | Optional | Agent name |
| `metadata` | Object | Optional | Campaign, tags, etc. |

### What You Get (Analytics):

✅ Call duration by customer
✅ Call success rates
✅ Calls by call type
✅ Calls by time of day / day of week
✅ Top customers by call volume
✅ Average call duration
✅ Call outcomes (completed, missed, failed)
✅ Agent performance
✅ Your custom context data in every call record

---

## 🔄 Example Use Cases

### Use Case 1: Collections CRM

```javascript
// When user clicks on a loan account
IntalksAICallRibbon.setCustomer({
    phoneNumber: '+919876543210',
    name: 'Rajesh Kumar',
    customerId: 'LOAN001',
    
    context: {
        accountType: 'Business Loan',
        principalAmount: 500000,
        outstandingBalance: 150000,
        emiAmount: 15000,
        daysOverdue: 45,
        lastPaymentDate: '2024-08-15',
        collectionAttempts: 3,
        riskCategory: 'Medium'
    },
    
    callType: 'collections',
    agentId: 'AGT001',
    agentName: 'Suresh Kumar',
    
    metadata: {
        campaign: 'overdue_45days',
        bucket: 'DPD_30_60',
        priority: 'High'
    }
});
```

**Analytics You'll Get:**
- Which loan types have highest contact rates
- Average call duration per overdue bucket
- Success rate by days overdue
- Best times to contact customers
- Agent performance on collection calls

---

### Use Case 2: Sales CRM

```javascript
// When contacting a lead
IntalksAICallRibbon.setCustomer({
    phoneNumber: '+918765432109',
    name: 'Priya Sharma',
    customerId: 'LEAD-2024-0451',
    
    context: {
        leadSource: 'Website Form',
        productInterest: 'Premium Subscription',
        expectedValue: 75000,
        leadScore: 85,
        company: 'Tech Innovations Pvt Ltd',
        industry: 'IT Services',
        employeeCount: 50
    },
    
    callType: 'sales',
    agentId: 'SALES-05',
    agentName: 'Rahul Verma',
    
    metadata: {
        campaign: 'new_leads_q4',
        stage: 'Qualification',
        lastInteraction: '2024-10-10'
    }
});
```

**Analytics You'll Get:**
- Conversion rates by lead source
- Call duration vs deal value correlation
- Best performing sales agents
- Optimal calling times for leads
- Product interest patterns

---

### Use Case 3: Customer Support

```javascript
// When handling a support ticket
IntalksAICallRibbon.setCustomer({
    phoneNumber: '+917654321098',
    name: 'Venkatesh Iyer',
    customerId: 'CUST-7829',
    
    context: {
        ticketId: 'SUPPORT-1234',
        issueType: 'Technical',
        productName: 'Enterprise Plan',
        severity: 'High',
        accountValue: 250000,
        subscriptionTier: 'Premium',
        issueCategory: 'Login Issues'
    },
    
    callType: 'customer_service',
    agentId: 'SUPPORT-12',
    agentName: 'Meena Iyer',
    
    metadata: {
        department: 'Technical Support',
        escalated: false,
        sla: 'Priority'
    }
});
```

**Analytics You'll Get:**
- Average resolution time by issue type
- Support call volume patterns
- Customer satisfaction correlation
- Agent expertise mapping
- High-value customer handling

---

## 📥 API Endpoints for Your Backend

### 1. Get Call History

Retrieve call logs with filters:

```bash
GET /api/ribbon/call-logs
Headers: x-api-key: your-api-key

Query Parameters:
- page: Page number (default: 1)
- pageSize: Records per page (default: 50)
- startDate: Filter from date (ISO 8601)
- endDate: Filter to date (ISO 8601)
- customerId: Your CRM customer ID
- callDirection: inbound/outbound
```

**Response:**
```json
{
  "logs": [
    {
      "session_id": "uuid",
      "customer_name": "Rajesh Kumar",
      "customer_phone": "+919876543210",
      "customer_id_external": "LOAN001",
      "customer_context": {
        "loanType": "Business Loan",
        "outstandingBalance": 150000
      },
      "call_type": "collections",
      "call_status": "completed",
      "duration": 270,
      "initiated_at": "2024-10-12T10:30:00Z",
      "connected_at": "2024-10-12T10:30:15Z",
      "ended_at": "2024-10-12T10:34:45Z",
      "agent_name": "Suresh Kumar",
      "metadata": {
        "campaign": "overdue_45days"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 50,
    "total": 234,
    "totalPages": 5
  }
}
```

---

### 2. Get Customer Call History

Get all calls for a specific customer:

```bash
GET /api/ribbon/customer/{customerId}/calls
Headers: x-api-key: your-api-key

Query Parameters:
- limit: Number of calls (default: 50)
```

**Response:**
```json
{
  "customerId": "LOAN001",
  "calls": [...],
  "totalCalls": 5,
  "totalDuration": 1230
}
```

---

### 3. Get Analytics Summary

```bash
GET /api/ribbon/analytics
Headers: x-api-key: your-api-key

Query Parameters:
- startDate: Filter from date
- endDate: Filter to date
- limit: Number of recent calls
```

**Response:**
```json
{
  "summary": {
    "totalCalls": 1250,
    "totalDuration": 335600,
    "avgDuration": 268,
    "inboundCalls": 320,
    "outboundCalls": 930,
    "missedCalls": 45
  },
  "callsByDate": {
    "2024-10-12": 45,
    "2024-10-11": 52
  },
  "recentCalls": [...],
  "usage": {
    "callsThisMonth": 1250,
    "limit": 20000,
    "remaining": 18750
  }
}
```

---

### 4. Get Detailed Analytics

```bash
GET /api/ribbon/analytics/detailed
Headers: x-api-key: your-api-key

Query Parameters:
- startDate: Filter from date
- endDate: Filter to date
```

**Response:**
```json
{
  "summary": {
    "totalCalls": 1250,
    "totalDuration": 335600,
    "avgDuration": 268,
    "inboundCalls": 320,
    "outboundCalls": 930,
    "missedCalls": 45
  },
  "callsByHour": {
    "9": 45,
    "10": 78,
    "11": 92,
    ...
  },
  "callsByDayOfWeek": {
    "0": 120,  // Sunday
    "1": 245,  // Monday
    ...
  },
  "topCustomers": [
    {
      "customer_id_external": "LOAN001",
      "customer_name": "Rajesh Kumar",
      "customer_phone": "+919876543210",
      "call_count": "5",
      "total_duration": "1230"
    }
  ],
  "durationBuckets": {
    "0-30s": 45,
    "30s-1m": 120,
    "1m-3m": 450,
    "3m-5m": 320,
    "5m+": 315
  },
  "recentActivity": [...]
}
```

---

### 5. Export Call Data

```bash
GET /api/ribbon/export/calls
Headers: x-api-key: your-api-key

Query Parameters:
- format: json or csv
- startDate: Filter from date
- endDate: Filter to date
```

**CSV Format:**
```
Session ID,Customer Name,Phone Number,Direction,Start Time,End Time,Duration (s),Customer ID
uuid,Rajesh Kumar,+919876543210,outbound,2024-10-12 10:30:00,2024-10-12 10:34:45,270,LOAN001
```

---

## 🎯 Best Practices

### 1. Always Send Customer Context

❌ **Don't do this:**
```javascript
IntalksAICallRibbon.setCustomer({
    phoneNumber: '+919876543210',
    name: 'Rajesh Kumar',
    customerId: 'LOAN001'
    // Missing context!
});
```

✅ **Do this:**
```javascript
IntalksAICallRibbon.setCustomer({
    phoneNumber: '+919876543210',
    name: 'Rajesh Kumar',
    customerId: 'LOAN001',
    context: {
        // Add relevant business data
        loanAmount: 500000,
        daysOverdue: 45,
        // etc.
    },
    callType: 'collections',
    agentId: 'AGT001'
});
```

### 2. Use Consistent Field Names

Be consistent with your context field names across calls:

✅ **Good:**
```javascript
// All collection calls use same fields
context: {
    loanType: 'Business Loan',
    outstandingBalance: 150000,
    daysOverdue: 45
}
```

❌ **Bad:**
```javascript
// Inconsistent field names
context: {
    loan_type: 'Business',    // Sometimes this
    LoanType: 'Personal',     // Sometimes this
    type: 'Gold'              // Sometimes this
}
```

### 3. Include Agent Information

This enables agent performance analytics:

```javascript
agentId: 'AGT001',          // Unique agent ID
agentName: 'Suresh Kumar'   // Human-readable name
```

### 4. Use Call Types Consistently

Stick to a set of call types:
- `collections`
- `sales`
- `customer_service`
- `support`
- `follow_up`
- etc.

### 5. Leverage Metadata for Campaigns

```javascript
metadata: {
    campaign: 'overdue_45days',  // Track campaign performance
    source: 'auto_dialer',       // Track call sources
    priority: 'high'             // Track by priority
}
```

---

## 📈 Analytics Queries You Can Run

With proper context data, you can analyze:

### By Call Type
```
How many collection calls vs sales calls this month?
What's the average duration for each call type?
```

### By Customer Segment
```
What's the call success rate for high-value customers?
How many calls needed per overdue bucket?
```

### By Time Patterns
```
What time of day has the highest answer rate?
Which days of the week are most productive?
```

### By Agent
```
Which agents have the highest call completion rate?
What's the average call duration per agent?
```

### By Campaign
```
How is the Q4 collections campaign performing?
What's the conversion rate for the new leads campaign?
```

### By Context Data
```
Do larger loan amounts require longer calls?
Is there a correlation between days overdue and call success?
What's the average call duration by product type?
```

---

## 🔒 Security & Privacy

### What We Store:
- Call timeline and duration
- Customer name and phone (for context only)
- Your customer ID (for linking)
- Context data you choose to send
- Call events (mute, hold, transfer, etc.)

### What We DON'T Store:
- Call recordings (handled by Exotel)
- Full customer profiles
- Sensitive PII beyond what you send
- Payment information
- Documents or attachments

### Data Retention:
- Call data: 12 months
- Analytics summaries: Indefinitely
- Deleted on account closure

---

## 🆘 Support

### API Status
Monitor API health: `GET /health`

### Rate Limits
- Standard Plan: 100 calls/month
- Professional: 5,000 calls/month
- Enterprise: 20,000 calls/month
- Custom: Unlimited (contact us)

### Need Help?
- 📧 Email: support@intalksai.com
- 📚 Docs: https://docs.callribbon.intalksai.com
- 💬 Slack: Join our community

---

## 🚀 Quick Start Checklist

- [ ] Get your API key
- [ ] Initialize widget on your page
- [ ] Send customer context before each call
- [ ] Include `context` object with business data
- [ ] Set `callType` for analytics
- [ ] Include `agentId` and `agentName`
- [ ] Use `metadata` for campaigns
- [ ] Test with a few calls
- [ ] Query analytics endpoints
- [ ] Verify data appears correctly
- [ ] Roll out to production

---

## 📝 Example Integration (Complete)

```html
<!DOCTYPE html>
<html>
<head>
    <title>My CRM - Collections</title>
    <link rel="stylesheet" href="https://cdn.callribbon.intalksai.com/v1/ribbon.css">
</head>
<body>
    <div id="app">
        <!-- Your CRM UI -->
        <button onclick="callCustomer('LOAN001')">
            Call Rajesh Kumar
        </button>
    </div>

    <script src="https://cdn.callribbon.intalksai.com/v1/ribbon.js"></script>
    <script>
        // Initialize once on page load
        IntalksAICallRibbon.init({
            apiKey: 'your-api-key-here',
            apiUrl: 'https://api.callribbon.intalksai.com',
            position: 'bottom',
            onCallEvent: handleCallEvent,
            onReady: () => console.log('Ribbon ready!')
        });

        // Call customer function
        function callCustomer(loanId) {
            // Get customer data from your CRM
            const customer = getCustomerFromCRM(loanId);
            
            // Set context before calling
            IntalksAICallRibbon.setCustomer({
                phoneNumber: customer.phone,
                name: customer.name,
                customerId: customer.loanId,
                
                context: {
                    loanType: customer.loanType,
                    loanAmount: customer.loanAmount,
                    outstandingBalance: customer.outstanding,
                    daysOverdue: customer.daysOverdue,
                    emiAmount: customer.emiAmount
                },
                
                callType: 'collections',
                agentId: getCurrentAgent().id,
                agentName: getCurrentAgent().name,
                
                metadata: {
                    campaign: 'overdue_campaign_q4',
                    attempt: customer.callAttempts + 1
                }
            });
            
            // Make the call
            IntalksAICallRibbon.makeCall();
        }

        // Handle call events
        function handleCallEvent(event, data) {
            console.log('Call Event:', event, data);
            
            switch(event) {
                case 'connected':
                    updateCRM(data.customerId, 'call_connected');
                    break;
                case 'callEnded':
                    updateCRM(data.customerId, 'call_ended', {
                        duration: data.duration
                    });
                    break;
            }
        }
    </script>
</body>
</html>
```

---

**Ready to get started? Contact us for your API key!** 🚀

