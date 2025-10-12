# 📡 Exotel Call Ribbon - Complete API Documentation

## Base URL
```
http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com
```

---

## 🔐 Authentication

All API requests require authentication using your Client API Key.

### **Methods:**

**For POST requests:**
```javascript
{
  "apiKey": "your-api-key-123"
}
```

**For GET requests:**
```
Headers: X-API-Key: your-api-key-123
```

---

## 📋 **Core API Endpoints**

### 1. Initialize Ribbon
**Endpoint:** `POST /api/ribbon/init`

**Purpose:** Authenticate client and get Exotel credentials

**Request:**
```json
{
  "apiKey": "demo-api-key-789",
  "domain": "yourcrm.com"
}
```

**Response (200 OK):**
```json
{
  "exotelToken": "9875596a6e1be7bfaa865f43a028ec40f980e57fdeb4de8c",
  "userId": "f6e23a8c3ce28cda4a76bce715dd714e1d138183f58179df",
  "features": ["call", "mute", "hold", "dtmf"],
  "clientInfo": {
    "name": "Demo Client",
    "plan": "trial",
    "remainingCalls": 95
  }
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid API key
- `403 Forbidden` - Domain not allowed
- `429 Too Many Requests` - Monthly limit exceeded

---

### 2. Log Call Event
**Endpoint:** `POST /api/ribbon/log-call`

**Purpose:** Log call events for tracking and analytics

**Request:**
```json
{
  "apiKey": "demo-api-key-789",
  "event": "connected",
  "data": {
    "callSid": "CA1234567890",
    "phoneNumber": "+919876543210",
    "callDirection": "outbound",
    "duration": 180,
    "customerData": {
      "customerId": "CUST001",
      "name": "John Doe",
      "email": "john@example.com"
    }
  },
  "timestamp": "2025-10-12T10:30:00Z",
  "domain": "yourcrm.com"
}
```

**Response:**
```json
{
  "success": true,
  "logId": "log-1760280743-abc123def"
}
```

---

### 3. Get Configuration
**Endpoint:** `GET /api/ribbon/config`

**Headers:** `X-API-Key: your-api-key-123`

**Response:**
```json
{
  "features": ["call", "mute", "hold", "dtmf"],
  "plan": "trial",
  "usage": {
    "callsThisMonth": 25,
    "limit": 100,
    "remaining": 75
  }
}
```

---

### 4. Get Analytics
**Endpoint:** `GET /api/ribbon/analytics`

**Headers:** `X-API-Key: your-api-key-123`

**Query Parameters:**
- `startDate` (optional): Filter from date (ISO 8601)
- `endDate` (optional): Filter to date (ISO 8601)
- `customerId` (optional): Filter by customer
- `limit` (optional): Number of recent calls (default: 100)

**Example:**
```
GET /api/ribbon/analytics?startDate=2025-10-01&limit=50
```

**Response:**
```json
{
  "summary": {
    "totalCalls": 125,
    "totalDuration": 22500,
    "avgDuration": 180,
    "inboundCalls": 45,
    "outboundCalls": 80,
    "missedCalls": 5
  },
  "callsByDate": {
    "2025-10-12": 25,
    "2025-10-11": 30,
    "2025-10-10": 20
  },
  "recentCalls": [
    {
      "sessionId": "session-1760280743",
      "clientId": "client-demo",
      "startTime": "2025-10-12T10:30:00Z",
      "endTime": "2025-10-12T10:33:00Z",
      "duration": 180,
      "phoneNumber": "+919876543210",
      "callDirection": "outbound",
      "customerData": {
        "customerId": "CUST001",
        "name": "John Doe"
      },
      "status": "completed"
    }
  ],
  "usage": {
    "callsThisMonth": 25,
    "limit": 100,
    "remaining": 75
  }
}
```

---

### 5. Health Check
**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "healthy",
  "version": "2.0.0",
  "uptime": 86400
}
```

---

## 📞 **Call Management Endpoints**

### 6. Get Call Logs (with Filters)
**Endpoint:** `GET /api/ribbon/call-logs`

**Headers:** `X-API-Key: your-api-key-123`

**Query Parameters:**
- `startDate` (optional): ISO 8601 date
- `endDate` (optional): ISO 8601 date
- `customerId` (optional): Filter by customer ID
- `event` (optional): Filter by event type (connected, incoming, callEnded)
- `callDirection` (optional): inbound or outbound
- `page` (optional): Page number (default: 1)
- `pageSize` (optional): Results per page (default: 50)

