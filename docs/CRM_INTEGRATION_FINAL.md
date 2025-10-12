# 📞 Exotel Call Control Ribbon - CRM Integration Guide

## Quick Start for CRM Integration

This guide shows you exactly what to add to your CRM application to enable integrated calling capabilities.

---

## 🚀 **3-Step Integration**

### **Step 1: Include the Widget Script**

Add this script tag to your CRM application's HTML:

```html
<script src="https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js"></script>
```

### **Step 2: Initialize the Ribbon**

Add this JavaScript code to initialize the widget:

```javascript
ExotelCallRibbon.init({
  apiKey: 'your-api-key-here',
  apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
  position: 'bottom',
  onCallEvent: function(event, data) {
    console.log('Call event:', event, data);
    // Handle call events in your CRM
  },
  onReady: function() {
    console.log('Call ribbon is ready!');
  }
});
```

### **Step 3: Load Customer Data**

When a customer is selected in your CRM:

```javascript
function onCustomerSelected(customer) {
  ExotelCallRibbon.setCustomer({
    phoneNumber: customer.phone,
    name: customer.name,
    email: customer.email,
    customerId: customer.id
  });
}
```

**That's it! Your CRM now has integrated calling.** ✅

---

## 📋 **Complete Integration Example**

### **HTML File:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>My CRM Application</title>
</head>
<body>
  <!-- Your CRM Application -->
  <div id="crm-app">
    <h1>My CRM Dashboard</h1>
    
    <!-- Customer List Example -->
    <div class="customers">
      <div class="customer-card" onclick="selectCustomer('John Doe', '+919876543210', 'CUST001')">
        <h3>John Doe</h3>
        <p>Phone: +919876543210</p>
      </div>
      
      <div class="customer-card" onclick="selectCustomer('Jane Smith', '+918765432109', 'CUST002')">
        <h3>Jane Smith</h3>
        <p>Phone: +918765432109</p>
      </div>
    </div>
  </div>

  <!-- Include Call Control Widget -->
  <script src="https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js"></script>

  <!-- Initialize Widget -->
  <script>
    // Initialize call ribbon
    ExotelCallRibbon.init({
      apiKey: 'demo-api-key-789', // Replace with your API key
      apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
      position: 'bottom', // 'top', 'bottom', or 'floating'
      onCallEvent: handleCallEvent,
      onReady: function() {
        console.log('Call ribbon ready!');
      }
    });

    // Handle customer selection
    function selectCustomer(name, phone, id) {
      ExotelCallRibbon.setCustomer({
        phoneNumber: phone,
        name: name,
        customerId: id
      });
    }

    // Handle call events
    function handleCallEvent(event, data) {
      console.log('Call Event:', event, data);
      
      switch(event) {
        case 'connected':
          // Call connected - update CRM
          updateCRMStatus(data.customerData.customerId, 'on_call');
          startCallTimer(data);
          break;
          
        case 'callEnded':
          // Call ended - save to CRM
          savCallRecord(data);
          updateCRMStatus(data.customerData.customerId, 'call_completed');
          break;
          
        case 'incoming':
          // Incoming call - show notification
          showIncomingCallNotification(data);
          break;
      }
    }

    // Your CRM functions
    function updateCRMStatus(customerId, status) {
      // Update customer status in your CRM
      console.log('Updating status:', customerId, status);
    }

    function saveCallRecord(data) {
      // Save call record to your CRM database
      console.log('Saving call record:', data);
    }

    function showIncomingCallNotification(data) {
      // Show notification for incoming call
      alert('Incoming call from: ' + data.phoneNumber);
    }

    function startCallTimer(data) {
      // Start call duration timer
      console.log('Call started:', data);
    }
  </script>
