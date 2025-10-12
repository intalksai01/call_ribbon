# 📞 IntalksAI Call Ribbon - Complete CRM Integration Guide

## 🎯 Overview

This guide provides everything you need to integrate the IntalksAI Call Ribbon into your CRM application. The widget enables seamless calling capabilities while automatically capturing call analytics for your business.

**Key Benefits:**
- ✅ One-line widget integration
- ✅ Automatic call analytics
- ✅ Flexible customer context tracking
- ✅ No Exotel credential management needed
- ✅ Works with any CRM platform

---

## 🚀 Quick Start (3 Steps)

### **Step 1: Include the Widget**

Add this script tag to your CRM application:

```html
<script src="https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js"></script>
```

### **Step 2: Initialize the Ribbon**

```javascript
ExotelCallRibbon.init({
  apiKey: 'your-api-key-here',
  apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
  position: 'bottom',
  onCallEvent: handleCallEvent,
  onReady: () => console.log('Ribbon ready!')
});
```

### **Step 3: Set Customer Context**

**⚠️ IMPORTANT:** Send rich context data for meaningful analytics!

```javascript
ExotelCallRibbon.setCustomer({
  // Required fields
  phoneNumber: '+919876543210',
  name: 'Rajesh Kumar',
  customerId: 'LOAN001',
  
  // ⭐ CRITICAL FOR ANALYTICS - Send your business data
  context: {
    loanType: 'Business Loan',
    loanAmount: 500000,
    outstandingBalance: 150000,
    daysOverdue: 45,
    emiAmount: 15000,
    riskCategory: 'Medium'
  },
  
  // Call metadata
  callType: 'collections',  // collections, sales, support
  agentId: 'AGT001',
  agentName: 'Suresh Kumar',
  metadata: {
    campaign: 'overdue_45days',
    attempt: 4
  }
});
```

**That's it! You now have integrated calling + analytics.** ✅

---

## 📊 Why Context Data Matters

### What You Send → What You Get

| Data You Send | Analytics You Get |
|---------------|-------------------|
| `context.loanAmount` | Call patterns by loan size |
| `context.daysOverdue` | Success rates by overdue bucket |
| `callType` | Performance metrics by call type |
| `agentId` | Individual agent performance |
| `metadata.campaign` | Campaign effectiveness tracking |
| Call duration | Average handling time analysis |

**The more context you send, the better insights you get!**

---

## 💡 Complete Integration Examples

### Example 1: Collections CRM

```html
<!DOCTYPE html>
<html>
<head>
  <title>Collections CRM</title>
</head>
<body>
  <div id="collections-dashboard">
    <h1>Collections Dashboard</h1>
    
    <!-- Customer List -->
    <table id="customer-table">
      <tr onclick="callCustomer('LOAN001')">
        <td>LOAN001</td>
        <td>Rajesh Kumar</td>
        <td>+919876543210</td>
        <td>₹1,50,000</td>
        <td>45 days overdue</td>
      </tr>
    </table>
  </div>

  <!-- Widget Script -->
  <script src="https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js"></script>

  <script>
    // Initialize once on page load
    ExotelCallRibbon.init({
      apiKey: 'your-collections-api-key',
      apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
      position: 'bottom',
      onCallEvent: handleCallEvent,
      onReady: () => console.log('✅ Call ribbon ready!')
    });

    // Call customer from your CRM
    function callCustomer(loanId) {
      // Get customer from your database
      const customer = getCustomerFromDB(loanId);
      
      // Set customer with rich context
      ExotelCallRibbon.setCustomer({
        // Required
        phoneNumber: customer.phone,
        name: customer.name,
        customerId: customer.loanId,
        
        // Business context (critical for analytics!)
        context: {
          loanType: customer.loanType,
          loanAmount: customer.loanAmount,
          outstandingBalance: customer.outstanding,
          daysOverdue: customer.daysOverdue,
          emiAmount: customer.emiAmount,
          lastPaymentDate: customer.lastPaymentDate,
          collectionAttempts: customer.attemptCount,
          riskCategory: customer.riskCategory
        },
        
        // Call metadata
        callType: 'collections',
        agentId: getCurrentAgent().id,
        agentName: getCurrentAgent().name,
        metadata: {
          campaign: 'overdue_campaign_q4',
          bucket: 'DPD_30_60',
          attempt: customer.attemptCount + 1,
          priority: customer.priority
        }
      });
      
      // Call will be initiated automatically
    }

    // Handle call events
    function handleCallEvent(event, data) {
      console.log('📞 Call Event:', event, data);
      
      switch(event) {
        case 'connected':
          // Update CRM - call connected
          updateCustomerStatus(data.customerData.customerId, 'ON_CALL');
          startCallTimer();
          break;
          
        case 'callEnded':
          // Update CRM - call ended
          updateCustomerStatus(data.customerData.customerId, 'CALL_COMPLETED');
          saveCallNotes(data.customerData.customerId, data.duration);
          scheduleFollowUp(data.customerData.customerId);
          break;
          
        case 'incoming':
          // Incoming call - show popup
          showIncomingCallPopup(data.phoneNumber);
          break;
      }
    }

    // Your CRM functions
    function getCustomerFromDB(loanId) {
      // Fetch from your database
      return {
        loanId: 'LOAN001',
        name: 'Rajesh Kumar',
        phone: '+919876543210',
        loanType: 'Business Loan',
        loanAmount: 500000,
        outstanding: 150000,
        daysOverdue: 45,
        emiAmount: 15000,
        attemptCount: 3,
        priority: 'High',
        riskCategory: 'Medium',
        lastPaymentDate: '2024-08-15'
      };
    }

    function updateCustomerStatus(customerId, status) {
      // Update in your CRM
      console.log(`Update ${customerId} status to ${status}`);
    }

    function saveCallNotes(customerId, duration) {
      // Save to your CRM
      console.log(`Save call notes for ${customerId}, duration: ${duration}s`);
    }

    function getCurrentAgent() {
      // Get logged-in agent info
      return { id: 'AGT001', name: 'Suresh Kumar' };
    }
  </script>
</body>
</html>
```