**Example:**
```
GET /api/ribbon/call-logs?customerId=CUST001&page=1&pageSize=20
```

**Response:**
```json
{
  "logs": [
    {
      "logId": "log-1760280743-abc123",
      "clientId": "client-demo",
      "clientName": "Demo Client",
      "event": "connected",
      "data": {
        "callSid": "CA1234567890",
        "phoneNumber": "+919876543210",
        "callDirection": "outbound",
        "customerData": {
          "customerId": "CUST001",
          "name": "John Doe"
        }
      },
      "timestamp": "2025-10-12T10:30:00Z",
      "domain": "yourcrm.com"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 125,
    "totalPages": 7
  }
}
```

---

### 7. Get Active Calls
**Endpoint:** `GET /api/ribbon/active-calls`

**Headers:** `X-API-Key: your-api-key-123`

**Response:**
```json
{
  "activeCalls": [
    {
      "sessionId": "session-1760280743",
      "clientId": "client-demo",
      "startTime": "2025-10-12T10:30:00Z",
      "phoneNumber": "+919876543210",
      "callDirection": "outbound",
      "customerData": {
        "customerId": "CUST001",
        "name": "John Doe"
      },
      "status": "active"
    }
  ],
  "count": 1
}
```

---

### 8. Get Detailed Analytics
**Endpoint:** `GET /api/ribbon/analytics/detailed`

**Headers:** `X-API-Key: your-api-key-123`

**Query Parameters:**
- `startDate` (optional): ISO 8601 date
- `endDate` (optional): ISO 8601 date

**Response:**
```json
{
  "summary": {
    "totalCalls": 125,
    "totalDuration": 22500,
    "avgDuration": 180,
    "inboundCalls": 45,
    "outboundCalls": 80,
    "missedCalls": 5
  },
  "callsByHour": {
    "0": 2, "1": 1, "2": 0, "3": 0,
    "9": 15, "10": 20, "11": 25,
    "14": 18, "15": 22, "16": 12
  },
  "callsByDayOfWeek": {
    "0": 5, "1": 25, "2": 30, "3": 28, "4": 22, "5": 15, "6": 0
  },
  "topCustomers": [
    {
      "customerId": "CUST001",
      "customerName": "John Doe",
      "phoneNumber": "+919876543210",
      "callCount": 15,
      "totalDuration": 2700
    }
  ],
  "durationBuckets": {
    "0-30s": 10,
    "30s-1m": 25,
    "1m-3m": 50,
    "3m-5m": 30,
    "5m+": 10
  },
  "recentActivity": [
    {
      "sessionId": "session-1760280743",
      "startTime": "2025-10-12T10:30:00Z",
      "endTime": "2025-10-12T10:33:00Z",
      "duration": 180,
      "phoneNumber": "+919876543210",
      "customerData": { "name": "John Doe" }
    }
  ]
}
```

---

### 9. Export Call Logs
**Endpoint:** `GET /api/ribbon/export/calls`

**Headers:** `X-API-Key: your-api-key-123`

**Query Parameters:**
- `startDate` (optional): ISO 8601 date
- `endDate` (optional): ISO 8601 date
- `format` (optional): `json` or `csv` (default: json)

**Example (CSV):**
```
GET /api/ribbon/export/calls?format=csv&startDate=2025-10-01
```

**Response (CSV):**
```csv
Session ID,Customer Name,Phone Number,Direction,Start Time,End Time,Duration (s),Customer ID
session-1760280743,John Doe,+919876543210,outbound,2025-10-12T10:30:00Z,2025-10-12T10:33:00Z,180,CUST001
```

**Response (JSON):**
```json
{
  "client": {
    "clientId": "client-demo",
    "name": "Demo Client"
  },
  "exportDate": "2025-10-12T12:00:00Z",
  "dateRange": {
    "startDate": "2025-10-01",
    "endDate": "2025-10-12"
  },
  "calls": [
    {
      "sessionId": "session-1760280743",
      "startTime": "2025-10-12T10:30:00Z",
      "endTime": "2025-10-12T10:33:00Z",
      "duration": 180,
      "phoneNumber": "+919876543210",
      "callDirection": "outbound",
      "customerData": { "customerId": "CUST001", "name": "John Doe" }
    }
  ]
}
```

---

## 👥 **Customer Management Endpoints**

### 10. Save/Update Customer
**Endpoint:** `POST /api/ribbon/customer`

**Purpose:** Store customer information in the system

