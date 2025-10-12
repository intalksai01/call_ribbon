# 🗄️ IntalksAI Call Ribbon - Database

## Overview

Simplified PostgreSQL database schema focused on **call history and context**, not trying to replicate a full CRM.

**Philosophy:** *"We own the call, not the customer"*

---

## 📊 Schema (6 Tables)

### 1. **clients**
Your paying customers who use the widget
- API keys
- Exotel credentials (managed server-side)
- Subscription & limits
- Features enabled

### 2. **call_sessions** ⭐ THE CORE
Every call made through the widget
- Customer context (name, phone, their CRM ID)
- Call timeline & outcome
- Agent information
- Flexible JSONB fields for business data

### 3. **call_events**
Detailed event log
- Mute, hold, transfer, DTMF events
- Event timeline
- Debugging data

### 4. **call_notes**
Agent notes during/after calls
- Text notes
- Note type (during_call, after_call)
- Agent info

### 5. **usage_tracking**
Daily usage summary
- Call counts
- Total duration
- For billing

### 6. **api_logs**
API request logs
- Debugging
- Error tracking
- Performance monitoring

---

## 🚀 Setup

### 1. Create RDS Instance

```bash
cd database
./setup-rds-mumbai.sh
```

This creates a PostgreSQL 16 instance in Mumbai (ap-south-1).

### 2. Initialize Schema

```bash
# Apply schema
psql -h <RDS_ENDPOINT> -U call_ribbon_admin -d call_ribbon_db -f schema-simplified.sql

# Load test data
psql -h <RDS_ENDPOINT> -U call_ribbon_admin -d call_ribbon_db -f init-simplified-test-data.sql
```

### 3. Configure API

Set environment variable in Elastic Beanstalk:

```bash
DATABASE_URL=postgresql://user:pass@host:5432/dbname
```

---

## 📈 What We Store

### Call Data ✅
- Call timeline (initiated, connected, ended)
- Call duration & outcome
- Call direction (inbound/outbound)
- Exotel call SID

### Customer Context ✅
- Name & phone (for display)
- Your CRM's customer ID (for linking)
- **Flexible JSONB context** - ANY business data

### Agent Info ✅
- Agent ID & name
- From your system

### Metadata ✅
- Campaign tags
- Call type
- Any custom tags

---

## ❌ What We DON'T Store

- ❌ Full customer profiles (that's your CRM)
- ❌ Customer addresses, documents
- ❌ Campaign management data
- ❌ Agent performance reviews
- ❌ Call recordings (Exotel handles this)
- ❌ Payment information

---

## 🔄 Data Flow

```
Client CRM → Widget → API → Database

What they send:
{
  phoneNumber: "+919876543210",
  name: "Rajesh Kumar",
  customerId: "LOAN001",
  context: {
    loanAmount: 500000,
    daysOverdue: 45
  }
}

What we store:
call_sessions {
  customer_name: "Rajesh Kumar",
  customer_phone: "+919876543210",
  customer_id_external: "LOAN001",
  customer_context: {...},  // JSONB
  duration: 270,
  call_status: "completed"
}

What they get back:
- Complete call history
- Rich analytics
- Their context data in every record
```

---

## 📊 Sample Data

The database includes test data for **South India Finvest**:
- 3 clients (Demo, Collections CRM, South India Finvest)
- 5 call sessions with customer context
- 16 call events
- 4 agent notes
- Usage tracking data

---

## 🔧 Management Scripts

### Create/Migrate Database
```bash
./setup-rds-mumbai.sh              # Create new RDS instance
./migrate-to-simplified.sh         # Migrate to simplified schema
```

### Test
```bash
./test-simplified-endpoints.sh     # Test all API endpoints
```

---

## 📈 Analytics Queries

The schema supports rich analytics through views:

### Daily Stats
```sql
SELECT * FROM daily_call_stats 
WHERE client_id = '...' 
AND call_date >= '2024-10-01';
```

### Customer Summary
```sql
SELECT * FROM customer_call_summary
WHERE client_id = '...'
ORDER BY total_calls DESC;
```

---

## 🔒 Security

- ✅ Encryption at rest (AWS KMS)
- ✅ Encryption in transit (SSL)
- ✅ Row-level security (client_id isolation)
- ✅ Backup retention: 7 days
- ✅ Publicly accessible: Yes (for API connectivity)

---

## 💰 Cost Estimate

**RDS PostgreSQL (db.t3.micro):**
- Instance: ~₹1,500/month
- Storage (20GB): ~₹200/month
- Backups: ~₹100/month

**Total: ~₹1,800/month** (~$18/month)

---

## 📋 Connection Details

```
Endpoint: intalksai-call-ribbon-db.cviea4aicss0.ap-south-1.rds.amazonaws.com
Port: 5432
Database: call_ribbon_db
Username: call_ribbon_admin
Region: ap-south-1 (Mumbai)
```

---

## 🆘 Support

Need help with database?
- 📧 contact@intalksai.com
- 📚 See [Schema Comparison](SCHEMA_COMPARISON.md) for design decisions
