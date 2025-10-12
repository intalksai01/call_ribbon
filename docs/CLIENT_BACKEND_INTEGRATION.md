# 🔧 Backend Integration Guide - Call Logs, Customers & Analytics

## Overview

This guide shows how to integrate our backend APIs into your CRM for:
- 📞 Call log management
- 👥 Customer information storage
- 📊 Analytics and reporting
- 📈 Real-time dashboards

---

## 🚀 **Quick Start**

### **Base URL:**
```
http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
```

### **Authentication:**
```
X-API-Key: your-api-key-123
```

---

## 📞 **Call Log Management**

### **1. Automatic Call Logging**

Calls are automatically logged when you use the widget. Every call event is sent to our backend.

**No action required from your side!** ✅

### **2. Retrieve Call Logs**

```javascript
// Get all calls with pagination
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/call-logs?page=1&pageSize=50', {
  headers: {
    'X-API-Key': 'your-api-key-123'
  }
})
.then(r => r.json())
.then(data => {
  console.log('Call logs:', data.logs);
  console.log('Total:', data.pagination.total);
});
```

### **3. Filter Call Logs**

```javascript
// Get calls for specific date range
const startDate = '2025-10-01T00:00:00Z';
const endDate = '2025-10-31T23:59:59Z';

fetch(`http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/call-logs?startDate=${startDate}&endDate=${endDate}`, {
  headers: { 'X-API-Key': 'your-api-key-123' }
})
.then(r => r.json())
.then(data => console.log('Filtered logs:', data));
```

### **4. Filter by Customer**

```javascript
// Get all calls for specific customer
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/call-logs?customerId=CUST001', {
  headers: { 'X-API-Key': 'your-api-key-123' }
})
.then(r => r.json())
.then(data => console.log('Customer calls:', data));
```

### **5. Filter by Call Direction**

```javascript
// Get outbound calls only
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/call-logs?callDirection=outbound', {
  headers: { 'X-API-Key': 'your-api-key-123' }
})
.then(r => r.json())
.then(data => console.log('Outbound calls:', data));
```

---

## 👥 **Customer Information Management**

### **1. Save Customer Information**

Automatically save customer info when they're selected:

```javascript
// When customer is selected in your CRM
function onCustomerSelected(customer) {
  // Set in widget
  ExotelCallRibbon.setCustomer({
    phoneNumber: customer.phone,
    name: customer.name,
    customerId: customer.id
  });

  // Save to our backend for tracking
  fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/customer', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      apiKey: 'your-api-key-123',
      customerData: {
        customerId: customer.id,
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        company: customer.company,
        customFields: {
          accountBalance: customer.balance,
          segment: customer.segment,
          priority: customer.priority
        }
      }
    })
  })
  .then(r => r.json())
  .then(result => console.log('Customer saved:', result));
}
```

### **2. Retrieve Customer Information**

```javascript
// Get customer info with call history
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/customer/CUST001', {
  headers: { 'X-API-Key': 'your-api-key-123' }
})
.then(r => r.json())
.then(data => {
  console.log('Customer:', data.customer);
  console.log('Call history:', data.callHistory);
  console.log('Total calls:', data.totalCalls);
  console.log('Total talk time:', data.totalDuration, 'seconds');
});
```

### **3. Get Customer Call History**

```javascript
// Get last 10 calls for customer
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/customer/CUST001/calls?limit=10', {
  headers: { 'X-API-Key': 'your-api-key-123' }
})
.then(r => r.json())
.then(data => {
  console.log('Recent calls:', data.calls);
  console.log('All events:', data.events);
});
```

---

## 📊 **Analytics & Reporting**

### **1. Basic Analytics**

```javascript
// Get overall statistics
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics', {
  headers: { 'X-API-Key': 'your-api-key-123' }
})
.then(r => r.json())
.then(stats => {
  console.log('Total calls:', stats.summary.totalCalls);
  console.log('Total duration:', stats.summary.totalDuration);
  console.log('Average duration:', stats.summary.avgDuration);
  console.log('Inbound:', stats.summary.inboundCalls);
  console.log('Outbound:', stats.summary.outboundCalls);
  console.log('Recent activity:', stats.recentCalls);
});
```

### **2. Detailed Analytics Report**