---

### Example 2: Sales CRM

```javascript
// Initialize for sales CRM
ExotelCallRibbon.init({
  apiKey: 'your-sales-api-key',
  apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
  position: 'floating',
  onCallEvent: handleSalesCallEvent
});

// Call a lead
function callLead(leadId) {
  const lead = getLeadFromCRM(leadId);
  
  ExotelCallRibbon.setCustomer({
    phoneNumber: lead.phone,
    name: lead.name,
    customerId: lead.leadId,
    
    context: {
      leadSource: lead.source,          // Website, Referral, etc.
      productInterest: lead.product,    // Which product
      expectedValue: lead.dealValue,    // Deal size
      leadScore: lead.score,            // 0-100
      company: lead.company,
      industry: lead.industry,
      employeeCount: lead.employees,
      currentProvider: lead.currentProvider
    },
    
    callType: 'sales',
    agentId: getCurrentSalesRep().id,
    agentName: getCurrentSalesRep().name,
    metadata: {
      campaign: 'new_leads_q4',
      stage: lead.stage,              // Qualification, Demo, etc.
      lastInteraction: lead.lastContact,
      nextAction: 'Product Demo'
    }
  });
}

function handleSalesCallEvent(event, data) {
  switch(event) {
    case 'connected':
      updateLeadStage(data.customerData.customerId, 'IN_CONVERSATION');
      startCallScript('product_demo');
      break;
      
    case 'callEnded':
      showCallDispositionForm(data);
      updateLeadScore(data.customerData.customerId, data.duration);
      scheduleNextAction(data.customerData.customerId);
      break;
  }
}
```

---

### Example 3: Support CRM

```javascript
// Initialize for support
ExotelCallRibbon.init({
  apiKey: 'your-support-api-key',
  apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
  position: 'bottom',
  onCallEvent: handleSupportCallEvent
});

// Call a customer with support ticket
function callCustomerForSupport(ticketId) {
  const ticket = getTicketFromCRM(ticketId);
  
  ExotelCallRibbon.setCustomer({
    phoneNumber: ticket.customerPhone,
    name: ticket.customerName,
    customerId: ticket.customerId,
    
    context: {
      ticketId: ticket.ticketId,
      issueType: ticket.issueType,      // Technical, Billing, etc.
      severity: ticket.severity,         // Low, Medium, High, Critical
      productName: ticket.product,
      subscriptionTier: ticket.tier,     // Basic, Pro, Enterprise
      accountValue: ticket.accountValue,
      issueCategory: ticket.category,
      previousTickets: ticket.historyCount,
      customerSatisfaction: ticket.csatScore
    },
    
    callType: 'customer_service',
    agentId: getCurrentSupportAgent().id,
    agentName: getCurrentSupportAgent().name,
    metadata: {
      department: 'Technical Support',
      sla: ticket.sla,
      escalated: ticket.isEscalated,
      priority: ticket.priority
    }
  });
}

function handleSupportCallEvent(event, data) {
  switch(event) {
    case 'connected':
      openTicketPanel(data.customerData.context.ticketId);
      loadCustomerHistory(data.customerData.customerId);
      startSLATimer();
      break;
      
    case 'callEnded':
      updateTicketStatus(data.customerData.context.ticketId, 'RESOLVED');
      sendCSATSurvey(data.customerData.customerId);
      logResolution(data);
      break;
  }
}
```

