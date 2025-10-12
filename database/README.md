# 🗄️ Database Setup - PostgreSQL RDS Mumbai

## Overview

Comprehensive PostgreSQL database for call center tracking, customer management, and analytics.

**Region:** ap-south-1 (Mumbai)  
**Engine:** PostgreSQL 16.10  
**Instance:** db.t3.micro (20GB storage)

---

## 📊 **Database Schema**

### **15 Tables Designed for Call Center Operations:**

#### **1. Core Tables:**
- **clients** - Client/tenant configuration and credentials
- **customers** - Customer information with flexible custom fields
- **call_sessions** - Main call tracking table
- **call_events** - Detailed event log for each call

#### **2. Call Management:**
- **call_notes** - Notes and comments for calls
- **call_recordings** - Recording metadata and storage
- **call_tags** - Flexible tagging system
- **dispositions** - Call outcomes/dispositions
- **call_dispositions** - Links calls to dispositions

#### **3. Analytics & Reporting:**
- **analytics_daily** - Pre-aggregated daily statistics
- **agent_performance** - Agent metrics and KPIs
- **customer_interactions** - All touchpoints across channels

#### **4. Operations:**
- **usage_tracking** - API usage for billing
- **webhooks** - Webhook configurations
- **api_logs** - Audit trail for API requests

---

## 🚀 **Quick Setup**

### **Step 1: Create RDS Instance**

```bash
cd database
chmod +x setup-rds-mumbai.sh
./setup-rds-mumbai.sh
```

**Wait:** 5-10 minutes for RDS creation

### **Step 2: Initialize Schema**

```bash
# Get connection details from rds-connection-info.txt
psql -h <DB_ENDPOINT> -p 5432 -U call_ribbon_admin -d call_ribbon_db -f schema.sql
```

### **Step 3: Update API Configuration**

```bash
# Add to api/.env
cat >> ../api/.env <<EOF
DB_HOST=<DB_ENDPOINT>
DB_PORT=5432
DB_NAME=call_ribbon_db
DB_USER=call_ribbon_admin
DB_PASSWORD=<PASSWORD_FROM_RDS_INFO>
DB_SSL=true
EOF
```

### **Step 4: Install Dependencies & Deploy**

```bash
cd ../api
npm install
eb deploy production-mumbai --region ap-south-1
```

---

## 📋 **Database Tables Details**

### **1. clients**

Stores client/tenant information.

```sql
Key Fields:
- client_id (UUID, PK)
- api_key (VARCHAR, UNIQUE)
- client_name
- exotel_token (encrypted)
- exotel_user_id (encrypted)
- plan_type (trial/starter/professional/enterprise)
- monthly_call_limit
- calls_this_month
- features (JSONB)
- allowed_domains (JSONB)
```

**Usage:**
- Multi-tenant support
- API key validation
- Usage limit enforcement
- Feature access control

---

### **2. customers**

Stores customer/contact information.

```sql
Key Fields:
- customer_id (UUID, PK)
- client_id (UUID, FK)
- external_customer_id (from client's CRM)
- full_name, email, phone_number
- company_name, job_title
- customer_type, segment, priority
- tags (JSONB array)
- custom_fields (JSONB - flexible schema)
- total_calls, total_call_duration (denormalized stats)
```

**Custom Fields Example:**
```json
{
  "accountBalance": 5000,
  "lastPaymentDate": "2025-09-15",
  "loyaltyTier": "gold",
  "preferredLanguage": "en",
  "timezone": "Asia/Kolkata"
}
```

---

### **3. call_sessions**

Main call tracking table.

```sql
Key Fields:
- session_id (UUID, PK)
- client_id, customer_id (FKs)
- exotel_call_sid
- phone_number
- call_direction (inbound/outbound)
- call_type (sales/support/collections)
- initiated_at, connected_at, ended_at
- duration, ring_duration
- call_status (initiated/connected/completed/failed/missed)
- end_reason
- quality_score
- agent_id, agent_name
- metadata (JSONB)
```

**Call Status Flow:**
```
initiated → ringing → connected → completed
                   ↘ → failed
                   ↘ → missed
                   ↘ → busy
```

---

### **4. call_events**

Detailed event log for debugging and tracking.