</body>
</html>
```

---

## 🔑 **Configuration Options**

### **Required Parameters:**

```javascript
{
  apiKey: 'your-api-key-here',  // Provided by us
  apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com'
}
```

### **Optional Parameters:**

```javascript
{
  position: 'bottom',  // 'top', 'bottom', or 'floating'
  onCallEvent: function(event, data) { },  // Call event handler
  onReady: function() { }  // Ready callback
}
```

---

## 📞 **Widget API Methods**

### **1. Initialize Widget**
```javascript
ExotelCallRibbon.init(config);
```

### **2. Set Customer Data**
```javascript
ExotelCallRibbon.setCustomer({
  phoneNumber: '+919876543210',  // Required
  name: 'John Doe',              // Optional
  email: 'john@example.com',     // Optional
  customerId: 'CUST001'          // Optional (your CRM ID)
});
```

### **3. Change Position**
```javascript
ExotelCallRibbon.setPosition('top');      // Move to top
ExotelCallRibbon.setPosition('bottom');   // Move to bottom
ExotelCallRibbon.setPosition('floating'); // Floating mode
```

### **4. Show/Hide Widget**
```javascript
ExotelCallRibbon.setVisible(true);   // Show
ExotelCallRibbon.setVisible(false);  // Hide
```

### **5. Minimize/Expand**
```javascript
ExotelCallRibbon.setMinimized(true);   // Minimize
ExotelCallRibbon.setMinimized(false);  // Expand
```

### **6. Make Call Programmatically**
```javascript
ExotelCallRibbon.makeCall('+919876543210');
```

### **7. Destroy Widget**
```javascript
ExotelCallRibbon.destroy();  // Cleanup when done
```

---

## 📡 **Call Events**

### **Event Types:**

```javascript
function handleCallEvent(event, data) {
  switch(event) {
    case 'incoming':
      // Incoming call received
      // data: { phoneNumber, callSid, ... }
      break;
      
    case 'connected':
      // Call successfully connected
      // data: { phoneNumber, callSid, customerData, ... }
      break;
      
    case 'callEnded':
      // Call ended
      // data: { phoneNumber, duration, customerData, ... }
      break;
      
    case 'mutetoggle':
      // Mute state changed
      // data: { isMuted, ... }
      break;
      
    case 'holdtoggle':
      // Hold state changed
      // data: { isOnHold, ... }
      break;
  }
}
```

### **Event Data Structure:**

```javascript
{
  // Call information
  callSid: "CA1234567890abcdef",
  phoneNumber: "+919876543210",
  callDirection: "outbound", // or "inbound"
  duration: 180, // seconds
  
  // Customer data (from setCustomer)
  customerData: {
    phoneNumber: "+919876543210",
    name: "John Doe",
    email: "john@example.com",
    customerId: "CUST001"
  },
  
  // Metadata
  timestamp: "2025-10-12T10:30:00Z",
  domain: "yourcrm.com"
}
```

---

## 🔐 **API Key & Authentication**

### **Getting Your API Key:**

Contact us to receive your unique Client API Key. Example format:
```
yourcompany-api-key-123
```

### **Security:**

**What you provide:**
- ✅ Your Client API Key only



### **API Key Types:**

```javascript
// Demo/Testing
'demo-api-key-789'  // All domains, 100 calls/month

// Production Enterprise
'yourcompany-api-key-123'  // Your domains, custom limits
```

---

## 🌐 **Backend API Endpoints**

### **Base URL:**
```
http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
```

### **Available Endpoints:**

#### **1. Initialize Ribbon**
```
POST /api/ribbon/init

Request:
{
  "apiKey": "your-api-key-123",
  "domain": "yourcrm.com"
}

Response:
{
  "exotelToken": "...", // Managed by widget, not by you
  "userId": "...",      // Managed by widget, not by you
  "features": ["call", "mute", "hold", "dtmf"],
  "clientInfo": {
    "name": "Your Company",
    "plan": "enterprise",
    "remainingCalls": 9995
  }
}
```

#### **2. Log Call Events**
```
POST /api/ribbon/log-call

Request:
{
  "apiKey": "your-api-key-123",
  "event": "connected",
  "data": { ... },
  "timestamp": "2025-10-12T10:30:00Z",
  "domain": "yourcrm.com"
}

Response:
{
  "success": true,
  "logId": "log-1234567890-abc"
}
```

#### **3. Get Configuration**
```
GET /api/ribbon/config
Headers: X-API-Key: your-api-key-123