**Request:**
```json
{
  "apiKey": "your-api-key-123",
  "customerData": {
    "customerId": "CUST001",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+919876543210",
    "company": "Acme Corp",
    "tags": ["vip", "enterprise"],
    "customFields": {
      "accountBalance": 5000,
      "lastPayment": "2025-09-15"
    }
  }
}
```

**Response:**
```json
{
  "success": true,
  "customerId": "CUST001",
  "message": "Customer information saved"
}
```

---

### 11. Get Customer Information
**Endpoint:** `GET /api/ribbon/customer/:customerId`

**Headers:** `X-API-Key: your-api-key-123`

**Example:**
```
GET /api/ribbon/customer/CUST001
```

**Response:**
```json
{
  "customer": {
    "customerId": "CUST001",
    "clientId": "client-demo",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+919876543210",
    "company": "Acme Corp",
    "tags": ["vip", "enterprise"],
    "customFields": {
      "accountBalance": 5000,
      "lastPayment": "2025-09-15"
    },
    "createdAt": "2025-10-01T10:00:00Z",
    "lastUpdated": "2025-10-12T10:30:00Z"
  },
  "callHistory": [
    {
      "sessionId": "session-1760280743",
      "startTime": "2025-10-12T10:30:00Z",
      "duration": 180,
      "callDirection": "outbound"
    }
  ],
  "totalCalls": 15,
  "totalDuration": 2700
}
```

---

### 12. Get Customer Call History
**Endpoint:** `GET /api/ribbon/customer/:customerId/calls`

**Headers:** `X-API-Key: your-api-key-123`

**Query Parameters:**
- `limit` (optional): Number of calls to return (default: 50)

**Example:**
```
GET /api/ribbon/customer/CUST001/calls?limit=10
```

**Response:**
```json
{
  "customerId": "CUST001",
  "calls": [
    {
      "sessionId": "session-1760280743",
      "clientId": "client-demo",
      "startTime": "2025-10-12T10:30:00Z",
      "endTime": "2025-10-12T10:33:00Z",
      "duration": 180,
      "phoneNumber": "+919876543210",
      "callDirection": "outbound",
      "customerData": {
        "customerId": "CUST001",
        "name": "John Doe"
      },
      "status": "completed"
    }
  ],
  "events": [
    {
      "logId": "log-1760280743-abc",
      "event": "connected",
      "timestamp": "2025-10-12T10:30:00Z"
    },
    {
      "logId": "log-1760280800-def",
      "event": "callEnded",
      "timestamp": "2025-10-12T10:33:00Z"
    }
  ],
  "totalCalls": 15,
  "totalDuration": 2700
}
```

---

## 🔧 **Admin Endpoints**

### 13. List All Clients
**Endpoint:** `GET /api/admin/clients`

**Note:** Add admin authentication in production

**Response:**
```json
[
  {
    "clientId": "client-001",
    "name": "Collections CRM Inc.",
    "plan": "enterprise",
    "callsThisMonth": 125,
    "limit": 10000,
    "apiKey": "collection..."
  },
  {
    "clientId": "client-demo",
    "name": "Demo Client",
    "plan": "trial",
    "callsThisMonth": 25,
    "limit": 100,
    "apiKey": "demo-api-k..."
  }
]
```

---

### 14. All Clients Analytics
**Endpoint:** `GET /api/admin/analytics/all`

**Note:** Add admin authentication in production

**Response:**
```json
{
  "clients": [
    {
      "clientId": "client-001",
      "clientName": "Collections CRM Inc.",
      "plan": "enterprise",
      "totalCalls": 125,
      "totalDuration": 22500,
      "callsThisMonth": 125,
      "limit": 10000,
      "utilizationPercent": 1
    }
  ],
  "totalClients": 3,
  "totalCallsAllClients": 250
}
```

---

## 📊 **Usage Examples**

### **Example 1: Get Today's Call Logs**

```javascript
const today = new Date().toISOString().split('T')[0];

fetch(`http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/call-logs?startDate=${today}T00:00:00Z`, {
  headers: {
    'X-API-Key': 'your-api-key-123'
  }
})
.then(r => r.json())
.then(data => {
  console.log('Today\'s calls:', data.logs);
  console.log('Total:', data.pagination.total);
});
```

### **Example 2: Get Customer Call History**

```javascript
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/customer/CUST001/calls', {
  headers: {
    'X-API-Key': 'your-api-key-123'
  }
})
.then(r => r.json())
.then(data => {
  console.log('Customer calls:', data.calls);
  console.log('Total calls:', data.totalCalls);
  console.log('Total duration:', data.totalDuration, 'seconds');
});
```