---

## 📞 Widget API Reference

### Initialization

```javascript
ExotelCallRibbon.init({
  // Required
  apiKey: 'your-api-key',
  apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
  
  // Optional
  position: 'bottom',  // 'top', 'bottom', 'floating'
  onCallEvent: function(event, data) { },
  onReady: function() { }
});
```

### Set Customer Context

```javascript
ExotelCallRibbon.setCustomer({
  // ✅ Required
  phoneNumber: '+919876543210',
  name: 'Customer Name',
  customerId: 'YOUR-CRM-ID',
  
  // ⭐ Highly Recommended
  context: {
    // ANY business-specific data
    // This powers your analytics!
  },
  
  // Recommended
  callType: 'collections', // or 'sales', 'support', 'customer_service'
  agentId: 'AGT001',
  agentName: 'Agent Name',
  metadata: {
    campaign: 'campaign_name',
    // any other tags
  }
});
```

### Other Methods

```javascript
// Show/Hide Widget
ExotelCallRibbon.setVisible(true);
ExotelCallRibbon.setVisible(false);

// Minimize/Expand
ExotelCallRibbon.setMinimized(true);
ExotelCallRibbon.setMinimized(false);

// Change Position
ExotelCallRibbon.setPosition('top');
ExotelCallRibbon.setPosition('bottom');
ExotelCallRibbon.setPosition('floating');

// Make Call Programmatically
ExotelCallRibbon.makeCall('+919876543210');

// Cleanup
ExotelCallRibbon.destroy();
```

---

## 📡 Call Events

### Event Types

```javascript
function handleCallEvent(event, data) {
  switch(event) {
    case 'incoming':
      // Incoming call received
      break;
      
    case 'connected':
      // Call connected successfully
      break;
      
    case 'callEnded':
      // Call ended
      break;
      
    case 'mutetoggle':
      // Mute state changed
      break;
      
    case 'holdtoggle':
      // Hold state changed
      break;
      
    case 'dtmf':
      // DTMF digit pressed
      break;
  }
}
```

### Event Data Structure

```javascript
{
  // Call Info
  callSid: "CA1234567890",
  phoneNumber: "+919876543210",
  callDirection: "outbound",
  duration: 180,
  
  // Customer Data (what you sent)
  customerData: {
    phoneNumber: "+919876543210",
    name: "Customer Name",
    customerId: "YOUR-ID",
    context: { /* your business data */ },
    callType: "collections",
    agentId: "AGT001",
    metadata: { /* your metadata */ }
  },
  
  // Metadata
  timestamp: "2024-10-12T10:30:00Z"
}
```

---

## 📊 Backend API Endpoints

### Get Call History

