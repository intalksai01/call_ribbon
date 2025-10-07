# 📋 Client Integration Guide - Exotel Call Ribbon

**For CRM Applications** - Integrate powerful call control features in 3 simple steps!

---

## 🎯 What You'll Get

After integration, your CRM will have:
- 📞 **Make & Receive Calls** - Click-to-dial from customer records
- 🎛️ **Call Controls** - Mute, hold, hangup, DTMF keypad
- 📊 **Call Logging** - Automatic call tracking
- 🎨 **Customizable UI** - Matches your CRM's look and feel
- 📱 **Mobile Responsive** - Works on all devices

---

## ⏱️ Integration Time

- **Basic Integration**: 5 minutes
- **Full Integration with CRM**: 30 minutes
- **Testing**: 15 minutes

**Total**: Less than 1 hour! ⚡

---

## ✅ Prerequisites

Before you start, make sure you have:
- [ ] Your unique API key (provided by us)
- [ ] Access to your CRM's codebase
- [ ] Ability to add script tags to your HTML

---

## 🚀 Quick Start (3 Steps)

### **Step 1: Add CSS** (1 line)

Add this line to your HTML `<head>` section:

```html
<link rel="stylesheet" href="https://cdn.yourcompany.com/ribbon.css">
```

### **Step 2: Add JavaScript** (1 line)

Add this line before the closing `</body>` tag:

```html
<script src="https://cdn.yourcompany.com/ribbon.js"></script>
```

### **Step 3: Initialize** (5-10 lines)

Add this script to initialize the ribbon:

```html
<script>
  // Initialize the Call Control Ribbon
  ExotelCallRibbon.init({
    apiKey: 'YOUR-API-KEY-HERE',  // Provided by us
    position: 'bottom',            // or 'top', 'floating'
    onCallEvent: function(event, data) {
      // This is called for every call event
      console.log('Call event:', event, data);
    }
  });
</script>
```

**That's it!** The ribbon will appear at the bottom of your page. 🎉

---

## 📝 Complete Example

Here's a complete HTML example:

```html
<!DOCTYPE html>
<html>
<head>
  <title>My CRM Application</title>
  
  <!-- Your existing CSS -->
  <link rel="stylesheet" href="/css/your-crm.css">
  
  <!-- Step 1: Add Call Ribbon CSS -->
  <link rel="stylesheet" href="https://cdn.yourcompany.com/ribbon.css">
</head>
<body>

  <!-- Your CRM content -->
  <div id="crm-app">
    <h1>Customer Management</h1>
    
    <div class="customer-list">
      <!-- Your customer list -->
      <div class="customer" onclick="selectCustomer({
        id: '123',
        name: 'John Doe',
        phone: '+919876543210'
      })">
        <h3>John Doe</h3>
        <p>+919876543210</p>
      </div>
    </div>
  </div>

  <!-- Step 2: Add Call Ribbon JS -->
  <script src="https://cdn.yourcompany.com/ribbon.js"></script>
  
  <!-- Step 3: Initialize -->
  <script>
    // Initialize the ribbon
    ExotelCallRibbon.init({
      apiKey: 'your-api-key-here',
      position: 'bottom',
      onCallEvent: function(event, data) {
        console.log('Call event:', event, data);
        
        // Save call to your database
        if (event === 'connected') {
          saveCallToDatabase(data);
        }
      }
    });

    // When customer is selected, update the ribbon
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

---

## 🎨 Configuration Options

### **Basic Configuration:**

```javascript
ExotelCallRibbon.init({
  apiKey: 'your-api-key',      // Required
  position: 'bottom',          // Optional: 'top', 'bottom', 'floating'
  onCallEvent: function(e, d){}, // Optional: Event callback
  onReady: function(){}        // Optional: Ready callback
});
```

### **Position Options:**

```javascript
// Bottom bar (default)
ExotelCallRibbon.init({ position: 'bottom' });

// Top bar
ExotelCallRibbon.init({ position: 'top' });