### **Example 3: Save Customer Information**

```javascript
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/customer', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    apiKey: 'your-api-key-123',
    customerData: {
      customerId: 'CUST001',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+919876543210',
      customFields: {
        accountBalance: 5000,
        segment: 'enterprise'
      }
    }
  })
})
.then(r => r.json())
.then(data => {
  console.log('Customer saved:', data.customerId);
});
```

### **Example 4: Get Detailed Analytics Report**

```javascript
const startDate = '2025-10-01T00:00:00Z';
const endDate = '2025-10-31T23:59:59Z';

fetch(`http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics/detailed?startDate=${startDate}&endDate=${endDate}`, {
  headers: {
    'X-API-Key': 'your-api-key-123'
  }
})
.then(r => r.json())
.then(analytics => {
  console.log('Total calls:', analytics.summary.totalCalls);
  console.log('Average duration:', analytics.summary.avgDuration, 'seconds');
  console.log('Top 10 customers:', analytics.topCustomers);
  console.log('Calls by hour:', analytics.callsByHour);
  console.log('Busiest day:', analytics.callsByDayOfWeek);
});
```

### **Example 5: Export Call Logs to CSV**

```javascript
const startDate = '2025-10-01';
const endDate = '2025-10-31';

// Download CSV file
window.location.href = `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/export/calls?format=csv&startDate=${startDate}&endDate=${endDate}&X-API-Key=your-api-key-123`;

// Or fetch and process
fetch(`http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/export/calls?format=csv&startDate=${startDate}`, {
  headers: {
    'X-API-Key': 'your-api-key-123'
  }
})
.then(r => r.text())
.then(csv => {
  console.log('CSV data:', csv);
  // Process or download CSV
});
```

### **Example 6: Monitor Active Calls**

```javascript
// Poll every 5 seconds for active calls
setInterval(() => {
  fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/active-calls', {
    headers: {
      'X-API-Key': 'your-api-key-123'
    }
  })
  .then(r => r.json())
  .then(data => {
    console.log('Active calls:', data.count);
    updateDashboard(data.activeCalls);
  });
}, 5000);
```

---

## 📊 **Building Analytics Dashboard**

### **Complete Dashboard Example:**

```javascript
class CallAnalyticsDashboard {
  constructor(apiKey, apiUrl) {
    this.apiKey = apiKey;
    this.apiUrl = apiUrl;
  }

  async getOverview() {
    const response = await fetch(`${this.apiUrl}/api/ribbon/analytics`, {
      headers: { 'X-API-Key': this.apiKey }
    });
    return response.json();
  }

  async getDetailedReport(startDate, endDate) {
    const params = new URLSearchParams({ startDate, endDate });
    const response = await fetch(`${this.apiUrl}/api/ribbon/analytics/detailed?${params}`, {
      headers: { 'X-API-Key': this.apiKey }
    });
    return response.json();
  }

  async getActiveCalls() {
    const response = await fetch(`${this.apiUrl}/api/ribbon/active-calls`, {
      headers: { 'X-API-Key': this.apiKey }
    });
    return response.json();
  }

  async getCustomerHistory(customerId) {
    const response = await fetch(`${this.apiUrl}/api/ribbon/customer/${customerId}/calls`, {
      headers: { 'X-API-Key': this.apiKey }
    });
    return response.json();
  }

  async exportToCSV(startDate, endDate) {
    const params = new URLSearchParams({ format: 'csv', startDate, endDate });
    const response = await fetch(`${this.apiUrl}/api/ribbon/export/calls?${params}`, {
      headers: { 'X-API-Key': this.apiKey }
    });
    const csv = await response.text();
    
    // Download CSV
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `call-logs-${startDate}-${endDate}.csv`;
    a.click();
  }

  async renderDashboard() {
    // Get all data
    const [overview, detailed, active] = await Promise.all([
      this.getOverview(),
      this.getDetailedReport(),
      this.getActiveCalls()
    ]);

    // Render to your dashboard
    console.log('Overview:', overview);
    console.log('Detailed:', detailed);
    console.log('Active calls:', active);
    
    // Update UI elements
    document.getElementById('total-calls').textContent = overview.summary.totalCalls;
    document.getElementById('total-duration').textContent = this.formatDuration(overview.summary.totalDuration);
    document.getElementById('active-calls').textContent = active.count;
    
    // Render charts
    this.renderCallsByHourChart(detailed.callsByHour);
    this.renderTopCustomersChart(detailed.topCustomers);
    this.renderDurationDistribution(detailed.durationBuckets);
  }

  formatDuration(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return `${hours}h ${minutes}m`;
  }

  renderCallsByHourChart(data) {
    // Integrate with Chart.js, D3.js, or your preferred charting library
    console.log('Calls by hour:', data);
  }

  renderTopCustomersChart(customers) {
    console.log('Top customers:', customers);
  }

  renderDurationDistribution(buckets) {
    console.log('Duration distribution:', buckets);
  }
}

// Usage
const dashboard = new CallAnalyticsDashboard(
  'your-api-key-123',
  'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com'
);

dashboard.renderDashboard();
```

