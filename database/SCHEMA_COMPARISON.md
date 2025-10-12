# Database Schema Comparison

## 🔴 Current Schema (TOO COMPLEX)
**15 tables** - Trying to be a full CRM system

### Problems:
❌ **customers table** - Too detailed (address, job title, company, etc.)
❌ **call_recordings table** - Recording storage/management (not our job)
❌ **call_tags table** - Complex tagging system
❌ **dispositions table** - Call disposition codes
❌ **webhooks table** - Webhook management
❌ **analytics_daily table** - Redundant aggregations
❌ **agent_performance table** - HR/performance tracking
❌ **campaigns table** - Marketing campaign management
❌ **custom_fields table** - CRM customization

**Result:** We're trying to replicate their entire CRM! ❌

---

## ✅ Simplified Schema (RECOMMENDED)
**6 tables** - Focused on what we actually own

### Core Philosophy:
> **"We own the call, not the customer"**

### Tables:

#### 1. **clients** (Our Customers)
- Who pays us to use the widget
- Their Exotel credentials
- Subscription & limits
- Features enabled

#### 2. **call_sessions** (The Heart)
- Every call made through our widget
- Basic customer context (name, phone, their CRM ID)
- Call timeline & outcome
- Agent info (passed from their system)
- **Flexible JSONB fields** for any extra context they want to pass

#### 3. **call_events** (Detailed Log)
- Mute, hold, transfer, DTMF, etc.
- Event timeline for each call
- Debugging & analytics

#### 4. **call_notes** (Optional)
- Agent notes during/after call
- Simple text notes

#### 5. **usage_tracking** (Billing)
- Daily call counts
- Total duration
- For billing purposes

#### 6. **api_logs** (Optional - Debugging)
- API request logs
- Error tracking
- Troubleshooting

---

## Key Design Decisions

### ✅ What We Store:
1. **Call History** - Complete timeline of every call
2. **Basic Customer Context** - Name, phone, their CRM ID
3. **Flexible Metadata** - JSONB fields for client-specific data
4. **Usage Data** - For billing
5. **Event Logs** - For analytics & debugging

### ❌ What We DON'T Store:
1. **Customer Master Data** - That lives in their CRM
2. **Campaign Management** - Their responsibility
3. **Agent Performance** - Their HR system
4. **Recording Files** - Exotel handles this
5. **Complex Disposition Codes** - Too CRM-specific

---

## Data Flow

```
Client's CRM → Call Initiated → Our Widget → Exotel → Call Session Created
                                                ↓
                            Customer Context (name, phone, ID)
                                                ↓
                            We store: call timeline + context
                                                ↓
                            They query: call history via API
```

### What Client Passes to Us:
```json
{
  "phoneNumber": "+919876543210",
  "name": "Rajesh Kumar",
  "customerId": "LOAN001",
  "context": {
    "loanType": "Business Loan",
    "amount": 150000,
    "daysOverdue": 45,
    "agentId": "AGT001",
    "campaign": "collections_q1"
  }
}
```

### What We Store:
```sql
call_sessions:
  customer_name: "Rajesh Kumar"
  customer_phone: "+919876543210"
  customer_id_external: "LOAN001"
  customer_context: {"loanType": "Business Loan", "amount": 150000, ...}
  agent_id: "AGT001"
  metadata: {"campaign": "collections_q1"}
```

### What We Return:
```json
{
  "sessionId": "uuid",
  "customerName": "Rajesh Kumar",
  "customerPhone": "+919876543210",
  "customerId": "LOAN001",
  "callStatus": "completed",
  "duration": 335,
  "events": [...],
  "context": {...}
}
```

---

## API Endpoints (Simplified)

### For Clients:
1. `POST /api/ribbon/init` - Get credentials
2. `POST /api/ribbon/call/start` - Start call (we store basic context)
3. `GET /api/ribbon/calls` - Get call history
4. `GET /api/ribbon/calls/:sessionId` - Get call details
5. `POST /api/ribbon/calls/:sessionId/note` - Add note

### For Admin:
1. `GET /api/admin/clients` - List clients
2. `GET /api/admin/usage` - Usage stats
3. `GET /api/admin/analytics` - System analytics

---

## Migration Path

If we want to migrate from complex → simple:

```sql
-- Keep only essential tables
DROP TABLE IF EXISTS campaigns CASCADE;
DROP TABLE IF EXISTS agent_performance CASCADE;
DROP TABLE IF EXISTS custom_fields CASCADE;
DROP TABLE IF EXISTS dispositions CASCADE;
DROP TABLE IF EXISTS call_tags CASCADE;
DROP TABLE IF EXISTS call_recordings CASCADE;
DROP TABLE IF EXISTS webhooks CASCADE;
DROP TABLE IF EXISTS analytics_daily CASCADE;

-- Simplify customers table to just call_sessions
-- (customers table becomes redundant)
```

---

## Benefits of Simplified Schema

### ✅ Advantages:
1. **Clear Responsibility** - We own calls, they own customers
2. **Easier to Integrate** - Less data to sync
3. **Faster Queries** - Fewer joins, simpler indexes
4. **Flexible** - JSONB fields handle client-specific needs
5. **Maintainable** - Less code, less complexity
6. **Scalable** - Focused data model scales better
7. **Privacy** - We don't store sensitive customer data

### 📊 Data Volume Estimate:
- **1 million calls/month** across all clients
- **call_sessions**: ~50 MB/month
- **call_events**: ~100 MB/month (3-5 events per call)
- **Total**: ~150 MB/month = **1.8 GB/year**

Very manageable! 🎉

---

## Recommendation

✅ **Use the simplified schema (`schema-simplified.sql`)**

### Reasons:
1. Matches our actual business model
2. Easier for clients to integrate
3. Less maintenance overhead
4. Faster performance
5. Clear separation of concerns
6. GDPR/privacy friendly (we don't store PII unnecessarily)

### Next Steps:
1. Review simplified schema
2. Update `database.js` to match new schema
3. Update API endpoints to use simplified tables
4. Create migration script if needed
5. Update client documentation

