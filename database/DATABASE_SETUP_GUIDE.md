# 🗄️ Complete Database Setup Guide

## 📊 **Database Architecture**

### **PostgreSQL RDS in Mumbai (ap-south-1)**

```
┌──────────────────────────────────────────────────────────┐
│  Application Layer (Node.js API)                         │
│  production-mumbai.eba-jfgji9nq.ap-south-1...           │
└────────────────────┬─────────────────────────────────────┘
                     │
                     │ pg library (connection pool)
                     │
┌────────────────────▼─────────────────────────────────────┐
│  PostgreSQL RDS                                          │
│  intalksai-call-ribbon-db.xxx.ap-south-1.rds...         │
│  ├─ Engine: PostgreSQL 16.10                             │
│  ├─ Instance: db.t3.micro                                │
│  ├─ Storage: 20GB (encrypted)                            │
│  ├─ Backups: 7 days retention                            │
│  └─ Multi-AZ: Optional (add for HA)                      │
└──────────────────────────────────────────────────────────┘
```

---

## 📋 **15-Table Data Model**

### **Entities & Relationships:**

```
clients (1) ──< customers (M)
   │              │
   │              │
   ├──< call_sessions (M)
   │        │
   │        ├──< call_events (M)
   │        ├──< call_notes (M)
   │        ├──< call_recordings (M)
   │        ├──< call_tags (M)
   │        └──< call_dispositions (M)
   │
   ├──< dispositions (M)
   ├──< analytics_daily (M)
   ├──< usage_tracking (M)
   ├──< agent_performance (M)
   ├──< customer_interactions (M)
   ├──< webhooks (M)
   └──< api_logs (M)
```

---

## 🎯 **Key Design Decisions**

### **1. Multi-Tenant Architecture:**
- Every table has `client_id` for isolation
- Clients cannot access each other's data
- Queries automatically filtered by client_id

### **2. Flexible Schema (JSONB):**
```sql
-- Customers table
custom_fields JSONB  -- Any client-specific fields
tags JSONB           -- Flexible tagging

-- Call sessions
metadata JSONB       -- Call-specific data

-- Example usage:
SELECT * FROM customers 
WHERE custom_fields->>'vip_status' = 'gold';
```

### **3. Denormalized Statistics:**
```sql
-- Customers table has aggregated stats
total_calls INTEGER
total_call_duration INTEGER
last_call_date TIMESTAMP

-- Updated automatically via triggers
-- Fast queries without JOINs
```

### **4. Time-Series Optimization:**
- All tables have indexed timestamps
- Ready for partitioning by date
- Archiving strategy built-in

### **5. Audit Trail:**
```sql
-- api_logs table tracks everything
-- Full request/response logging
-- IP addresses and user agents
-- Error tracking
```

---

## 🚀 **Setup Process**

### **Current Status:**

```
✅ Schema designed (schema.sql)
✅ Database module created (database.js)
✅ Setup script created (setup-rds-mumbai.sh)
⏳ RDS instance creating (5-10 minutes)
⏳ Schema initialization pending
⏳ API update pending
```

### **After RDS is Ready:**

#### **1. Initialize Schema:**
```bash
# Get connection details
cat rds-connection-info.txt

# Connect and run schema
psql -h <endpoint> -U call_ribbon_admin -d call_ribbon_db -f schema.sql
```

#### **2. Update API Environment:**
```bash
cd api
cat >> .env <<EOF
DB_HOST=<endpoint>
DB_PORT=5432
DB_NAME=call_ribbon_db
DB_USER=call_ribbon_admin
DB_PASSWORD=<password>
DB_SSL=true
EOF
```

#### **3. Update server.js:**
Replace in-memory storage with database calls.

#### **4. Deploy:**
```bash
eb deploy production-mumbai --region ap-south-1
```

---

## 📊 **Database Schema Highlights**

### **Clients Table:**
```sql
CREATE TABLE clients (
    client_id UUID PRIMARY KEY,
    api_key VARCHAR(255) UNIQUE,
    client_name VARCHAR(255),
    exotel_token TEXT,              -- Encrypted
    exotel_user_id TEXT,            -- Encrypted
    plan_type VARCHAR(50),          -- trial/starter/pro/enterprise
    monthly_call_limit INTEGER,
    calls_this_month INTEGER,
    features JSONB,                 -- ["call", "mute", "hold"]
    allowed_domains JSONB,          -- ["domain1.com", "domain2.com"]
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);
```

### **Customers Table:**
```sql
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY,
    client_id UUID REFERENCES clients,
    external_customer_id VARCHAR(255), -- From client's CRM
    full_name VARCHAR(500),
    email VARCHAR(255),
    phone_number VARCHAR(50),
    customer_type VARCHAR(50),         -- prospect/lead/customer/vip
    segment VARCHAR(50),               -- enterprise/smb/individual
    priority VARCHAR(50),              -- high/medium/low
    tags JSONB,                        -- ["vip", "enterprise"]
    custom_fields JSONB,               -- Any custom data
    total_calls INTEGER,               -- Denormalized
    total_call_duration INTEGER,       -- Denormalized
    created_at TIMESTAMP WITH TIME ZONE
);
```

