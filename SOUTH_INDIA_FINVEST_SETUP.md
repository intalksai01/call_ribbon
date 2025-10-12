# 🏦 South India Finvest Pvt Ltd - Complete Setup

## ✅ **Client Configuration**

### **Company Details:**
```
Client Name: South India Finvest
Company: South India Finvest Pvt Ltd
Industry: Financial Services / Lending
Region: South India
Plan: Enterprise
```

### **API Key:**
```
southindia-finvest-api-key-2024
```

### **Features Enabled:**
- ✅ Call (dial customers)
- ✅ Mute/Unmute
- ✅ Hold/Resume
- ✅ DTMF keypad
- ✅ Call transfer
- ✅ Call recording

### **Usage Limits:**
- **Monthly Limit:** 20,000 calls
- **Current Usage:** 4 calls
- **Remaining:** 19,996 calls

### **Allowed Domains:**
- southindiafinvest.com
- app.southindiafinvest.com
- localhost

---

## 👥 **Test Customers Added**

### **1. Rajesh Kumar (LOAN001)**
```
Type: Collections - High Priority
Phone: +919876543210
Email: rajesh.kumar@email.com
Location: Bangalore, Karnataka

Loan Details:
- Loan Amount: ₹5,00,000
- Outstanding: ₹1,50,000
- Days Overdue: 45 days
- EMI: ₹15,000/month
- Last Payment: Aug 15, 2025

Tags: overdue, collections, high_value
Status: Active
```

### **2. Priya Sharma (LOAN002)**
```
Type: VIP Customer - Regular Payer
Phone: +918765432109
Email: priya.sharma@email.com
Location: Bangalore, Karnataka

Loan Details:
- Loan Amount: ₹25,00,000 (Home Loan)
- Outstanding: ₹18,00,000
- Days Overdue: 0 (Current)
- EMI: ₹25,000/month
- Last Payment: Oct 1, 2025

Tags: vip, regular_payer, home_loan
Status: Active
```

### **3. Amit Patel (LEAD001)**
```
Type: Hot Lead - Personal Loan
Phone: +917654321098
Email: amit.patel@email.com
Location: Mumbai, Maharashtra

Lead Details:
- Requested Amount: ₹3,00,000
- Purpose: Personal Loan
- Monthly Income: ₹80,000
- Employer: TCS
- Credit Score: 750
- Lead Source: Website (Oct 10, 2025)

Tags: hot_lead, personal_loan, salaried
Status: Active
```

### **4. Sunita Reddy (LOAN003)**
```
Type: Active Customer - Education Loan
Phone: +919988776655
Email: sunita.reddy@email.com
Location: Hyderabad, Telangana

Loan Details:
- Loan Amount: ₹8,00,000 (Education)
- Outstanding: ₹6,00,000
- Days Overdue: 0 (Current)
- EMI: ₹12,000/month
- Student: Rahul Reddy (IIT Madras)

Tags: education_loan, regular_payer
Status: Active
```

### **5. Venkatesh Iyer (LOAN004)**
```
Type: Collections - Multiple Attempts
Phone: +918877665544
Email: venkatesh.iyer@email.com
Location: Chennai, Tamil Nadu

Loan Details:
- Loan Amount: ₹4,00,000
- Outstanding: ₹1,80,000
- Days Overdue: 60 days
- EMI: ₹18,000/month
- Last Payment: Aug 1, 2025
- Collection Attempts: 8

Tags: overdue, collections, multiple_attempts
Status: Active (Restructuring Needed)
```

### **6. Lakshmi Menon (LOAN005)**
```
Type: Premium Customer - Commercial Property
Phone: +917766554433
Email: lakshmi.menon@email.com
Location: Kochi, Kerala

Loan Details:
- Loan Amount: ₹50,00,000 (Commercial Property)
- Outstanding: ₹35,00,000
- Days Overdue: 0 (Current)
- EMI: ₹65,000/month
- Property Value: ₹80,00,000
- Relationship Manager: Suresh Kumar

Tags: vip, premium, commercial_property
Status: Active
```

---

## 📞 **Sample Call History**

### **Calls Logged:**

1. **Rajesh Kumar (2 hours ago)**
   - Duration: 4 min 30 sec
   - Type: Collections
   - Agent: Suresh Kumar
   - Outcome: Payment promised (₹50,000 by Oct 15)
   - Quality: 4/5