```sql
Key Fields:
- event_id (UUID, PK)
- session_id (FK)
- event_type (incoming/connected/muted/hold/dtmf/callEnded)
- event_data (JSONB)
- event_timestamp
- source, domain, ip_address
```

**Event Types:**
- incoming, ringing, connected
- muted, unmuted
- hold, resume
- dtmf
- transferred
- callEnded

---

### **5. call_notes**

Notes added during or after calls.

```sql
Key Fields:
- note_id (UUID, PK)
- session_id, customer_id (FKs)
- note_text
- note_type (general/follow_up/issue/success)
- created_by (agent)
- is_internal
```

---

### **6. analytics_daily**

Pre-aggregated daily statistics for performance.

```sql
Key Fields:
- report_date
- total_calls, inbound_calls, outbound_calls
- total_duration, avg_duration
- unique_customers, new_customers
- calls_by_hour (JSONB)
```

**Purpose:** Fast dashboard queries without scanning millions of rows

---

## 🔍 **Database Views**

### **v_recent_calls**
Recent calls with customer information joined.

### **v_daily_stats**
Daily statistics per client.

### **v_customer_call_summary**
Customer call history summary.

**Usage:**
```sql
-- Get recent calls
SELECT * FROM v_recent_calls 
WHERE client_id = 'xxx' 
LIMIT 50;

-- Get daily stats
SELECT * FROM v_daily_stats 
WHERE client_id = 'xxx' 
AND call_date >= CURRENT_DATE - INTERVAL '30 days';
```

---

## 🔄 **Triggers & Automation**

### **Auto-Update Timestamps:**
```sql
update_updated_at_column()
```
Automatically updates `updated_at` field on any UPDATE.

### **Auto-Update Customer Stats:**
```sql
update_customer_stats()
```
Automatically updates customer statistics when calls complete.

---

## 📊 **Scalability Features**

### **1. Indexes:**
- All foreign keys indexed
- Timestamp fields indexed for date range queries
- Phone numbers indexed for lookups
- Composite indexes for common queries

### **2. JSONB Fields:**
- Flexible schema for custom data
- GIN indexes on JSONB arrays
- Fast queries on nested data

### **3. Partitioning Ready:**
```sql
-- Can be partitioned by date for large datasets
-- Example: Partition call_sessions by month
```

### **4. Archiving Strategy:**
```sql
-- Move old data to archive tables
-- Example: Archive calls older than 1 year
CREATE TABLE call_sessions_archive (
  LIKE call_sessions INCLUDING ALL
);
```

---

## 🔐 **Security Features**

### **1. Encryption:**
- ✅ Storage encryption enabled
- ✅ SSL connections required
- ✅ Passwords hashed (application layer)
- ✅ Sensitive fields can be encrypted

### **2. Access Control:**
- Row-level security ready
- Client isolation via client_id
- Audit trail in api_logs

### **3. Backup:**
- ✅ 7-day automated backups
- ✅ Point-in-time recovery
- ✅ Manual snapshots supported

---

## 📈 **Sample Queries**

### **Get Today's Call Stats:**
```sql
SELECT 
  COUNT(*) as total_calls,
  COUNT(*) FILTER (WHERE call_status = 'completed') as completed,
  COUNT(*) FILTER (WHERE call_direction = 'inbound') as inbound,
  SUM(duration) as total_duration
FROM call_sessions
WHERE client_id = 'xxx'
  AND DATE(initiated_at) = CURRENT_DATE;
```

### **Get Top 10 Customers:**
```sql
SELECT 
  c.full_name,
  c.phone_number,
  COUNT(cs.session_id) as call_count,
  SUM(cs.duration) as total_talk_time
FROM customers c
INNER JOIN call_sessions cs ON c.customer_id = cs.customer_id
WHERE c.client_id = 'xxx'
GROUP BY c.customer_id, c.full_name, c.phone_number
ORDER BY call_count DESC
LIMIT 10;
```

### **Get Call Distribution by Hour:**
```sql
SELECT 
  EXTRACT(HOUR FROM initiated_at) as hour,
  COUNT(*) as call_count
FROM call_sessions
WHERE client_id = 'xxx'
  AND initiated_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY hour
ORDER BY hour;
```