// Floating box (bottom-right corner)
ExotelCallRibbon.init({ position: 'floating' });
```

---

## 👤 Setting Customer Data

When a user selects a customer in your CRM, update the ribbon:

```javascript
ExotelCallRibbon.setCustomer({
  phoneNumber: '+919876543210',  // Required
  name: 'John Doe',              // Optional (displays in ribbon)
  email: 'john@example.com',     // Optional
  customerId: '12345'            // Optional (your CRM's ID)
});
```

**The ribbon will:**
- Pre-fill the phone number
- Display the customer's name in the header
- Include customer data in all call events

---

## 📞 Call Events

Listen to call events to integrate with your CRM:

```javascript
ExotelCallRibbon.init({
  apiKey: 'your-api-key',
  onCallEvent: function(eventType, data) {
    switch(eventType) {
      case 'incoming':
        // Incoming call received
        showIncomingCallPopup(data);
        break;
        
      case 'connected':
        // Call connected (outgoing or incoming)
        startCallTimer(data);
        logCallStart(data);
        break;
        
      case 'callEnded':
        // Call ended
        stopCallTimer(data);
        logCallEnd(data);
        showCallSummary(data);
        break;
        
      case 'holdtoggle':
        // Call put on hold or resumed
        updateCallStatus(data);
        break;
        
      case 'mutetoggle':
        // Call muted or unmuted
        updateCallStatus(data);
        break;
    }
  }
});
```

### **Event Data Structure:**

```javascript
{
  // Call information
  callId: "abc123...",
  callSid: "xyz789...",
  callDirection: "outbound", // or "inbound"
  callState: "connected",
  callDuration: 125, // seconds
  
  // Customer information (what you passed in)
  customerData: {
    phoneNumber: "+919876543210",
    name: "John Doe",
    customerId: "12345"
  },
  
  // Timestamp
  timestamp: "2024-01-15T10:30:00.000Z"
}
```

---

## 🔧 Advanced Features

### **Change Position Dynamically:**

```javascript
// Change to top
ExotelCallRibbon.setPosition('top');

// Change to floating
ExotelCallRibbon.setPosition('floating');
```

### **Show/Hide Ribbon:**

```javascript
// Hide ribbon
ExotelCallRibbon.setVisible(false);

// Show ribbon
ExotelCallRibbon.setVisible(true);
```

### **Minimize/Expand:**

```javascript
// Minimize ribbon
ExotelCallRibbon.setMinimized(true);

// Expand ribbon
ExotelCallRibbon.setMinimized(false);
```

### **Programmatic Calling:**

```javascript
// Make a call programmatically
ExotelCallRibbon.makeCall('+919876543210');
```

### **Destroy Ribbon:**

```javascript
// Remove ribbon completely
ExotelCallRibbon.destroy();
```

---

## 🎭 Framework-Specific Integration

### **React Integration:**

```javascript
import React, { useEffect } from 'react';

function App() {
  useEffect(() => {
    // Load CSS
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'https://cdn.yourcompany.com/ribbon.css';
    document.head.appendChild(link);

    // Load JS
    const script = document.createElement('script');
    script.src = 'https://cdn.yourcompany.com/ribbon.js';
    script.onload = () => {
      window.ExotelCallRibbon.init({
        apiKey: 'your-api-key',
        position: 'bottom',
        onCallEvent: (event, data) => {
          console.log('Call event:', event, data);
        }
      });
    };
    document.body.appendChild(script);

    return () => {
      window.ExotelCallRibbon?.destroy();
    };
  }, []);

  const handleCustomerClick = (customer) => {
    window.ExotelCallRibbon.setCustomer(customer);
  };

  return (
    <div>
      {/* Your CRM UI */}
    </div>
  );
}
```

### **Angular Integration:**

```typescript
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent implements OnInit {
  ngOnInit() {
    this.loadCallRibbon();
  }

  loadCallRibbon() {
    // Load CSS
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'https://cdn.yourcompany.com/ribbon.css';
    document.head.appendChild(link);

    // Load JS
    const script = document.createElement('script');
    script.src = 'https://cdn.yourcompany.com/ribbon.js';
    script.onload = () => {
      (window as any).ExotelCallRibbon.init({
        apiKey: 'your-api-key',
        position: 'bottom',
        onCallEvent: (event: string, data: any) => {
          console.log('Call event:', event, data);
        }
      });
    };
    document.body.appendChild(script);
  }

  selectCustomer(customer: any) {
    (window as any).ExotelCallRibbon.setCustomer(customer);
  }
}
```

### **Vue Integration:**

```javascript
export default {
  mounted() {
    this.loadCallRibbon();
  },
  methods: {
    loadCallRibbon() {
      // Load CSS
      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = 'https://cdn.yourcompany.com/ribbon.css';
      document.head.appendChild(link);

      // Load JS
      const script = document.createElement('script');
      script.src = 'https://cdn.yourcompany.com/ribbon.js';
      script.onload = () => {
        window.ExotelCallRibbon.init({
          apiKey: 'your-api-key',
          position: 'bottom',
          onCallEvent: (event, data) => {
            console.log('Call event:', event, data);
          }
        });
      };
      document.body.appendChild(script);
    },
    selectCustomer(customer) {
      window.ExotelCallRibbon.setCustomer(customer);
    }
  }
}
```

---

## 🐛 Troubleshooting

### **Problem: Ribbon not appearing**

**Solutions:**
1. Check browser console for errors (Press F12)
2. Verify CDN URLs are correct
3. Ensure API key is valid
4. Check that scripts load after DOM is ready

```javascript
// Wait for DOM to be ready
document.addEventListener('DOMContentLoaded', function() {
  ExotelCallRibbon.init({ ... });
});
```

### **Problem: Invalid API key error**

**Solutions:**
1. Double-check your API key
2. Ensure no extra spaces in the key
3. Contact support for a new key

### **Problem: Domain not allowed**

**Solutions:**
1. Check if your domain is whitelisted
2. Contact support to whitelist your domain
3. For testing, use localhost (usually whitelisted)

### **Problem: Phone number not dialing**

**Solutions:**
1. Verify phone number format: `+[country code][number]`
2. Example: `+919876543210` (India)
3. Must be 10-14 digits with optional + prefix

### **Problem: No audio during calls**

**Solutions:**
1. Check browser permissions for microphone
2. Use HTTPS (required for WebRTC)
3. Try a different browser (Chrome recommended)
4. Check firewall/network settings

---

## 📱 Browser Compatibility

| Browser | Minimum Version | Status |
|---------|----------------|--------|
| Chrome | 70+ | ✅ Recommended |
| Firefox | 65+ | ✅ Supported |
| Safari | 12+ | ✅ Supported |
| Edge | 79+ | ✅ Supported |
| IE | - | ❌ Not Supported |

---

## 🔐 Security

- ✅ Your API key is required for all calls
- ✅ Domain whitelisting prevents unauthorized use
- ✅ All calls are made over secure HTTPS/WSS
- ✅ Exotel credentials are never exposed to browsers
- ✅ Call logs are encrypted in transit and at rest

---

## 📊 Usage Limits

Check your plan limits:

| Plan | Calls/Month | Overage |
|------|-------------|---------|
| Trial | 100 | N/A |
| Professional | 5,000 | $0.02/call |
| Enterprise | 10,000 | $0.01/call |

Monitor your usage in the dashboard: `https://dashboard.yourcompany.com`