```javascript
// Get comprehensive analytics
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics/detailed', {
  headers: { 'X-API-Key': 'your-api-key-123' }
})
.then(r => r.json())
.then(analytics => {
  // Summary stats
  console.log('Summary:', analytics.summary);
  
  // Hourly distribution
  console.log('Busiest hour:', analytics.callsByHour);
  
  // Weekly pattern
  console.log('Calls by day:', analytics.callsByDayOfWeek);
  
  // Top customers
  console.log('Top 10 customers:', analytics.topCustomers);
  
  // Call duration distribution
  console.log('Duration buckets:', analytics.durationBuckets);
  
  // Recent activity
  console.log('Recent calls:', analytics.recentActivity);
});
```

### **3. Export to CSV**

```javascript
// Export calls as CSV file
function exportCallsToCSV() {
  const startDate = '2025-10-01';
  const endDate = '2025-10-31';
  
  const url = `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/export/calls?format=csv&startDate=${startDate}&endDate=${endDate}`;
  
  fetch(url, {
    headers: { 'X-API-Key': 'your-api-key-123' }
  })
  .then(r => r.text())
  .then(csv => {
    // Create download
    const blob = new Blob([csv], { type: 'text/csv' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `call-logs-${startDate}-to-${endDate}.csv`;
    link.click();
  });
}
```

### **4. Real-Time Dashboard**

```javascript
// Build real-time analytics dashboard
class RealTimeDashboard {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.baseUrl = 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com';
  }

  async init() {
    // Initial load
    await this.refreshData();
    
    // Auto-refresh every 30 seconds
    setInterval(() => this.refreshData(), 30000);
  }

  async refreshData() {
    try {
      // Get all data in parallel
      const [analytics, activeCalls, config] = await Promise.all([
        this.getDetailedAnalytics(),
        this.getActiveCalls(),
        this.getConfig()
      ]);

      // Update dashboard UI
      this.updateUI({
        analytics,
        activeCalls,
        config
      });
    } catch (error) {
      console.error('Dashboard refresh error:', error);
    }
  }

  async getDetailedAnalytics() {
    const response = await fetch(`${this.baseUrl}/api/ribbon/analytics/detailed`, {
      headers: { 'X-API-Key': this.apiKey }
    });
    return response.json();
  }

  async getActiveCalls() {
    const response = await fetch(`${this.baseUrl}/api/ribbon/active-calls`, {
      headers: { 'X-API-Key': this.apiKey }
    });
    return response.json();
  }

  async getConfig() {
    const response = await fetch(`${this.baseUrl}/api/ribbon/config`, {
      headers: { 'X-API-Key': this.apiKey }
    });
    return response.json();
  }

  updateUI(data) {
    // Update total calls
    document.getElementById('total-calls').textContent = data.analytics.summary.totalCalls;
    
    // Update total duration
    const hours = Math.floor(data.analytics.summary.totalDuration / 3600);
    document.getElementById('total-duration').textContent = `${hours}h`;
    
    // Update active calls
    document.getElementById('active-calls').textContent = data.activeCalls.count;
    
    // Update usage
    const usagePercent = Math.round((data.config.usage.callsThisMonth / data.config.usage.limit) * 100);
    document.getElementById('usage').textContent = `${usagePercent}%`;
    
    // Update charts
    this.renderCharts(data.analytics);
  }

  renderCharts(analytics) {
    // Render with your preferred charting library
    // Chart.js, D3.js, Recharts, etc.
    console.log('Rendering charts with:', analytics);
  }
}

// Initialize dashboard
const dashboard = new RealTimeDashboard('your-api-key-123');
dashboard.init();
```

---

## 📈 **Building Analytics Reports**

### **Daily Call Summary Report:**

```javascript
async function getDailySummary(date) {
  const startDate = `${date}T00:00:00Z`;
  const endDate = `${date}T23:59:59Z`;
  
  const response = await fetch(
    `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics/detailed?startDate=${startDate}&endDate=${endDate}`,
    {
      headers: { 'X-API-Key': 'your-api-key-123' }
    }
  );
  
  const data = await response.json();
  
  return {
    date,
    totalCalls: data.summary.totalCalls,
    totalDuration: data.summary.totalDuration,
    avgDuration: data.summary.avgDuration,
    peakHour: Object.entries(data.callsByHour)
      .sort((a, b) => b[1] - a[1])[0],
    topCustomer: data.topCustomers[0]
  };
}

// Usage
getDailySummary('2025-10-12').then(summary => {
  console.log('Daily summary:', summary);
});
```