---

## 🔄 **Real-Time Updates**

### **WebSocket Alternative (Polling):**

```javascript
// Poll for updates every 30 seconds
function startRealTimeMonitoring() {
  setInterval(async () => {
    // Get active calls
    const active = await fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/active-calls', {
      headers: { 'X-API-Key': 'your-api-key-123' }
    }).then(r => r.json());

    // Update dashboard
    updateActiveCalls(active.activeCalls);
    
    // Get recent activity
    const analytics = await fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics', {
      headers: { 'X-API-Key': 'your-api-key-123' }
    }).then(r => r.json());

    updateRecentActivity(analytics.recentCalls);
  }, 30000);
}
```

---

## 📈 **Analytics Queries**

### **Get This Month's Stats:**

```javascript
const startOfMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString();
const endOfMonth = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0, 23, 59, 59).toISOString();

fetch(`http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics?startDate=${startOfMonth}&endDate=${endOfMonth}`, {
  headers: { 'X-API-Key': 'your-api-key-123' }
})
.then(r => r.json())
.then(stats => {
  console.log('This month:', stats);
});
```

### **Get Specific Customer Analytics:**

```javascript
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics?customerId=CUST001', {
  headers: { 'X-API-Key': 'your-api-key-123' }
})
.then(r => r.json())
.then(stats => {
  console.log('Customer stats:', stats);
});
```

### **Get Outbound Calls Only:**

```javascript
fetch('http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/call-logs?callDirection=outbound&pageSize=100', {
  headers: { 'X-API-Key': 'your-api-key-123' }
})
.then(r => r.json())
.then(data => {
  console.log('Outbound calls:', data.logs);
});
```

---

## 📝 **Complete API Endpoint Summary**

### **Core APIs (Required):**
1. `POST /api/ribbon/init` - Initialize
2. `POST /api/ribbon/log-call` - Log events
3. `GET /api/ribbon/config` - Get config
4. `GET /api/ribbon/analytics` - Basic analytics
5. `GET /health` - Health check

### **Call Management (Enhanced):**
6. `GET /api/ribbon/call-logs` - Filtered call logs
7. `GET /api/ribbon/active-calls` - Active calls
8. `GET /api/ribbon/analytics/detailed` - Detailed analytics
9. `GET /api/ribbon/export/calls` - Export (CSV/JSON)

### **Customer Management (New):**
10. `POST /api/ribbon/customer` - Save customer
11. `GET /api/ribbon/customer/:id` - Get customer
12. `GET /api/ribbon/customer/:id/calls` - Customer calls

### **Admin (Optional):**
13. `GET /api/admin/clients` - List clients
14. `GET /api/admin/analytics/all` - All client stats

---

## 🎯 **Quick Reference**

```
Base URL: http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com

Authentication:
  POST: Include "apiKey" in body
  GET:  Include "X-API-Key" in headers

Demo API Key: demo-api-key-789
```

---

## 🔒 **Security Notes**

1. **API Keys:** Client API keys only, Exotel credentials managed server-side
2. **HTTPS:** Use HTTPS in production (currently HTTP for demo)
3. **CORS:** Currently allows all origins (*), restrict in production
4. **Rate Limiting:** Add in production
5. **Admin Auth:** Add authentication for admin endpoints

---

## 💾 **Data Storage**

**Current:** In-memory storage (resets on server restart)

**Production:** Replace with:
- PostgreSQL for relational data
- MongoDB for flexible schemas
- Redis for caching
- S3 for call recordings (if enabled)

---

## 📞 **Support**

**Test all endpoints:**
```bash
curl http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/health
```

**Issues?** Check server logs or contact support.

---

*API Version: 2.0.0*  
*Region: Mumbai (ap-south-1)*  
*Last Updated: October 12, 2025*