---

## 🆘 Support

### **Need Help?**

- 📧 **Email**: support@yourcompany.com
- 💬 **Live Chat**: https://yourcompany.com/support
- 📞 **Phone**: +1-XXX-XXX-XXXX (Business hours)
- 📖 **Knowledge Base**: https://docs.yourcompany.com

### **Response Times:**

- Trial: 48 hours
- Professional: 24 hours
- Enterprise: 4 hours (Priority)

---

## 🎓 Video Tutorials

Watch step-by-step integration videos:

- 🎥 **Quick Start** (5 min): https://youtu.be/xxx
- 🎥 **React Integration** (10 min): https://youtu.be/yyy
- 🎥 **Angular Integration** (10 min): https://youtu.be/zzz
- 🎥 **Advanced Features** (15 min): https://youtu.be/aaa

---

## 📈 Best Practices

### **1. Save Call Logs**

Always save call data to your database:

```javascript
onCallEvent: function(event, data) {
  if (event === 'callEnded') {
    fetch('/api/calls', {
      method: 'POST',
      body: JSON.stringify({
        customerId: data.customerData.customerId,
        duration: data.callDuration,
        direction: data.callDirection,
        timestamp: data.timestamp
      })
    });
  }
}
```

### **2. Show Call Notifications**

Notify users of incoming calls:

```javascript
onCallEvent: function(event, data) {
  if (event === 'incoming') {
    showNotification('Incoming call from ' + data.customerData.name);
    playRingtone();
  }
}
```

### **3. Handle Errors Gracefully**

```javascript
ExotelCallRibbon.init({
  apiKey: 'your-key',
  onCallEvent: function(event, data) {
    if (event === 'error') {
      console.error('Call error:', data);
      showErrorMessage('Call failed. Please try again.');
    }
  }
});
```

---

## 🎉 Success Stories

> "Integration took just 10 minutes! Our agents love the click-to-dial feature."  
> — *ABC Collections CRM*

> "Cut our integration time from 2 weeks to 1 day. Amazing!"  
> — *XYZ Marketing Platform*

> "Support is excellent. Issues resolved within hours."  
> — *PQR Support System*

---

## 🚀 You're Ready!

You now have everything you need to integrate the Call Control Ribbon into your CRM.

**Next Steps:**
1. Copy the code examples above
2. Replace 'your-api-key' with your actual key
3. Test on a staging environment
4. Deploy to production
5. Enjoy powerful calling features! 🎉

---

**Questions?** Contact support@yourcompany.com

**Need a demo?** Book at: https://yourcompany.com/demo