### **Monthly Performance Report:**

```javascript
async function getMonthlyReport(year, month) {
  const startDate = new Date(year, month - 1, 1).toISOString();
  const endDate = new Date(year, month, 0, 23, 59, 59).toISOString();
  
  const response = await fetch(
    `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics/detailed?startDate=${startDate}&endDate=${endDate}`,
    {
      headers: { 'X-API-Key': 'your-api-key-123' }
    }
  );
  
  const data = await response.json();
  
  return {
    month: `${year}-${month}`,
    summary: data.summary,
    busiestDay: Object.entries(data.callsByDayOfWeek)
      .sort((a, b) => b[1] - a[1])[0],
    topCustomers: data.topCustomers.slice(0, 5),
    avgCallDuration: data.summary.avgDuration,
    callDistribution: data.durationBuckets
  };
}

// Usage
getMonthlyReport(2025, 10).then(report => {
  console.log('Monthly report:', report);
});
```

### **Customer Performance Report:**

```javascript
async function getCustomerReport(customerId) {
  const response = await fetch(
    `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/customer/${customerId}/calls`,
    {
      headers: { 'X-API-Key': 'your-api-key-123' }
    }
  );
  
  const data = await response.json();
  
  // Calculate metrics
  const avgDuration = data.totalDuration / data.totalCalls;
  const lastCall = data.calls[0];
  const daysSinceLastCall = lastCall 
    ? Math.floor((Date.now() - new Date(lastCall.startTime)) / (1000 * 60 * 60 * 24))
    : null;
  
  return {
    customerId,
    totalCalls: data.totalCalls,
    totalDuration: data.totalDuration,
    avgDuration: Math.round(avgDuration),
    lastCall,
    daysSinceLastCall,
    recentCalls: data.calls.slice(0, 5)
  };
}

// Usage
getCustomerReport('CUST001').then(report => {
  console.log('Customer report:', report);
});
```

---

## 🎨 **Dashboard Examples**

### **Example 1: Collections CRM Dashboard**

```html
<!DOCTYPE html>
<html>
<head>
  <title>Collections Dashboard</title>
  <style>
    .dashboard {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;
      padding: 20px;
    }
    .stat-card {
      background: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .stat-value {
      font-size: 32px;
      font-weight: bold;
      color: #667eea;
    }
    .stat-label {
      color: #666;
      margin-top: 8px;
    }
  </style>
</head>
<body>
  <div class="dashboard">
    <div class="stat-card">
      <div class="stat-value" id="total-calls">0</div>
      <div class="stat-label">Total Calls</div>
    </div>
    <div class="stat-card">
      <div class="stat-value" id="total-duration">0h</div>
      <div class="stat-label">Total Talk Time</div>
    </div>
    <div class="stat-card">
      <div class="stat-value" id="active-calls">0</div>
      <div class="stat-label">Active Calls</div>
    </div>
    <div class="stat-card">
      <div class="stat-value" id="usage">0%</div>
      <div class="stat-label">Usage This Month</div>
    </div>
  </div>

  <script>
    const API_KEY = 'collections-crm-api-key-123';
    const API_URL = 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com';

    async function updateDashboard() {
      // Get analytics
      const analytics = await fetch(`${API_URL}/api/ribbon/analytics/detailed`, {
        headers: { 'X-API-Key': API_KEY }
      }).then(r => r.json());

      // Get active calls
      const active = await fetch(`${API_URL}/api/ribbon/active-calls`, {
        headers: { 'X-API-Key': API_KEY }
      }).then(r => r.json());

      // Get config
      const config = await fetch(`${API_URL}/api/ribbon/config`, {
        headers: { 'X-API-Key': API_KEY }
      }).then(r => r.json());

      // Update UI
      document.getElementById('total-calls').textContent = analytics.summary.totalCalls;
      
      const hours = Math.floor(analytics.summary.totalDuration / 3600);
      document.getElementById('total-duration').textContent = `${hours}h`;
      
      document.getElementById('active-calls').textContent = active.count;
      
      const usagePercent = Math.round((config.usage.callsThisMonth / config.usage.limit) * 100);
      document.getElementById('usage').textContent = `${usagePercent}%`;
    }

    // Update every 30 seconds
    updateDashboard();
    setInterval(updateDashboard, 30000);
  </script>
</body>
</html>
```

---