Response:
{
  "features": ["call", "mute", "hold"],
  "plan": "enterprise",
  "usage": {
    "callsThisMonth": 125,
    "limit": 10000,
    "remaining": 9875
  }
}
```

#### **4. Get Analytics**
```
GET /api/ribbon/analytics
Headers: X-API-Key: your-api-key-123

Response:
{
  "totalCalls": 125,
  "totalDuration": 22500,
  "incomingCalls": 45,
  "outgoingCalls": 80,
  "recentCalls": [ ... ]
}
```

#### **5. Health Check**
```
GET /health

Response:
{
  "status": "healthy",
  "version": "1.0.0",
  "uptime": 86400
}
```

---

## 💼 **CRM Integration Examples**

### **React Application:**

```jsx
import React, { useEffect } from 'react';

function CRMDashboard() {
  useEffect(() => {
    // Initialize on component mount
    if (window.ExotelCallRibbon) {
      window.ExotelCallRibbon.init({
        apiKey: process.env.REACT_APP_EXOTEL_API_KEY,
        apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
        position: 'bottom',
        onCallEvent: handleCallEvent
      });
    }
    
    // Cleanup on unmount
    return () => {
      if (window.ExotelCallRibbon) {
        window.ExotelCallRibbon.destroy();
      }
    };
  }, []);

  const handleCustomerClick = (customer) => {
    window.ExotelCallRibbon.setCustomer({
      phoneNumber: customer.phone,
      name: customer.name,
      customerId: customer.id
    });
  };

  const handleCallEvent = (event, data) => {
    console.log('Call event:', event, data);
    // Update your CRM state/database
  };

  return (
    <div>
      {/* Your CRM UI */}
      <CustomerList onCustomerClick={handleCustomerClick} />
    </div>
  );
}
```

### **Angular Application:**

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';

declare global {
  interface Window {
    ExotelCallRibbon: any;
  }
}

@Component({
  selector: 'app-crm-dashboard',
  template: `
    <div>
      <app-customer-list (customerSelected)="onCustomerSelected($event)">
      </app-customer-list>
    </div>
  `
})
export class CRMDashboardComponent implements OnInit, OnDestroy {
  
  ngOnInit() {
    // Load widget script dynamically
    const script = document.createElement('script');
    script.src = 'https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js';
    script.onload = () => {
      this.initializeRibbon();
    };
    document.body.appendChild(script);
  }

  initializeRibbon() {
    window.ExotelCallRibbon.init({
      apiKey: environment.exotelApiKey,
      apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
      position: 'bottom',
      onCallEvent: this.handleCallEvent.bind(this),
      onReady: () => {
        console.log('Ribbon ready!');
      }
    });
  }

  onCustomerSelected(customer: any) {
    window.ExotelCallRibbon.setCustomer({
      phoneNumber: customer.phone,
      name: customer.name,
      customerId: customer.id
    });
  }

  handleCallEvent(event: string, data: any) {
    console.log('Call event:', event, data);
    // Update your CRM
  }

  ngOnDestroy() {
    if (window.ExotelCallRibbon) {
      window.ExotelCallRibbon.destroy();
    }
  }
}
```

### **Vue.js Application:**

```vue
<template>
  <div id="crm-app">
    <CustomerList @customer-selected="onCustomerSelected" />
  </div>
</template>

<script>
export default {
  name: 'CRMDashboard',
  
  mounted() {
    // Load widget script
    const script = document.createElement('script');
    script.src = 'https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js';
    script.onload = () => {
      this.initializeRibbon();
    };
    document.body.appendChild(script);
  },
  
  methods: {
    initializeRibbon() {
      window.ExotelCallRibbon.init({
        apiKey: process.env.VUE_APP_EXOTEL_API_KEY,
        apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
        position: 'bottom',
        onCallEvent: this.handleCallEvent,
        onReady: () => {
          console.log('Ribbon ready!');
        }
      });
    },
    
    onCustomerSelected(customer) {
      window.ExotelCallRibbon.setCustomer({
        phoneNumber: customer.phone,
        name: customer.name,
        customerId: customer.id
      });
    },
    
    handleCallEvent(event, data) {
      console.log('Call event:', event, data);
      // Update your CRM
    }
  },
  
  beforeUnmount() {
    if (window.ExotelCallRibbon) {
      window.ExotelCallRibbon.destroy();
    }
  }
}
</script>
```

