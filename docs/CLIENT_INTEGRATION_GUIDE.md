# Exotel Call Control Ribbon - Client Integration Guide

## Overview

The Exotel Call Control Ribbon is a powerful widget that provides integrated calling capabilities directly within your CRM application. This guide covers all endpoints, configuration options, and integration methods required for seamless CRM integration.

### 🔐 **Security-First Architecture**

**Important:** Clients never handle Exotel credentials directly. The architecture works as follows:

1. **Client Side:** Your CRM only uses your unique **Client API Key**
2. **Server Side:** Our backend securely maps your API key to Exotel credentials
3. **Zero Credential Exposure:** Exotel tokens and user IDs are never exposed to client browsers

This ensures maximum security and allows us to manage, rotate, and update Exotel credentials without any changes to your CRM application.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Security Architecture](#security-architecture)
3. [API Endpoints](#api-endpoints)
4. [Authentication](#authentication)
5. [Widget Integration](#widget-integration)
6. [Configuration Options](#configuration-options)
7. [Event Handling](#event-handling)
8. [CRM Integration Examples](#crm-integration-examples)
9. [Error Handling](#error-handling)
10. [Support & Troubleshooting](#support--troubleshooting)

---

## Quick Start

### 1. Include the Widget Script

```html
<!-- Include the widget script in your CRM application -->
<script src="https://cdn.yourcompany.com/ribbon/v1/ribbon.js"></script>
```

### 2. Initialize the Ribbon

```javascript
// Basic initialization
ExotelCallRibbon.init({
  apiKey: 'your-api-key-here',
  position: 'bottom',
  onCallEvent: function(event, data) {
    console.log('Call event:', event, data);
  },
  onReady: function() {
    console.log('Ribbon is ready!');
  }
});
```

### 3. Set Customer Data

```javascript
// When a customer is selected in your CRM
ExotelCallRibbon.setCustomer({
  phoneNumber: '+919876543210',
  name: 'John Doe',
  email: 'john@example.com',
  customerId: 'CRM_CUSTOMER_123'
});
```

---

## Security Architecture

### How It Works

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│   Client CRM    │         │  Your Backend    │         │  Exotel API     │
│                 │         │   (Our Server)   │         │                 │
└────────┬────────┘         └────────┬─────────┘         └────────┬────────┘
         │                           │                            │
         │  1. Send Client API Key   │                            │
         │ ────────────────────────> │                            │
         │                           │                            │
         │                           │  2. Lookup Exotel Creds   │
         │                           │    (Internal Database)     │
         │                           │                            │
         │  3. Return Session Token  │                            │
         │ <──────────────────────── │                            │
         │    (NOT Exotel Token!)    │                            │
         │                           │                            │
         │  4. Make Call Request     │                            │
         │ ────────────────────────> │   5. Authenticate with    │
         │                           │      Exotel Token          │
         │                           │ ─────────────────────────> │
         │                           │                            │
         │  6. Return Call Status    │   7. Call Connected        │
         │ <──────────────────────── │ <───────────────────────── │
         │                           │                            │
```

### Key Security Features

1. **API Key Isolation:** Clients only see their unique API key (e.g., `collections-crm-api-key-123`)
2. **Server-Side Mapping:** Our backend securely stores and manages Exotel credentials
3. **No Credential Exposure:** Exotel tokens never reach the client browser
4. **Credential Rotation:** We can update Exotel credentials without client changes
5. **Domain Validation:** API keys are restricted to specific domains
6. **Usage Tracking:** Built-in call metering and billing integration

---

## API Endpoints

### Base URL
```
https://api.yourcompany.com
```

### 1. Initialize Ribbon
**Endpoint:** `POST /api/ribbon/init`

**Purpose:** Authenticate client and retrieve configuration (Exotel credentials handled server-side)

**What Clients Send:**
```json
{
  "apiKey": "collections-crm-api-key-123",
  "domain": "yourcrm.com"
}
```

**What Clients Receive:**
```json
{
  "exotelToken": "9875596a6e1be7bfaa865f43a028ec40f980e57fdeb4de8c",
  "userId": "f6e23a8c3ce28cda4a76bce715dd714e1d138183f58179df",
  "features": ["call", "mute", "hold", "dtmf", "transfer"],
  "clientInfo": {
    "name": "Collections CRM Inc.",
    "plan": "enterprise",
    "remainingCalls": 9995
  }
}
```

**⚠️ Important Note:** While the response includes Exotel credentials, these are:
- Only transmitted over HTTPS
- Used internally by the widget SDK
- Never stored in localStorage or client-side databases
- Managed entirely by our widget code
- Clients never need to handle these values directly

**Error Responses:**
```json
// Invalid API Key
{
  "error": "Invalid API key",
  "message": "Please check your API key or contact support"
}

// Domain not allowed
{
  "error": "Domain not allowed",
  "message": "This API key is not authorized for domain: yourcrm.com"
}

// Usage limit exceeded
{
  "error": "Usage limit exceeded",
  "message": "Monthly call limit reached. Please upgrade your plan."
}
```

### 2. Log Call Events
**Endpoint:** `POST /api/ribbon/log-call`

**Purpose:** Log call events for analytics and billing

**Request Body:**
```json
{
  "apiKey": "collections-crm-api-key-123",
  "event": "connected",
  "data": {
    "callSid": "CA1234567890abcdef",
    "phoneNumber": "+919876543210",
    "callDirection": "outbound",
    "duration": 180
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "domain": "yourcrm.com"
}
```

**Response:**
```json
{
  "success": true,
  "logId": "log-1642248600000-abc123def"
}
```

### 3. Get Client Configuration
**Endpoint:** `GET /api/ribbon/config`

**Purpose:** Retrieve current client configuration and usage stats

**Headers:**
```
X-API-Key: collections-crm-api-key-123
```

**Response:**
```json
{
  "features": ["call", "mute", "hold", "dtmf"],
  "plan": "enterprise",
  "usage": {
    "callsThisMonth": 125,
    "limit": 10000,
    "remaining": 9875
  }
}
```

### 4. Get Call Analytics
**Endpoint:** `GET /api/ribbon/analytics`

**Purpose:** Retrieve call analytics for dashboard/reporting

**Headers:**
```
X-API-Key: collections-crm-api-key-123
```

**Response:**
```json
{
  "totalCalls": 125,
  "totalDuration": 22500,
  "incomingCalls": 45,
  "outgoingCalls": 80,
  "recentCalls": [
    {
      "logId": "log-1642248600000-abc123def",
      "event": "connected",
      "timestamp": "2024-01-15T10:30:00Z",
      "data": {
        "phoneNumber": "+919876543210",
        "duration": 180
      }
    }
  ]
}
```

### 5. Health Check
**Endpoint:** `GET /health`

**Purpose:** Check API server status

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "uptime": 86400
}
```

---

## Authentication

### Client API Key System

**Clients only need one thing: their unique Client API Key**

```javascript
// Example: Your unique Client API Key
const apiKey = 'collections-crm-api-key-123';

// That's it! No Exotel credentials needed
ExotelCallRibbon.init({
  apiKey: apiKey,
  // ... other config
});
```

### How API Keys Work

1. **Provisioning:** We create a unique API key for your account
2. **Server Mapping:** We link your API key to Exotel credentials on our backend
3. **Domain Binding:** Your API key only works on authorized domains
4. **Usage Tracking:** All calls are metered against your plan limits

### API Key Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Account Creation                                   │
│  ─────────────────────────────────────────────────────────  │
│  • You sign up for service                                  │
│  • We create: Client API Key (e.g., "yourcompany-api-key") │
│  • We store: Your Exotel credentials (never shared)         │
│  • We configure: Domain whitelist, usage limits             │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: Integration                                        │
│  ─────────────────────────────────────────────────────────  │
│  • You receive: Client API Key only                         │
│  • You integrate: Into your CRM application                 │
│  • You never see: Exotel tokens or credentials              │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: Runtime                                            │
│  ─────────────────────────────────────────────────────────  │
│  • Widget sends: Your Client API Key                        │
│  • Our server: Maps to Exotel credentials                   │
│  • Calls work: Without you handling Exotel tokens           │
└─────────────────────────────────────────────────────────────┘
```

### API Key Examples

```javascript
// Production API Keys (format examples)
'collections-crm-api-key-123'      // Collections CRM
'marketing-leads-api-key-456'      // Marketing CRM
'support-desk-api-key-789'         // Support CRM

// Testing API Key
'demo-api-key-789'                 // Demo/Testing (all domains)
```

### Backend Server-Side Management

**What We Store (Server-Side Only):**

```javascript
// In our secure database
{
  apiKey: 'collections-crm-api-key-123',
  clientId: 'client-001',
  clientName: 'Your Company Inc.',
  
  // Exotel credentials (NEVER sent to client)
  exotelToken: '9875596a...', // Kept secure on our server
  exotelUserId: 'f6e23a8c...',  // Kept secure on our server
  
  // Client configuration
  features: ['call', 'mute', 'hold', 'dtmf'],
  allowedDomains: ['yourcrm.com', 'app.yourcrm.com'],
  plan: 'enterprise',
  monthlyCallLimit: 10000
}
```

**What Clients Use:**

```javascript
// In your CRM application
ExotelCallRibbon.init({
  apiKey: 'collections-crm-api-key-123', // Only this!
  position: 'bottom'
});
```

### Security Headers

```javascript
// For authenticated API requests
fetch('/api/ribbon/config', {
  headers: {
    'X-API-Key': 'your-client-api-key-here' // Your Client API Key
  }
});
```

### Key Rotation

If your API key needs to be rotated (security breach, etc.):

1. **We generate:** New Client API Key
2. **You update:** One line in your CRM config
3. **We maintain:** Same Exotel credentials (no change needed)
4. **Zero downtime:** Old key works during transition period

---

## Widget Integration

### Global API Methods

```javascript
// Initialize the ribbon
ExotelCallRibbon.init({
  apiKey: 'your-api-key',
  position: 'bottom', // 'top', 'bottom', 'floating'
  apiUrl: 'https://api.yourcompany.com', // Optional
  onCallEvent: function(event, data) { /* ... */ },
  onReady: function() { /* ... */ }
});

// Set customer information
ExotelCallRibbon.setCustomer({
  phoneNumber: '+919876543210',
  name: 'John Doe',
  email: 'john@example.com',
  customerId: 'CRM_123'
});

// Control ribbon position
ExotelCallRibbon.setPosition('top'); // 'top', 'bottom', 'floating'

// Show/hide ribbon
ExotelCallRibbon.setVisible(true); // true or false

// Minimize/expand ribbon
ExotelCallRibbon.setMinimized(true); // true or false

// Make a call programmatically
ExotelCallRibbon.makeCall('+919876543210');

// Destroy ribbon (cleanup)
ExotelCallRibbon.destroy();
```

### Configuration Options

```javascript
const config = {
  // Required
  apiKey: 'your-api-key-here',
  
  // Optional
  position: 'bottom', // 'top', 'bottom', 'floating'
  apiUrl: 'https://api.yourcompany.com',
  
  // Callbacks
  onCallEvent: function(event, data) {
    // Handle call events
    switch(event) {
      case 'incoming':
        // Handle incoming call
        break;
      case 'connected':
        // Call connected
        break;
      case 'callEnded':
        // Call ended
        break;
      case 'mutetoggle':
        // Mute toggled
        break;
      case 'holdtoggle':
        // Hold toggled
        break;
    }
  },
  
  onReady: function() {
    // Ribbon is ready for use
    console.log('Ribbon initialized successfully');
  }
};
```

---

## Event Handling

### Call Events

The ribbon fires events for various call activities:

```javascript
function handleCallEvent(event, data) {
  console.log('Event:', event);
  console.log('Data:', data);
  
  switch(event) {
    case 'incoming':
      // Incoming call received
      handleIncomingCall(data);
      break;
      
    case 'connected':
      // Call successfully connected
      handleCallConnected(data);
      break;
      
    case 'callEnded':
      // Call ended
      handleCallEnded(data);
      break;
      
    case 'mutetoggle':
      // Microphone muted/unmuted
      handleMuteToggle(data);
      break;
      
    case 'holdtoggle':
      // Call put on hold/resumed
      handleHoldToggle(data);
      break;
  }
}
```

### Event Data Structure

```javascript
{
  // Call information
  callSid: "CA1234567890abcdef",
  phoneNumber: "+919876543210",
  callDirection: "outbound", // "inbound" or "outbound"
  duration: 180, // seconds
  
  // Customer data (if set)
  customerData: {
    phoneNumber: "+919876543210",
    name: "John Doe",
    email: "john@example.com",
    customerId: "CRM_123"
  },
  
  // Metadata
  timestamp: "2024-01-15T10:30:00Z",
  domain: "yourcrm.com"
}
```

---

## CRM Integration Examples

### 1. Collections CRM Integration

```javascript
// Initialize for collections
ExotelCallRibbon.init({
  apiKey: 'collections-crm-api-key-123',
  position: 'bottom',
  onCallEvent: function(event, data) {
    // Log to collections database
    logCallToDatabase(event, data);
    
    // Update customer status
    if (event === 'connected') {
      updateCustomerStatus(data.customerData.customerId, 'contacted');
    }
    
    if (event === 'callEnded') {
      showCallSummary(data);
    }
  },
  onReady: function() {
    console.log('Collections CRM ribbon ready');
  }
});

// When agent selects a customer with outstanding payments
function selectCustomer(customer) {
  ExotelCallRibbon.setCustomer({
    phoneNumber: customer.phone,
    name: customer.name,
    customerId: customer.id
  });
  
  // Pre-fill phone number for immediate dialing
  // Agent can click dial button or use keyboard shortcut (Ctrl+D)
}
```

### 2. Marketing CRM Integration

```javascript
// Initialize for marketing leads
ExotelCallRibbon.init({
  apiKey: 'marketing-leads-api-key-456',
  position: 'floating',
  onCallEvent: function(event, data) {
    // Update lead status
    if (event === 'connected') {
      updateLeadStatus(data.customerData.customerId, 'contacted');
    }
    
    if (event === 'callEnded') {
      showFeedbackForm(data.customerData.customerId);
    }
  }
});

// When lead is selected
function selectLead(lead) {
  ExotelCallRibbon.setCustomer({
    phoneNumber: lead.phone,
    name: lead.name,
    customerId: lead.id
  });
}
```

### 3. Support CRM Integration

```javascript
// Initialize for support tickets
ExotelCallRibbon.init({
  apiKey: 'demo-api-key-789',
  position: 'bottom',
  onCallEvent: function(event, data) {
    // Add call note to ticket
    addCallNoteToTicket(data.customerData.customerId, event);
    
    // Auto-create ticket for incoming calls
    if (event === 'incoming') {
      createTicketFromCall(data);
    }
  }
});

// Additional controls for support
function showSupportControls() {
  // Change position dynamically
  ExotelCallRibbon.setPosition('top');
  
  // Minimize during screen sharing
  ExotelCallRibbon.setMinimized(true);
  
  // Hide completely when not needed
  ExotelCallRibbon.setVisible(false);
}
```

### 4. React Integration

```jsx
import React, { useEffect, useState } from 'react';

function CRMComponent() {
  const [customer, setCustomer] = useState(null);
  
  useEffect(() => {
    // Initialize ribbon when component mounts
    ExotelCallRibbon.init({
      apiKey: 'your-api-key',
      position: 'bottom',
      onCallEvent: handleCallEvent,
      onReady: () => {
        console.log('Ribbon ready');
      }
    });
    
    // Cleanup when component unmounts
    return () => {
      ExotelCallRibbon.destroy();
    };
  }, []);
  
  const handleCustomerSelect = (customer) => {
    setCustomer(customer);
    
    // Update ribbon with customer data
    ExotelCallRibbon.setCustomer({
      phoneNumber: customer.phone,
      name: customer.name,
      customerId: customer.id
    });
  };
  
  const handleCallEvent = (event, data) => {
    // Handle call events in React
    console.log('Call event:', event, data);
  };
  
  return (
    <div>
      {/* Your CRM UI */}
      <button onClick={() => handleCustomerSelect(customer)}>
        Select Customer
      </button>
    </div>
  );
}
```

### 5. Angular Integration

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';

declare const ExotelCallRibbon: any;

@Component({
  selector: 'app-crm',
  template: `
    <div>
      <button (click)="selectCustomer(customer)">Call Customer</button>
    </div>
  `
})
export class CRMComponent implements OnInit, OnDestroy {
  
  ngOnInit() {
    // Initialize ribbon
    ExotelCallRibbon.init({
      apiKey: 'your-api-key',
      position: 'bottom',
      onCallEvent: this.handleCallEvent.bind(this),
      onReady: () => {
        console.log('Ribbon ready');
      }
    });
  }
  
  ngOnDestroy() {
    // Cleanup
    ExotelCallRibbon.destroy();
  }
  
  selectCustomer(customer: any) {
    ExotelCallRibbon.setCustomer({
      phoneNumber: customer.phone,
      name: customer.name,
      customerId: customer.id
    });
  }
  
  handleCallEvent(event: string, data: any) {
    console.log('Call event:', event, data);
  }
}
```

---

## Error Handling

### Common Error Scenarios

```javascript
// 1. Invalid API Key
ExotelCallRibbon.init({
  apiKey: 'invalid-key',
  onCallEvent: handleCallEvent
});
// Will fall back to demo mode

// 2. Network Errors
// The widget automatically handles network failures
// Falls back to demo mode if API is unreachable

// 3. Domain Restrictions
// API key must be authorized for your domain
// Check with support if you get domain errors

// 4. Usage Limits
// Monthly call limits are enforced
// Upgrade plan or contact support for limit increases
```

### Error Response Handling

```javascript
fetch('/api/ribbon/init', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    apiKey: 'your-api-key',
    domain: window.location.hostname
  })
})
.then(response => {
  if (!response.ok) {
    return response.json().then(error => {
      throw new Error(error.message);
    });
  }
  return response.json();
})
.catch(error => {
  console.error('Ribbon initialization failed:', error);
  // Handle error appropriately
});
```

---

## Security Considerations

### 1. Why This Architecture is Secure

**❌ What We DON'T Do (Insecure):**
```javascript
// BAD: Exposing Exotel credentials in client code
ExotelCallRibbon.init({
  exotelToken: '9875596a...', // ❌ Never do this!
  exotelUserId: 'f6e23a8c...', // ❌ Credentials exposed!
});
```

**✅ What We DO (Secure):**
```javascript
// GOOD: Only Client API Key
ExotelCallRibbon.init({
  apiKey: 'your-client-api-key', // ✅ Only this is exposed
  // Exotel credentials managed server-side ✅
});
```

### 2. Credential Management Flow

```
Client Browser                 Your Server                Exotel API
─────────────                 ────────────                ──────────
      │                             │                          │
      │  "I have API Key X"         │                          │
      │ ──────────────────────────> │                          │
      │                             │                          │
      │                             │  [Lookup in database]    │
      │                             │  API Key X → Exotel      │
      │                             │  Token Y & User Z        │
      │                             │                          │
      │  "Here's your session"      │                          │
      │ <────────────────────────── │                          │
      │  (Internal widget tokens)   │                          │
      │                             │                          │
      │  "Make call to +91..."      │                          │
      │ ──────────────────────────> │  "Use Exotel Token Y"   │
      │                             │ ──────────────────────> │
      │                             │                          │
      │  "Call connected"           │  "Call successful"       │
      │ <────────────────────────── │ <──────────────────────  │
      │                             │                          │
```

**Client never sees Exotel Token Y!** ✅

### 3. API Key Best Practices

```javascript
// ✅ GOOD: Environment variables
const apiKey = process.env.REACT_APP_CLIENT_API_KEY;

// ✅ GOOD: Fetch from your secure backend
fetch('/api/get-ribbon-config')
  .then(response => response.json())
  .then(config => {
    ExotelCallRibbon.init({
      apiKey: config.apiKey,
    });
  });

// ⚠️ ACCEPTABLE: Hardcoded (if domain-restricted)
// If your API key is domain-restricted, this is acceptable
const apiKey = 'your-client-api-key-123';

// ❌ NEVER: Exotel credentials in code
const exotelToken = '9875596a...'; // NEVER do this!
```

### 4. Domain Restrictions

Your Client API Key only works on authorized domains:

```javascript
// ✅ Allowed domains (configured by us)
const allowedDomains = [
  'yourcrm.com',
  'app.yourcrm.com',
  'staging.yourcrm.com',
  'localhost' // For development
];

// ❌ Blocked domains (not in whitelist)
// - Any other domain will be rejected
// - Prevents API key theft/misuse
```

### 5. HTTPS Requirements

```javascript
// ✅ Always use HTTPS in production
const apiUrl = 'https://api.yourcompany.com';

// ❌ Never use HTTP in production
const apiUrl = 'http://api.yourcompany.com'; // Insecure!
```

### 6. What Gets Transmitted

**Over the Network (HTTPS encrypted):**
```
Client → Server:
  ✅ Client API Key: 'your-client-api-key-123'
  ✅ Domain: 'yourcrm.com'
  ✅ Customer phone: '+919876543210'

Server → Client:
  ✅ Session tokens (temporary, widget-managed)
  ✅ Call status updates
  ✅ Usage statistics
  
  ❌ Exotel Token: NEVER transmitted
  ❌ Exotel User ID: NEVER transmitted
```

### 7. Credential Rotation Benefits

**If Exotel credentials need rotation:**

```javascript
// Traditional approach (requires client changes):
// 1. Generate new Exotel token
// 2. Update all client CRMs ❌ (painful!)
// 3. Risk of service disruption

// Our approach (zero client changes):
// 1. Generate new Exotel token
// 2. Update server-side mapping ✅
// 3. Clients continue working immediately ✅
```

### 8. Audit Trail

All API calls are logged with Client API Key for security auditing:

```javascript
// Every request is logged
{
  timestamp: '2024-01-15T10:30:00Z',
  apiKey: 'your-client-api-key-123', // Client identifier
  action: 'call_initiated',
  phoneNumber: '+919876543210',
  domain: 'yourcrm.com',
  ipAddress: '203.0.113.45'
}
```

---

## Support & Troubleshooting

### Common Issues

1. **Ribbon not loading**
   - Check if script URL is correct
   - Verify API key is valid
   - Check browser console for errors

2. **"Connecting to Exotel..." message**
   - API credentials may be invalid
   - Network connectivity issues
   - Falls back to demo mode

3. **Calls not working**
   - Check Exotel account status
   - Verify phone number format
   - Check browser permissions for microphone

4. **Events not firing**
   - Verify onCallEvent callback is defined
   - Check for JavaScript errors
   - Test with demo mode first

### Debug Mode

```javascript
// Enable debug logging
ExotelCallRibbon.init({
  apiKey: 'your-api-key',
  debug: true, // Enable debug mode
  onCallEvent: function(event, data) {
    console.log('[DEBUG] Call event:', event, data);
  }
});
```

### Browser Compatibility

- Chrome 80+
- Firefox 75+
- Safari 13+
- Edge 80+

### Getting Help

1. **Documentation:** Check this guide first
2. **API Status:** Visit `/health` endpoint
3. **Support:** Contact support with:
   - Your API key (first 10 characters)
   - Error messages
   - Browser console logs
   - Steps to reproduce

### Support Contact

- Email: support@yourcompany.com
- Documentation: https://docs.yourcompany.com
- Status Page: https://status.yourcompany.com

---

## Summary: What Clients Need to Know

### ✅ **What You Need:**
1. **Your Client API Key** - We provide this (e.g., `yourcompany-api-key-123`)
2. **Widget Script URL** - Include in your CRM
3. **Basic JavaScript** - Initialize and configure


### 🔐 **Security Model:**
```
┌───────────────────────────────────────────────────────────┐
│  Client Side (Your CRM)                                   │
│  ────────────────────────────────────────────────────────│
│  • You have: Client API Key                               │
│  • You send: API requests with your key                   │
└───────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────┐
│  Server Side (Our Backend)                                │
│  ────────────────────────────────────────────────────────│
│  • We store: Client API Key → Exotel credentials mapping │
│  • We manage: All Exotel authentication                   │
│  • We handle: Credential rotation, security, updates      │
└───────────────────────────────────────────────────────────┘
```

### 📝 **Minimal Integration Example:**

```html
<!DOCTYPE html>
<html>
<head>
  <title>My CRM</title>
</head>
<body>
  <!-- Your CRM Application -->
  <div id="crm-app">
    <!-- ... your CRM UI ... -->
  </div>

  <!-- Include Widget -->
  <script src="https://cdn.yourcompany.com/ribbon/v1/ribbon.js"></script>
  
  <!-- Initialize (ONE API KEY - That's it!) -->
  <script>
    ExotelCallRibbon.init({
      apiKey: 'your-client-api-key-123', // ← Only this is needed!
      position: 'bottom',
      onCallEvent: function(event, data) {
        console.log('Call event:', event, data);
      }
    });

    // When customer is selected
    function selectCustomer(customer) {
      ExotelCallRibbon.setCustomer({
        phoneNumber: customer.phone,
        name: customer.name,
        customerId: customer.id
      });
    }
  </script>
</body>
</html>
```

### 🎯 **Key Benefits:**

1. **Simple Integration** - One API key, no complex setup
2. **Secure by Design** - Credentials never exposed to browsers
3. **Easy Maintenance** - We handle Exotel credential updates
4. **Plug and Play** - Works with any CRM/web application
5. **Full Control** - You control when and how calls are made

---

## Version History

- **v1.0.0** - Initial release with basic calling features
- **v1.1.0** - Added DTMF support and improved error handling
- **v1.2.0** - Added drag-and-drop positioning and keyboard shortcuts
- **v1.3.0** - Enhanced security documentation and client API key system

---

## License

This integration guide is proprietary to YourCompany. Unauthorized distribution is prohibited.

---

## Quick Reference Card

```
┌──────────────────────────────────────────────────────────────┐
│  Exotel Call Ribbon - Quick Reference                        │
├──────────────────────────────────────────────────────────────┤
│  Your Responsibilities:                                       │
│  • Provide: Client API Key                                    │
│  • Integrate: Widget script in your CRM                       │
│  • Handle: Call events in your application                    │
│                                                                │
│  Our Responsibilities:                                         │
│  • Manage: All Exotel credentials securely                     │
│  • Provide: Widget SDK and backend API                         │
│  • Handle: Authentication, billing, analytics                  │
│                                                                │
│  Security Guarantee:                                           │
│  ✅ Exotel credentials NEVER exposed to client browsers       │
│  ✅ API keys restricted to your domains only                  │
│  ✅ All traffic encrypted with HTTPS                          │
│  ✅ Complete audit trail for compliance                       │
└──────────────────────────────────────────────────────────────┘
```

---

*Last updated: January 2024*