## 📊 **Analytics Visualization**

### **Chart.js Integration Example:**

```html
<canvas id="callsChart"></canvas>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
async function renderCallsChart() {
  const API_KEY = 'your-api-key-123';
  const API_URL = 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com';

  // Get detailed analytics
  const analytics = await fetch(`${API_URL}/api/ribbon/analytics/detailed`, {
    headers: { 'X-API-Key': API_KEY }
  }).then(r => r.json());

  // Render hourly chart
  const ctx = document.getElementById('callsChart').getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: Object.keys(analytics.callsByHour),
      datasets: [{
        label: 'Calls by Hour',
        data: Object.values(analytics.callsByHour),
        backgroundColor: '#667eea'
      }]
    },
    options: {
      responsive: true,
      plugins: {
        title: {
          display: true,
          text: 'Calls Distribution by Hour'
        }
      }
    }
  });
}

renderCallsChart();
</script>
```

---

## 🔄 **Automated Reporting**

### **Daily Email Report (Pseudo-code):**

```javascript
// Run this as a daily cron job
async function sendDailyReport() {
  const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
  const startDate = `${yesterday}T00:00:00Z`;
  const endDate = `${yesterday}T23:59:59Z`;

  // Get yesterday's data
  const analytics = await fetch(
    `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics/detailed?startDate=${startDate}&endDate=${endDate}`,
    {
      headers: { 'X-API-Key': 'your-api-key-123' }
    }
  ).then(r => r.json());

  // Prepare email
  const emailBody = `
    Daily Call Report - ${yesterday}
    
    Total Calls: ${analytics.summary.totalCalls}
    Total Duration: ${Math.floor(analytics.summary.totalDuration / 60)} minutes
    Average Duration: ${analytics.summary.avgDuration} seconds
    
    Inbound: ${analytics.summary.inboundCalls}
    Outbound: ${analytics.summary.outboundCalls}
    
    Top Customers:
    ${analytics.topCustomers.slice(0, 5).map((c, i) => 
      `${i+1}. ${c.customerName} - ${c.callCount} calls`
    ).join('\n')}
  `;

  // Send email (use your email service)
  sendEmail({
    to: 'manager@yourcompany.com',
    subject: `Daily Call Report - ${yesterday}`,
    body: emailBody
  });
}
```

---

## 📱 **Mobile Dashboard Example**

```javascript
// Responsive dashboard for mobile agents
class MobileDashboard {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.apiUrl = 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com';
  }

  async getMyStats() {
    // Get today's stats
    const today = new Date().toISOString().split('T')[0];
    const startDate = `${today}T00:00:00Z`;
    
    const analytics = await fetch(
      `${this.apiUrl}/api/ribbon/analytics/detailed?startDate=${startDate}`,
      {
        headers: { 'X-API-Key': this.apiKey }
      }
    ).then(r => r.json());

    return {
      todayCalls: analytics.summary.totalCalls,
      todayDuration: analytics.summary.totalDuration,
      activeCalls: await this.getActiveCalls(),
      recentCalls: analytics.recentActivity.slice(0, 5)
    };
  }

  async getActiveCalls() {
    const response = await fetch(`${this.apiUrl}/api/ribbon/active-calls`, {
      headers: { 'X-API-Key': this.apiKey }
    });
    const data = await response.json();
    return data.count;
  }

  render() {
    this.getMyStats().then(stats => {
      document.getElementById('today-calls').textContent = stats.todayCalls;
      document.getElementById('today-duration').textContent = 
        `${Math.floor(stats.todayDuration / 60)}m`;
      document.getElementById('active').textContent = stats.activeCalls;
    });
  }
}
```

---

## 🎯 **Complete Integration Example**