### **Vanilla JavaScript (Plain HTML/JS):**

```html
<!DOCTYPE html>
<html>
<head>
  <title>CRM Application</title>
</head>
<body>
  <div id="customers">
    <!-- Your customer list -->
  </div>

  <!-- Include widget -->
  <script src="https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js"></script>
  
  <script>
    // Wait for widget to load
    window.addEventListener('load', function() {
      // Initialize
      ExotelCallRibbon.init({
        apiKey: 'demo-api-key-789',
        apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
        position: 'bottom',
        onCallEvent: function(event, data) {
          console.log('Call Event:', event, data);
        }
      });
    });

    // Set customer when selected
    function selectCustomer(phone, name, id) {
      ExotelCallRibbon.setCustomer({
        phoneNumber: phone,
        name: name,
        customerId: id
      });
    }
  </script>
</body>
</html>
```

---

## 🎨 **Widget Positioning**

### **Bottom Position (Default):**
```javascript
position: 'bottom'
```
Widget appears at bottom of screen, fixed position.

### **Top Position:**
```javascript
position: 'top'
```
Widget appears at top of screen, fixed position.

### **Floating Position:**
```javascript
position: 'floating'
```
Widget can be dragged anywhere on screen.

---

## 🔔 **Handling Call Events in Your CRM**

### **Collections CRM Example:**

```javascript
function handleCallEvent(event, data) {
  switch(event) {
    case 'connected':
      // Mark customer as "contacted" in database
      markCustomerContacted(data.customerData.customerId);
      
      // Show call scripts for agent
      showCollectionScripts(data.customerData);
      break;
      
    case 'callEnded':
      // Save call outcome
      saveCallOutcome({
        customerId: data.customerData.customerId,
        duration: data.duration,
        timestamp: data.timestamp
      });
      
      // Show follow-up form
      showFollowUpForm(data.customerData);
      break;
  }
}
```

### **Support CRM Example:**

```javascript
function handleCallEvent(event, data) {
  switch(event) {
    case 'incoming':
      // Auto-create ticket from incoming call
      createTicket({
        phone: data.phoneNumber,
        source: 'incoming_call',
        timestamp: data.timestamp
      });
      break;
      
    case 'connected':
      // Load customer history
      loadCustomerHistory(data.customerData.customerId);
      
      // Start call recording note
      startCallNote(data.callSid);
      break;
      
    case 'callEnded':
      // Add call note to ticket
      addCallNoteToTicket({
        ticketId: data.customerData.customerId,
        duration: data.duration,
        notes: getCallNotes()
      });
      break;
  }
}
```

### **Sales CRM Example:**

```javascript
function handleCallEvent(event, data) {
  switch(event) {
    case 'connected':
      // Update lead status to "contacted"
      updateLeadStatus(data.customerData.customerId, 'contacted');
      
      // Start sales script
      showSalesScript(data.customerData);
      break;
      
    case 'callEnded':
      // Show call outcome form
      showOutcomeForm({
        leadId: data.customerData.customerId,
        duration: data.duration,
        options: ['interested', 'not_interested', 'callback', 'no_answer']
      });
      
      // Schedule follow-up
      suggestFollowUp(data.customerData);
      break;
  }
}
```

---

## 🎛️ **Advanced Integration**

### **Dynamic API Key (Recommended for Multi-Tenant):**

```javascript
// Fetch API key from your backend
fetch('/api/get-call-ribbon-config')
  .then(response => response.json())
  .then(config => {
    ExotelCallRibbon.init({
      apiKey: config.apiKey,  // From your backend
      apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
      position: 'bottom',
      onCallEvent: handleCallEvent
    });
  });
```

### **Integration with CRM Workflows:**

```javascript
// Example: Salesforce-like integration
function handleCallEvent(event, data) {
  if (event === 'connected') {
    // Create task in CRM
    createTask({
      type: 'Call',
      subject: `Call with ${data.customerData.name}`,
      relatedTo: data.customerData.customerId,
      startTime: data.timestamp
    });
  }
  
  if (event === 'callEnded') {
    // Update task with duration
    updateTask({
      duration: data.duration,
      endTime: new Date().toISOString(),
      status: 'Completed'
    });
    
    // Log activity
    logActivity({
      type: 'call',
      customerId: data.customerData.customerId,
      duration: data.duration
    });
  }
}
```