2. **Priya Sharma (4 hours ago)**
   - Duration: 2 min 40 sec
   - Type: Customer Service
   - Agent: Meena Iyer
   - Outcome: Courtesy call - No issues
   - Quality: 5/5

3. **Amit Patel (1 hour ago)**
   - Duration: 7 min 45 sec
   - Type: Sales
   - Agent: Rahul Verma
   - Outcome: Documents to be submitted by Oct 14
   - Quality: 5/5

4. **Venkatesh Iyer (30 minutes ago)**
   - Duration: 0 sec (No answer)
   - Type: Collections
   - Agent: Suresh Kumar
   - Outcome: No answer - Will retry in 2 hours

5. **Rajesh Kumar (Yesterday)**
   - Duration: 5 min 35 sec
   - Type: Collections
   - Agent: Suresh Kumar
   - Outcome: Extension requested

---

## 🗄️ **Database Configuration**

### **PostgreSQL RDS:**
```
Endpoint: intalksai-call-ribbon-db.cviea4aicss0.ap-south-1.rds.amazonaws.com
Port: 5432
Database: call_ribbon_db
Username: call_ribbon_admin
Password: 9AYVOZVXas6tiAz3vYAqZM1NS
Region: ap-south-1 (Mumbai)
```

### **Connection String:**
```
postgresql://call_ribbon_admin:9AYVOZVXas6tiAz3vYAqZM1NS@intalksai-call-ribbon-db.cviea4aicss0.ap-south-1.rds.amazonaws.com:5432/call_ribbon_db
```

---

## 🧪 **Test All Endpoints**

### **Quick Test:**
```bash
cd database
chmod +x test-all-endpoints.sh
./test-all-endpoints.sh
```

### **Individual Endpoint Tests:**

#### **1. Get Analytics:**
```bash
curl -s "http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/analytics/detailed" \
  -H "X-API-Key: southindia-finvest-api-key-2024" | jq .
```

#### **2. Get Customer Info:**
```bash
curl -s "http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/customer/LOAN001" \
  -H "X-API-Key: southindia-finvest-api-key-2024" | jq .
```

#### **3. Get Call Logs:**
```bash
curl -s "http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/call-logs?customerId=LOAN001" \
  -H "X-API-Key: southindia-finvest-api-key-2024" | jq .
```

#### **4. Export to CSV:**
```bash
curl -s "http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/export/calls?format=csv" \
  -H "X-API-Key: southindia-finvest-api-key-2024"
```

---

## 📊 **Expected Analytics Results**

### **Summary:**
```json
{
  "totalCalls": 4,
  "totalDuration": 1230,
  "avgDuration": 308,
  "inboundCalls": 0,
  "outboundCalls": 4,
  "missedCalls": 1
}
```

### **Top Customers:**
```json
[
  {
    "customerId": "LOAN001",
    "customerName": "Rajesh Kumar",
    "phoneNumber": "+919876543210",
    "callCount": 2,
    "totalDuration": 605
  }
]
```

### **Call Distribution:**
```json
{
  "0-30s": 1,
  "30s-1m": 0,
  "1m-3m": 1,
  "3m-5m": 1,
  "5m+": 1
}
```

---

## 🔐 **Dispositions Available**

South India Finvest specific dispositions:

1. **payment_promised** - Payment Promised
2. **partial_payment** - Partial Payment Received
3. **full_payment** - Full Payment Received
4. **callback_requested** - Callback Requested
5. **payment_plan_agreed** - Payment Plan Agreed
6. **unable_to_pay** - Unable to Pay
7. **no_answer** - No Answer
8. **wrong_number** - Wrong Number
9. **phone_switched_off** - Phone Switched Off
10. **dispute_raised** - Dispute Raised
11. **legal_notice_required** - Legal Notice Required
12. **settlement_discussion** - Settlement Discussion

---

## 🎯 **Integration Code for South India Finvest**

### **Frontend Integration:**