### **Get Customer Call Timeline:**
```sql
SELECT 
  cs.initiated_at,
  cs.duration,
  cs.call_status,
  cn.note_text
FROM call_sessions cs
LEFT JOIN call_notes cn ON cs.session_id = cn.session_id
WHERE cs.customer_id = (
  SELECT customer_id FROM customers 
  WHERE external_customer_id = 'CUST001'
)
ORDER BY cs.initiated_at DESC;
```

---

## 🛠️ **Maintenance**

### **Daily Tasks:**
```sql
-- Update analytics_daily table
INSERT INTO analytics_daily (client_id, report_date, ...)
SELECT ... FROM call_sessions
WHERE DATE(initiated_at) = CURRENT_DATE - 1
ON CONFLICT (client_id, report_date) DO UPDATE ...;
```

### **Weekly Tasks:**
```sql
-- Archive old call events (>90 days)
DELETE FROM call_events 
WHERE event_timestamp < CURRENT_DATE - INTERVAL '90 days';

-- Vacuum tables
VACUUM ANALYZE call_sessions;
VACUUM ANALYZE call_events;
```

### **Monthly Tasks:**
```sql
-- Generate monthly reports
-- Archive completed calls (>1 year)
-- Review and optimize slow queries
```

---

## 📊 **Performance Optimization**

### **Indexes:**
```sql
-- Already created in schema.sql
-- Review with:
SELECT * FROM pg_indexes 
WHERE schemaname = 'public';
```

### **Query Performance:**
```sql
-- Analyze query performance
EXPLAIN ANALYZE 
SELECT * FROM call_sessions 
WHERE client_id = 'xxx' 
  AND initiated_at >= CURRENT_DATE - 7;
```

### **Connection Pooling:**
```javascript
// Already configured in database.js
pool: {
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
}
```

---

## 💰 **Cost Optimization**

### **Current Setup:**
```
db.t3.micro: ~$15/month
20GB gp3 storage: ~$2/month
7-day backups: ~$0.10/GB/month
Total: ~$18-20/month
```

### **Scaling Options:**

**For higher traffic:**
- db.t3.small: ~$30/month (2GB RAM)
- db.t3.medium: ~$60/month (4GB RAM)

**For more storage:**
- 50GB: ~$5/month
- 100GB: ~$10/month

---

## 🔄 **Migration from In-Memory**

Current `server.js` uses in-memory storage. Here's the migration plan:

### **Phase 1: Dual Write**
- Write to both in-memory and PostgreSQL
- Read from in-memory
- Verify data consistency

### **Phase 2: Dual Read**
- Write to both
- Read from PostgreSQL with in-memory fallback
- Monitor performance

### **Phase 3: PostgreSQL Only**
- Read and write only to PostgreSQL
- Remove in-memory storage
- Full production mode

---

## 📝 **Connection Examples**

### **Node.js (pg library):**
```javascript
const { Pool } = require('pg');

const pool = new Pool({
  host: 'intalksai-call-ribbon-db.xxx.ap-south-1.rds.amazonaws.com',
  port: 5432,
  database: 'call_ribbon_db',
  user: 'call_ribbon_admin',
  password: 'your-password',
  ssl: { rejectUnauthorized: false }
});

// Query
const result = await pool.query('SELECT * FROM clients WHERE api_key = $1', ['demo-api-key-789']);
```

### **psql (Command Line):**
```bash
psql -h intalksai-call-ribbon-db.xxx.ap-south-1.rds.amazonaws.com \
     -p 5432 \
     -U call_ribbon_admin \
     -d call_ribbon_db
```

### **pgAdmin / DBeaver:**
```
Host: intalksai-call-ribbon-db.xxx.ap-south-1.rds.amazonaws.com
Port: 5432
Database: call_ribbon_db
Username: call_ribbon_admin
Password: <from rds-connection-info.txt>
SSL: Require
```

---

## 🎯 **Features of This Data Model**

### **1. Multi-Tenant:**
- ✅ Complete client isolation
- ✅ Separate data per API key
- ✅ Per-client configuration

### **2. Flexible Schema:**
- ✅ JSONB fields for custom data
- ✅ Easy to add fields without migrations
- ✅ Tags and metadata support