### **Keyboard Shortcuts:**

The widget includes built-in keyboard shortcuts:

```
Ctrl/Cmd + D  - Dial
Ctrl/Cmd + M  - Mute/Unmute
Ctrl/Cmd + H  - Hold/Resume
Ctrl/Cmd + C  - Hangup
Space         - Minimize/Expand (when focused)
```

Agents can use these for faster workflow.

---

## 🧪 **Testing Your Integration**

### **Step 1: Test with Demo API Key**

```javascript
ExotelCallRibbon.init({
  apiKey: 'demo-api-key-789',  // Public demo key
  apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
  position: 'bottom'
});
```

### **Step 2: Test Customer Selection**

```javascript
ExotelCallRibbon.setCustomer({
  phoneNumber: '+919876543210',
  name: 'Test Customer',
  customerId: 'TEST001'
});
```

### **Step 3: Test Call Flow**

1. Click "Dial" button (or press Ctrl+D)
2. Watch call timer start
3. Test mute/unmute button
4. Test hold/resume button
5. Open DTMF keypad
6. Click hangup

### **Step 4: Verify Events**

Open browser console (F12) and verify:
- Init event logged
- Call events firing
- Customer data in event payload
- No JavaScript errors

---

## 🐛 **Troubleshooting**

### **Widget Not Loading:**

```javascript
// Check if script loaded
if (typeof ExotelCallRibbon === 'undefined') {
  console.error('Widget script not loaded');
  // Check script URL is correct
}
```

### **API Key Invalid:**

```javascript
// Widget will show error
// Check browser console for:
// "Invalid API key" or "Domain not allowed"

// Verify:
// 1. API key is correct
// 2. Your domain is whitelisted
// 3. Usage limit not exceeded
```

### **Calls Not Working:**

```javascript
// Widget runs in demo mode if:
// - API credentials invalid
// - Network error
// - Exotel service down

// Demo mode allows testing UI without real calls
// Check console for "Demo mode" messages
```

### **CORS Errors:**

```javascript
// If you see CORS errors:
// Contact us to whitelist your domain

// Current CORS: '*' (all domains)
// Production: Restricted to your domains
```

---

## 📱 **Mobile Responsive**

The widget is fully mobile responsive:

- ✅ Touch-friendly buttons
- ✅ Drag support on mobile
- ✅ Responsive layout
- ✅ Works on iOS Safari
- ✅ Works on Android Chrome

**No additional mobile configuration needed.**

---

## 🔒 **Security Best Practices**

### **1. Protect Your API Key:**

```javascript
// ✅ GOOD: Environment variable
const apiKey = process.env.REACT_APP_EXOTEL_KEY;

// ✅ GOOD: Fetch from your backend
fetch('/api/config').then(r => r.json()).then(config => {
  ExotelCallRibbon.init({ apiKey: config.apiKey });
});

// ⚠️ ACCEPTABLE: Hardcoded (if domain-restricted)
const apiKey = 'yourcompany-api-key-123';

// ❌ NEVER: Expose Exotel credentials
// You don't have them anyway - we manage them!
```

### **2. Validate Phone Numbers:**

```javascript
function validatePhone(phone) {
  // E.164 format: +[country][number]
  const regex = /^\+[1-9]\d{1,14}$/;
  return regex.test(phone);
}

// Before setting customer
if (validatePhone(customer.phone)) {
  ExotelCallRibbon.setCustomer(customer);
}
```

### **3. Handle Sensitive Data:**

```javascript
// Don't log sensitive data
function handleCallEvent(event, data) {
  // ❌ Don't log full customer data in production
  console.log('Full data:', data);
  
  // ✅ Log event type only
  console.log('Event:', event);
  
  // Send to your secure backend
  saveToSecureBackend(event, data);
}
```

---

## 📊 **Usage Limits**

### **Demo API Key:**
- **Limit:** 100 calls/month
- **Domains:** All domains allowed
- **Use for:** Testing and development