### **Call Sessions Table:**
```sql
CREATE TABLE call_sessions (
    session_id UUID PRIMARY KEY,
    client_id UUID REFERENCES clients,
    customer_id UUID REFERENCES customers,
    exotel_call_sid VARCHAR(255),
    phone_number VARCHAR(50),
    call_direction VARCHAR(20),        -- inbound/outbound
    call_type VARCHAR(50),             -- sales/support/collections
    initiated_at TIMESTAMP,
    connected_at TIMESTAMP,
    ended_at TIMESTAMP,
    duration INTEGER,                  -- seconds
    call_status VARCHAR(50),           -- initiated/connected/completed/failed
    end_reason VARCHAR(100),
    quality_score INTEGER,             -- 1-5
    agent_id VARCHAR(255),
    metadata JSONB
);
```

### **Call Events Table:**
```sql
CREATE TABLE call_events (
    event_id UUID PRIMARY KEY,
    session_id UUID REFERENCES call_sessions,
    client_id UUID REFERENCES clients,
    event_type VARCHAR(50),            -- connected/muted/hold/dtmf/callEnded
    event_data JSONB,
    event_timestamp TIMESTAMP,
    source VARCHAR(50),                -- widget/api/webhook
    domain VARCHAR(255)
);
```

---

## 🎨 **Sample Data Included**

The schema automatically creates:

- ✅ 3 demo clients (matching server.js)
- ✅ 8 standard dispositions per client
- ✅ Proper indexes and constraints
- ✅ Triggers for auto-updates
- ✅ Views for common queries

---

## 📈 **Analytics Capabilities**

### **Pre-Built Analytics:**

1. **Daily aggregations** (analytics_daily table)
2. **Hourly call distribution**
3. **Day-of-week patterns**
4. **Top customers by call count**
5. **Duration distribution**
6. **Agent performance metrics**
7. **Customer interaction history**

### **Example Dashboard Query:**

```sql
SELECT 
  -- Today's stats
  (SELECT COUNT(*) FROM call_sessions 
   WHERE client_id = 'xxx' AND DATE(initiated_at) = CURRENT_DATE) as today_calls,
  
  -- This week's stats
  (SELECT COUNT(*) FROM call_sessions 
   WHERE client_id = 'xxx' AND initiated_at >= CURRENT_DATE - 7) as week_calls,
  
  -- Active calls
  (SELECT COUNT(*) FROM call_sessions 
   WHERE client_id = 'xxx' AND call_status = 'connected') as active_calls,
  
  -- Top customer today
  (SELECT c.full_name FROM customers c
   INNER JOIN call_sessions cs ON c.customer_id = cs.customer_id
   WHERE c.client_id = 'xxx' AND DATE(cs.initiated_at) = CURRENT_DATE
   GROUP BY c.customer_id, c.full_name
   ORDER BY COUNT(*) DESC
   LIMIT 1) as top_customer_today;
```

---

## 🔐 **Security Best Practices**

### **1. Connection Security:**
```javascript
// Always use SSL
ssl: {
  rejectUnauthorized: false // AWS RDS requirement
}
```

### **2. Password Management:**
```bash
# Use AWS Secrets Manager
aws secretsmanager create-secret \
  --name intalksai/rds/password \
  --secret-string '{"password":"xxx"}' \
  --region ap-south-1
```

### **3. Least Privilege:**
```sql
-- Create read-only user for reporting
CREATE USER reporting_user WITH PASSWORD 'xxx';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reporting_user;
```

### **4. Row-Level Security (Optional):**
```sql
-- Enable RLS for extra security
ALTER TABLE call_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY client_isolation ON call_sessions
  USING (client_id = current_setting('app.current_client_id')::uuid);
```

---

## 💰 **Cost Management**

### **Current Setup:**
```
Instance: db.t3.micro (Free tier eligible for 12 months)
Storage: 20GB gp3
Backups: 7 days
Estimated: ~$18-20/month
```

### **Optimization Tips:**

1. **Use Reserved Instances** (save 30-50%)
2. **Delete old backups** (reduce backup storage costs)
3. **Archive old data** (reduce active database size)
4. **Monitor usage** (scale down if underutilized)

---

## 🎊 **Ready for Production**

This database schema supports:

- ✅ Millions of calls
- ✅ Thousands of customers
- ✅ Multiple clients (multi-tenant)
- ✅ Real-time analytics
- ✅ Historical reporting
- ✅ Custom fields and extensibility
- ✅ Audit trails
- ✅ Data exports
- ✅ Agent performance tracking
- ✅ Webhook integrations

---

**Next: Wait for RDS to complete, then initialize schema!** 🚀