### **3. Scalable:**
- ✅ Proper indexing
- ✅ Optimized queries
- ✅ View-based abstractions
- ✅ Partition-ready

### **4. Analytics-Ready:**
- ✅ Pre-aggregated tables
- ✅ Fast reporting queries
- ✅ Historical data retention
- ✅ Export capabilities

### **5. Extensible:**
- ✅ Easy to add new tables
- ✅ Relationship-based design
- ✅ Foreign key constraints
- ✅ Trigger support

---

## 📞 **Example: Complete Call Flow in Database**

```sql
-- 1. Call initiated
INSERT INTO call_sessions (client_id, phone_number, call_direction, call_status)
VALUES ('client-xxx', '+919876543210', 'outbound', 'initiated');

-- 2. Call connected
UPDATE call_sessions 
SET call_status = 'connected', connected_at = NOW()
WHERE session_id = 'session-xxx';

INSERT INTO call_events (session_id, event_type, event_data)
VALUES ('session-xxx', 'connected', '{"quality": "good"}');

-- 3. During call - add note
INSERT INTO call_notes (session_id, note_text, created_by)
VALUES ('session-xxx', 'Customer interested in premium plan', 'agent-001');

-- 4. Call ended
UPDATE call_sessions 
SET call_status = 'completed', 
    ended_at = NOW(),
    duration = EXTRACT(EPOCH FROM (NOW() - connected_at))
WHERE session_id = 'session-xxx';

INSERT INTO call_events (session_id, event_type)
VALUES ('session-xxx', 'callEnded');

-- 5. Add disposition
INSERT INTO call_dispositions (session_id, disposition_id, notes)
VALUES ('session-xxx', 
        (SELECT disposition_id FROM dispositions WHERE disposition_code = 'success'),
        'Successfully pitched premium plan');

-- Customer stats automatically updated via trigger!
```

---

## 🔍 **Monitoring & Maintenance**

### **Check Database Size:**
```sql
SELECT 
  pg_size_pretty(pg_database_size('call_ribbon_db')) as database_size;
```

### **Check Table Sizes:**
```sql
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### **Check Connection Pool:**
```sql
SELECT 
  count(*) as active_connections,
  max_conn,
  max_conn - count(*) as available_connections
FROM pg_stat_activity
CROSS JOIN (SELECT setting::int as max_conn FROM pg_settings WHERE name = 'max_connections') s
WHERE datname = 'call_ribbon_db';
```

### **Slow Query Log:**
```sql
SELECT 
  query,
  calls,
  total_time,
  mean_time,
  max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

---

## 📦 **Backup & Recovery**

### **Automated Backups:**
- ✅ Daily backups at 3:00-4:00 AM IST
- ✅ 7-day retention
- ✅ Point-in-time recovery enabled

### **Manual Snapshot:**
```bash
aws rds create-db-snapshot \
  --db-instance-identifier intalksai-call-ribbon-db \
  --db-snapshot-identifier backup-$(date +%Y%m%d-%H%M) \
  --region ap-south-1
```

### **Restore from Snapshot:**
```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier intalksai-call-ribbon-db-restored \
  --db-snapshot-identifier backup-20251012-1200 \
  --region ap-south-1
```

---

## 🎯 **Next Steps**

1. ✅ **RDS Instance Created** (running in background)
2. ⏳ **Wait for Availability** (5-10 minutes)
3. 📋 **Get Connection Info** (check `rds-connection-info.txt`)
4. 🗄️ **Initialize Schema** (run `schema.sql`)
5. 🔧 **Update API** (configure database connection)
6. 🚀 **Deploy** (redeploy API to Mumbai)
7. 🧪 **Test** (verify database operations)

---

## 📞 **Support**

**Check RDS Status:**
```bash
aws rds describe-db-instances \
  --db-instance-identifier intalksai-call-ribbon-db \
  --region ap-south-1 \
  --query 'DBInstances[0].DBInstanceStatus'
```

**View Logs:**
```bash
aws rds describe-db-log-files \
  --db-instance-identifier intalksai-call-ribbon-db \
  --region ap-south-1
```

---

*Database setup for production-grade call center tracking* 🗄️