### **Production API Keys:**
- **Enterprise:** 10,000 calls/month
- **Professional:** 5,000 calls/month
- **Starter:** 1,000 calls/month
- **Domains:** Restricted to your domains

### **Checking Usage:**

```javascript
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/config', {
  headers: {
    'X-API-Key': 'your-api-key-123'
  }
})
.then(r => r.json())
.then(config => {
  console.log('Usage:', config.usage);
  // { callsThisMonth: 125, limit: 10000, remaining: 9875 }
});
```

---

## 🎯 **Quick Integration Checklist**

- [ ] Include widget script in CRM HTML
- [ ] Initialize widget with API key
- [ ] Add customer selection handler
- [ ] Implement call event handler
- [ ] Test with demo API key
- [ ] Verify events in console
- [ ] Test on desktop browser
- [ ] Test on mobile device
- [ ] Get production API key
- [ ] Update to production API key
- [ ] Configure domain whitelist
- [ ] Go live!

---

## 📞 **Support & Resources**

### **Demo & Testing:**
- **Live Demo:** https://d2t5fsybshqnye.cloudfront.net
- **Demo API Key:** `demo-api-key-789`

### **API Endpoints:**
- **Mumbai API:** http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
- **Health Check:** http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/health

### **Documentation:**
- **Architecture:** `/docs/ARCHITECTURE_DIAGRAM.md`
- **Full Integration Guide:** `/docs/CLIENT_INTEGRATION_GUIDE.md`
- **Live Demo Info:** `/docs/LIVE_DEMO_INFO.md`

### **Getting Help:**
- **Email:** support@yourcompany.com
- **API Status:** Check `/health` endpoint
- **Browser Console:** Check for error messages

---

## 💡 **Common Integration Patterns**

### **Pattern 1: Auto-Dial on Customer Select**

```javascript
function selectCustomer(customer) {
  ExotelCallRibbon.setCustomer({
    phoneNumber: customer.phone,
    name: customer.name,
    customerId: customer.id
  });
  
  // Optionally auto-dial
  if (customer.autoCall) {
    ExotelCallRibbon.makeCall(customer.phone);
  }
}
```

### **Pattern 2: Call Queue Management**

```javascript
let callQueue = [];

function addToCallQueue(customer) {
  callQueue.push(customer);
  processNextCall();
}

function processNextCall() {
  if (callQueue.length === 0) return;
  
  const nextCustomer = callQueue.shift();
  ExotelCallRibbon.setCustomer(nextCustomer);
  ExotelCallRibbon.makeCall(nextCustomer.phoneNumber);
}

function handleCallEvent(event, data) {
  if (event === 'callEnded') {
    // Process next in queue
    setTimeout(processNextCall, 2000);
  }
}
```

### **Pattern 3: Call Recording & Notes**

```javascript
let currentCallNotes = '';

function handleCallEvent(event, data) {
  if (event === 'connected') {
    // Show notes interface
    showNotesPanel();
    currentCallNotes = '';
  }
  
  if (event === 'callEnded') {
    // Save call with notes
    saveCallRecord({
      customerId: data.customerData.customerId,
      duration: data.duration,
      notes: currentCallNotes,
      timestamp: data.timestamp
    });
  }
}

function updateCallNotes(notes) {
  currentCallNotes = notes;
}
```

---

## 🚀 **Go Live Checklist**

### **Before Production:**

- [ ] Test with demo API key
- [ ] Verify all call events work
- [ ] Test on different browsers
- [ ] Test on mobile devices
- [ ] Implement error handling
- [ ] Add call logging to your database

### **Production Setup:**

- [ ] Request production API key from us
- [ ] Provide domain whitelist
- [ ] Update widget config with production key
- [ ] Test with production key
- [ ] Monitor usage in dashboard
- [ ] Set up alerting for errors

### **Post-Launch:**

- [ ] Monitor call quality
- [ ] Track usage metrics
- [ ] Gather agent feedback
- [ ] Optimize workflows
- [ ] Plan feature enhancements

---

## 📋 **Minimum Requirements**

### **Browser Support:**
- Chrome 80+
- Firefox 75+
- Safari 13+
- Edge 80+