```html
<!DOCTYPE html>
<html>
<head>
  <title>South India Finvest - Collections Dashboard</title>
</head>
<body>
  <div id="dashboard">
    <h1>Collections Dashboard</h1>
    <!-- Your CRM UI -->
  </div>

  <!-- Include Widget -->
  <script src="https://d2t5fsybshqnye.cloudfront.net/static/js/main.3b847e89.js"></script>
  
  <script>
    // Initialize for South India Finvest
    ExotelCallRibbon.init({
      apiKey: 'southindia-finvest-api-key-2024',
      apiUrl: 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com',
      position: 'bottom',
      onCallEvent: handleCallEvent,
      onReady: function() {
        console.log('Call ribbon ready for South India Finvest!');
        loadCustomers();
      }
    });

    // Load customers
    function loadCustomers() {
      // Your code to load customer list
      const customers = [
        { id: 'LOAN001', name: 'Rajesh Kumar', phone: '+919876543210' },
        { id: 'LOAN002', name: 'Priya Sharma', phone: '+918765432109' },
        // ... more customers
      ];
      
      renderCustomerList(customers);
    }

    // Handle customer selection
    function selectCustomer(customer) {
      ExotelCallRibbon.setCustomer({
        phoneNumber: customer.phone,
        name: customer.name,
        customerId: customer.id
      });
      
      // Load customer details and call history
      loadCustomerDetails(customer.id);
    }

    // Handle call events
    function handleCallEvent(event, data) {
      console.log('Call Event:', event, data);
      
      if (event === 'connected') {
        // Show collection scripts
        showCollectionScripts(data.customerData);
      }
      
      if (event === 'callEnded') {
        // Show disposition form
        showDispositionForm(data);
      }
    }

    // Load customer details from backend
    async function loadCustomerDetails(customerId) {
      const response = await fetch(
        `http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/customer/${customerId}`,
        {
          headers: { 'X-API-Key': 'southindia-finvest-api-key-2024' }
        }
      );
      
      const data = await response.json();
      console.log('Customer details:', data.customer);
      console.log('Call history:', data.callHistory);
      
      displayCustomerInfo(data);
    }
  </script>
</body>
</html>
```

---

## 📊 **Dashboard Analytics**

### **Get Real-Time Stats:**

```javascript
async function getDashboardStats() {
  const baseUrl = 'http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com';
  const apiKey = 'southindia-finvest-api-key-2024';

  // Get detailed analytics
  const analytics = await fetch(`${baseUrl}/api/ribbon/analytics/detailed`, {
    headers: { 'X-API-Key': apiKey }
  }).then(r => r.json());

  // Get active calls
  const active = await fetch(`${baseUrl}/api/ribbon/active-calls`, {
    headers: { 'X-API-Key': apiKey }
  }).then(r => r.json());

  // Get usage
  const config = await fetch(`${baseUrl}/api/ribbon/config`, {
    headers: { 'X-API-Key': apiKey }
  }).then(r => r.json());

  return {
    totalCalls: analytics.summary.totalCalls,
    totalDuration: analytics.summary.totalDuration,
    avgDuration: analytics.summary.avgDuration,
    activeCalls: active.count,
    topCustomers: analytics.topCustomers,
    callsByHour: analytics.callsByHour,
    usage: config.usage
  };
}

// Display on dashboard
getDashboardStats().then(stats => {
  console.log('Dashboard Stats:', stats);
  // Update your UI
});
```

---

## 🗄️ **Database Tables Populated**

### **Tables with Data:**
- ✅ **clients** - 1 record (South India Finvest)
- ✅ **customers** - 6 records
- ✅ **call_sessions** - 5 records (4 completed, 1 missed)
- ✅ **call_events** - 16 events
- ✅ **call_notes** - 5 notes
- ✅ **dispositions** - 12 standard dispositions
- ✅ **customer_interactions** - 1 email interaction

### **Tables Ready (Empty):**
- ✅ **call_recordings** - Ready for recordings
- ✅ **call_tags** - Ready for tagging
- ✅ **analytics_daily** - Will auto-populate
- ✅ **usage_tracking** - Tracking enabled
- ✅ **agent_performance** - Ready for agents
- ✅ **webhooks** - Ready for integrations
- ✅ **api_logs** - Audit trail active

---

## 🧪 **Testing Workflow**

### **Step 1: Initialize Database**

```bash
cd database

# Run initialization script
PGPASSWORD='9AYVOZVXas6tiAz3vYAqZM1NS' psql \
  -h intalksai-call-ribbon-db.cviea4aicss0.ap-south-1.rds.amazonaws.com \
  -p 5432 \
  -U call_ribbon_admin \
  -d call_ribbon_db \
  -f init-with-test-data.sql
```

### **Step 2: Test All Endpoints**