```javascript
// Complete CRM integration with all features
class CRMCallIntegration {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.apiUrl = 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com';
    this.init();
  }

  init() {
    // Initialize widget
    ExotelCallRibbon.init({
      apiKey: this.apiKey,
      apiUrl: this.apiUrl,
      position: 'bottom',
      onCallEvent: this.handleCallEvent.bind(this)
    });
  }

  // Handle customer selection
  async selectCustomer(customer) {
    // Load into widget
    ExotelCallRibbon.setCustomer({
      phoneNumber: customer.phone,
      name: customer.name,
      customerId: customer.id
    });

    // Save customer info
    await this.saveCustomer(customer);

    // Load customer call history
    const history = await this.getCustomerHistory(customer.id);
    this.displayCustomerHistory(history);
  }

  // Save customer to backend
  async saveCustomer(customer) {
    const response = await fetch(`${this.apiUrl}/api/ribbon/customer`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        apiKey: this.apiKey,
        customerData: {
          customerId: customer.id,
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          customFields: customer.metadata
        }
      })
    });
    
    return response.json();
  }

  // Get customer call history
  async getCustomerHistory(customerId) {
    const response = await fetch(
      `${this.apiUrl}/api/ribbon/customer/${customerId}/calls`,
      {
        headers: { 'X-API-Key': this.apiKey }
      }
    );
    
    return response.json();
  }

  // Handle call events
  handleCallEvent(event, data) {
    console.log('Call event:', event, data);

    switch(event) {
      case 'connected':
        this.onCallConnected(data);
        break;
      case 'callEnded':
        this.onCallEnded(data);
        break;
      case 'incoming':
        this.onIncomingCall(data);
        break;
    }
  }

  onCallConnected(data) {
    // Update CRM UI
    this.showCallInterface(data.customerData);
    
    // Load customer details
    this.loadCustomerDetails(data.customerData.customerId);
    
    // Start call timer
    this.startCallTimer();
  }

  async onCallEnded(data) {
    // Save call notes
    const notes = this.getCallNotes();
    
    // Save to your CRM database
    await this.saveToCRM({
      customerId: data.customerData.customerId,
      duration: data.duration,
      timestamp: data.timestamp,
      notes: notes
    });

    // Refresh customer history
    const history = await this.getCustomerHistory(data.customerData.customerId);
    this.displayCustomerHistory(history);
    
    // Show call summary
    this.showCallSummary(data);
  }

  onIncomingCall(data) {
    // Show notification
    this.showNotification(`Incoming call from ${data.phoneNumber}`);
    
    // Try to match with existing customer
    this.findCustomerByPhone(data.phoneNumber);
  }

  // Helper methods
  showCallInterface(customer) {
    console.log('Showing call interface for:', customer);
  }

  loadCustomerDetails(customerId) {
    console.log('Loading customer:', customerId);
  }

  startCallTimer() {
    console.log('Timer started');
  }

  getCallNotes() {
    return document.getElementById('call-notes')?.value || '';
  }

  async saveToCRM(callData) {
    console.log('Saving to CRM:', callData);
    // Save to your database
  }

  displayCustomerHistory(history) {
    console.log('Displaying history:', history);
  }

  showCallSummary(data) {
    console.log('Call summary:', data);
  }

  showNotification(message) {
    alert(message);
  }

  findCustomerByPhone(phone) {
    console.log('Finding customer:', phone);
  }
}

// Initialize
const crmIntegration = new CRMCallIntegration('your-api-key-123');
```

---

## 📊 **All Available Endpoints**

```
Core APIs:
✅ POST /api/ribbon/init
✅ POST /api/ribbon/log-call
✅ GET  /api/ribbon/config
✅ GET  /api/ribbon/analytics
✅ GET  /health

Call Management:
✅ GET  /api/ribbon/call-logs (with filters & pagination)
✅ GET  /api/ribbon/active-calls
✅ GET  /api/ribbon/analytics/detailed
✅ GET  /api/ribbon/export/calls (CSV & JSON)

Customer Management:
✅ POST /api/ribbon/customer
✅ GET  /api/ribbon/customer/:id
✅ GET  /api/ribbon/customer/:id/calls

Admin (Add auth in production):
✅ GET  /api/admin/clients
✅ GET  /api/admin/analytics/all
```

---

## 🎯 **Summary**

**What You Get:**

1. **Automatic Call Logging** - Every call logged automatically
2. **Customer Management** - Store and retrieve customer info
3. **Analytics** - Comprehensive call analytics
4. **Exports** - CSV/JSON exports for reporting
5. **Real-Time Data** - Active calls monitoring
6. **Detailed Reports** - Hourly, daily, weekly patterns
7. **Customer Insights** - Per-customer call history

**What You Need:**

1. **Your API Key** - Contact us to get yours
2. **API Base URL** - http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
3. **Basic JavaScript** - To call our endpoints

**Integration Time:** 1-2 hours for complete setup

---

*API Version: 2.0.0*  
*Region: Mumbai (ap-south-1)*  
*All endpoints tested and working* ✅