### **Network:**
- HTTPS recommended (for security)
- Stable internet connection
- Microphone access for agents

### **Your CRM:**
- Can include external JavaScript
- Can make CORS requests
- Modern JavaScript support (ES6+)

---

## 💼 **Example: Complete CRM Integration**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Collections CRM</title>
  <style>
    .customer-list { padding: 20px; }
    .customer-card {
      border: 1px solid #ddd;
      padding: 15px;
      margin: 10px 0;
      cursor: pointer;
    }
    .customer-card:hover { background: #f0f0f0; }
    .customer-card.calling { background: #e3f2fd; }
  </style>
</head>
<body>
  <div class="crm-container">
    <h1>Collections Dashboard</h1>
    
    <div class="customer-list" id="customerList">
      <!-- Customers will be loaded here -->
    </div>
  </div>

  <!-- Include Call Ribbon Widget -->
  <script src="https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js"></script>

  <script>
    // Your customer data
    const customers = [
      { id: 'C001', name: 'John Doe', phone: '+919876543210', balance: 5000 },
      { id: 'C002', name: 'Jane Smith', phone: '+918765432109', balance: 3500 }
    ];

    // Render customers
    function renderCustomers() {
      const list = document.getElementById('customerList');
      list.innerHTML = customers.map(c => `
        <div class="customer-card" data-id="${c.id}" onclick="selectCustomer('${c.id}')">
          <h3>${c.name}</h3>
          <p>Phone: ${c.phone}</p>
          <p>Balance: $${c.balance}</p>
        </div>
      `).join('');
    }

    // Initialize widget
    ExotelCallRibbon.init({
      apiKey: 'collections-crm-api-key-123',
      apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
      position: 'bottom',
      onCallEvent: handleCallEvent,
      onReady: function() {
        console.log('Call ribbon ready!');
        renderCustomers();
      }
    });

    // Handle customer selection
    function selectCustomer(customerId) {
      const customer = customers.find(c => c.id === customerId);
      
      // Highlight selected
      document.querySelectorAll('.customer-card').forEach(el => {
        el.classList.remove('calling');
      });
      document.querySelector(`[data-id="${customerId}"]`).classList.add('calling');
      
      // Load into ribbon
      ExotelCallRibbon.setCustomer({
        phoneNumber: customer.phone,
        name: customer.name,
        customerId: customer.id
      });
    }

    // Handle call events
    function handleCallEvent(event, data) {
      console.log('Call Event:', event, data);
      
      switch(event) {
        case 'connected':
          console.log('Call connected to:', data.customerData.name);
          // Update UI, show call scripts, etc.
          break;
          
        case 'callEnded':
          console.log('Call ended. Duration:', data.duration, 'seconds');
          // Save to database, show follow-up form
          saveCallRecord(data);
          break;
      }
    }

    // Save call to your backend
    function saveCallRecord(data) {
      fetch('/api/calls/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          customerId: data.customerData.customerId,
          phone: data.phoneNumber,
          duration: data.duration,
          timestamp: data.timestamp
        })
      });
    }
  </script>
</body>
</html>
```

---

## 📝 **Integration Summary**

### **What You Need:**

1. **Widget Script URL:**
   ```
   https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js
   ```

2. **Your Client API Key:**
   ```
   Contact us to get: yourcompany-api-key-123
   Demo key available: demo-api-key-789
   ```

3. **API Base URL:**
   ```
   http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
   ```

4. **3 Lines of Code:**
   ```javascript
   // 1. Include script
   <script src="widget-url"></script>
   
   // 2. Initialize
   ExotelCallRibbon.init({ apiKey: 'your-key' });
   
   // 3. Set customer
   ExotelCallRibbon.setCustomer({ phoneNumber, name, customerId });
   ```

---

## ✅ **You're Ready to Integrate!**

Everything you need is in this document. The widget is deployed, tested, and production-ready in Mumbai region.

**Start with the demo API key, test the integration, then contact us for your production API key!**

---

*Last Updated: October 12, 2025*  
*Region: Mumbai (ap-south-1)*  
*Status: Production Ready*  
*Widget Version: 1.3.0*