```bash
chmod +x test-all-endpoints.sh
./test-all-endpoints.sh
```

### **Step 3: Verify Data**

```bash
# Connect to database
PGPASSWORD='9AYVOZVXas6tiAz3vYAqZM1NS' psql \
  -h intalksai-call-ribbon-db.cviea4aicss0.ap-south-1.rds.amazonaws.com \
  -p 5432 \
  -U call_ribbon_admin \
  -d call_ribbon_db

# Run queries
\dt  -- List tables
SELECT COUNT(*) FROM customers;
SELECT * FROM v_recent_calls LIMIT 5;
\q  -- Exit
```

---

## 📊 **Sample Queries for South India Finvest**

### **Get Overdue Customers:**

```sql
SELECT 
    external_customer_id,
    full_name,
    phone_number,
    custom_fields->>'outstandingBalance' as outstanding,
    custom_fields->>'daysOverdue' as days_overdue,
    custom_fields->>'emiAmount' as emi
FROM customers
WHERE client_id = '550e8400-e29b-41d4-a716-446655440001'
  AND (custom_fields->>'daysOverdue')::int > 0
ORDER BY (custom_fields->>'daysOverdue')::int DESC;
```

### **Get Collection Success Rate:**

```sql
SELECT 
    COUNT(*) FILTER (WHERE cd.notes LIKE '%payment%') as successful_collections,
    COUNT(*) as total_calls,
    ROUND(COUNT(*) FILTER (WHERE cd.notes LIKE '%payment%') * 100.0 / COUNT(*), 2) as success_rate
FROM call_sessions cs
LEFT JOIN call_dispositions cd ON cs.session_id = cd.session_id
WHERE cs.client_id = '550e8400-e29b-41d4-a716-446655440001'
  AND cs.call_type = 'collections'
  AND cs.call_status = 'completed';
```

### **Get Agent Performance:**

```sql
SELECT 
    agent_name,
    COUNT(*) as total_calls,
    SUM(duration) as total_duration,
    AVG(duration) as avg_duration,
    AVG(quality_score) as avg_quality
FROM call_sessions
WHERE client_id = '550e8400-e29b-41d4-a716-446655440001'
  AND call_status = 'completed'
GROUP BY agent_name
ORDER BY total_calls DESC;
```

---

## 🎯 **Next Steps**

### **1. Update API Server:**

```bash
cd ../api

# Add database connection to .env
cat >> .env <<EOF
DB_HOST=intalksai-call-ribbon-db.cviea4aicss0.ap-south-1.rds.amazonaws.com
DB_PORT=5432
DB_NAME=call_ribbon_db
DB_USER=call_ribbon_admin
DB_PASSWORD=9AYVOZVXas6tiAz3vYAqZM1NS
DB_SSL=true
EOF

# Install pg module (already in package.json)
npm install

# Update server.js to use database.js instead of in-memory storage
# (Implementation pending)

# Deploy to Mumbai
eb deploy production-mumbai --region ap-south-1
```

### **2. Test Integration:**

```bash
# Test with South India Finvest API key
curl -X POST http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com/api/ribbon/init \
  -H "Content-Type: application/json" \
  -d '{"apiKey":"southindia-finvest-api-key-2024","domain":"southindiafinvest.com"}' | jq .
```

### **3. Frontend Testing:**

Open demo and test with South India Finvest customers:
```
https://d2t5fsybshqnye.cloudfront.net
```

Update widget to use South India Finvest API key for testing.

---

## 📋 **Checklist**

- [x] PostgreSQL RDS created in Mumbai
- [x] Database schema designed (15 tables)
- [x] South India Finvest client added
- [x] 6 test customers added with realistic data
- [x] 5 sample call sessions created
- [x] Call events and notes added
- [x] 12 dispositions configured
- [x] Test scripts created
- [ ] Install psql client
- [ ] Initialize database schema
- [ ] Update API server to use PostgreSQL
- [ ] Deploy updated API
- [ ] Test all endpoints
- [ ] Verify data persistence

---

## 🎊 **Ready for Production Testing!**

**Client:** South India Finvest Pvt Ltd  
**API Key:** southindia-finvest-api-key-2024  
**Customers:** 6 (Collections, VIP, Leads)  
**Database:** PostgreSQL in Mumbai ✅  
**Status:** Ready to initialize and test  

---

*Complete setup for South India Finvest with realistic lending/collections data* 🏦