```bash
GET /api/ribbon/call-logs?page=1&pageSize=50
Headers: x-api-key: your-api-key

# Optional query params:
- startDate: ISO date
- endDate: ISO date
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

### Get Customer Call History

```bash
GET /api/ribbon/customer/{customerId}/calls?limit=50
Headers: x-api-key: your-api-key
```

### Get Analytics

```bash
GET /api/ribbon/analytics
Headers: x-api-key: your-api-key
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
  "callsByDate": { "2024-10-12": 45 },
  "usage": {
    "callsThisMonth": 1250,
    "limit": 20000,
    "remaining": 18750
  }
}
```

### Get Detailed Analytics

```bash
GET /api/ribbon/analytics/detailed
Headers: x-api-key: your-api-key
```

**Response includes:**
- `callsByHour` - Call volume by hour of day
- `callsByDayOfWeek` - Call volume by day
- `topCustomers` - Most called customers
- `durationBuckets` - Call duration distribution

### Export Data

```bash
GET /api/ribbon/export/calls?format=csv
Headers: x-api-key: your-api-key
```

Exports to CSV or JSON format.

---

## 🔑 API Key & Authentication

### Getting Your API Key

Contact us to get your unique API key:
- 📧 Email: contact@intalksai.com
- 🌐 Website: https://callribbon.intalksai.com

**API Key Format:** `yourcompany-api-key-2024`

### Security

- ✅ We manage Exotel credentials (you don't need to)
- ✅ API keys authenticate your application
- ✅ Domain restrictions available
- ✅ Usage limits per plan
- ✅ Secure HTTPS communication

### Plans

| Plan | Monthly Calls | Features |
|------|--------------|----------|
| Trial | 100 | Basic calling |
| Starter | 1,000 | + Analytics |
| Professional | 5,000 | + API access |
| Enterprise | 20,000+ | + Custom features |

---

## 🎯 Context Data Best Practices

### 1. Be Consistent

Use the same field names across all calls:

✅ **Good:**
```javascript
context: {
  loanAmount: 500000,
  daysOverdue: 45
}
```

❌ **Bad:**
```javascript
// Different field names each time
context: {
  loan_amt: 500000,    // Sometimes this
  LoanAmount: 600000,  // Sometimes this
  amount: 700000       // Sometimes this
}
```

### 2. Send Relevant Data

Collections CRM should send:
- Loan details
- Payment history
- Overdue information

Sales CRM should send:
- Lead source
- Product interest
- Deal value

Support CRM should send:
- Ticket details
- Issue type
- Customer tier

### 3. Use Metadata for Tags

```javascript
metadata: {
  campaign: 'q4_collections',
  priority: 'high',
  source: 'auto_dialer'
}
```

### 4. Include Agent Info

Always include agent details:
```javascript
agentId: 'AGT001',
agentName: 'Suresh Kumar'
```

### 5. Set Call Type

Use consistent call types:
- `collections`
- `sales`
- `customer_service`
- `support`
- `follow_up`

---

## 🔧 Troubleshooting

### Widget Not Loading

```javascript
// Check if widget loaded
if (typeof ExotelCallRibbon === 'undefined') {
  console.error('Widget not loaded! Check script URL');
}
```

### API Key Invalid

```javascript
// Test API key
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/config', {
  headers: { 'x-api-key': 'your-api-key' }
})
.then(r => r.json())
.then(data => console.log('API Key valid:', data))
.catch(err => console.error('API Key invalid:', err));
```

### Calls Not Working

1. Check Exotel credentials are configured (contact us)
2. Verify API key is active
3. Check browser console for errors
4. Ensure customer phone number is in correct format

---

## 📱 Mobile Support

The widget is fully responsive and works on:
- ✅ Desktop browsers
- ✅ Mobile browsers
- ✅ Tablets
- ✅ iOS Safari
- ✅ Android Chrome

---

## 🌐 Browser Support

- ✅ Chrome (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Edge
- ⚠️ IE11 (limited support)

---

## 📚 Additional Resources

- 📖 Full API Documentation: `docs/CLIENT_API_GUIDE.md`
- ⚡ Quick Reference: `docs/QUICK_REFERENCE.md`
- 🗄️ Database Schema: `database/SCHEMA_COMPARISON.md`
- 🔐 Security Guide: Contact us

---

## 🆘 Support

### Contact Us

- 📧 Email: contact@intalksai.com
- 📚 Documentation: https://docs.callribbon.intalksai.com
- 💬 Slack Community: (invite link)

### SLA

- Response Time: 24 hours
- Critical Issues: 4 hours
- Uptime: 99.9%

---

## ✅ Integration Checklist

Before going live, ensure:

- [ ] Widget script included
- [ ] API key configured
- [ ] `init()` called on page load
- [ ] `setCustomer()` called before each call
- [ ] **Context data** being sent (critical!)
- [ ] Call type specified
- [ ] Agent info included
- [ ] Metadata for campaigns added
- [ ] Event handlers implemented
- [ ] Error handling in place
- [ ] Tested with real calls
- [ ] Analytics data verified
- [ ] Production API key obtained

---

## 🚀 Go Live

**Ready to deploy?**

1. Replace demo API key with production key
2. Test with a few calls
3. Verify analytics data
4. Roll out to your team
5. Monitor usage dashboard

**Need help?** Contact us anytime! 📧 contact@intalksai.com

---

## 📄 License

This widget is provided under commercial license.
Contact us for terms and pricing.

© 2024 IntalksAI. All rights reserved.
