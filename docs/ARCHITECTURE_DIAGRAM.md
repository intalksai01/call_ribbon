# Exotel Call Ribbon - Architecture & Security

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CLIENT CRM APPLICATION                              │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  CRM UI (HTML/JavaScript)                                            │   │
│  │  ─────────────────────────────────────────────────────────────────  │   │
│  │  • Customer lists                                                    │   │
│  │  • Call history                                                      │   │
│  │  • Agent dashboard                                                   │   │
│  └──────────────────────────┬──────────────────────────────────────────┘   │
│                             │                                                │
│                             ▼                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ExotelCallRibbon Widget (JavaScript)                                │   │
│  │  ─────────────────────────────────────────────────────────────────  │   │
│  │  ExotelCallRibbon.init({                                             │   │
│  │    apiKey: 'your-client-api-key-123'  ← ONLY THIS!                 │   │
│  │  });                                                                  │   │
│  └──────────────────────────┬──────────────────────────────────────────┘   │
│                             │                                                │
└─────────────────────────────┼────────────────────────────────────────────────┘
                              │
                              │ HTTPS (TLS 1.3)
                              │ Sends: Client API Key
                              │ Never sends: Exotel credentials
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      YOUR BACKEND API SERVER                                 │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  POST /api/ribbon/init                                               │   │
│  │  ─────────────────────────────────────────────────────────────────  │   │
│  │  1. Receive: Client API Key                                          │   │
│  │  2. Validate: Domain whitelist                                        │   │
│  │  3. Check: Usage limits                                               │   │
│  │  4. Lookup: Exotel credentials from database                          │   │
│  │  5. Return: Session config (internal to widget)                       │   │
│  └──────────────────────────┬──────────────────────────────────────────┘   │
│                             │                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Secure Database                                                      │   │
│  │  ─────────────────────────────────────────────────────────────────  │   │
│  │  {                                                                    │   │
│  │    apiKey: 'client-api-key-123',                                     │   │
│  │    clientName: 'Acme Corp',                                           │   │
│  │    exotelToken: '9875596a...',    ← Stored securely               │   │
│  │    exotelUserId: 'f6e23a8c...',   ← Never exposed to client        │   │
│  │    allowedDomains: ['acme.com'],                                      │   │
│  │    monthlyLimit: 10000                                                │   │
│  │  }                                                                    │   │
│  └──────────────────────────┬──────────────────────────────────────────┘   │
│                             │                                                │
└─────────────────────────────┼────────────────────────────────────────────────┘
                              │
                              │ HTTPS
                              │ Uses: Exotel Token (from database)
                              │ Client never sees this!
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          EXOTEL API                                          │
│                                                                               │
│  • WebRTC SIP Server                                                         │
│  • Call routing                                                              │
│  • DTMF handling                                                             │
│  • Call recordings                                                           │
│  • Analytics                                                                 │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Flow

### Step-by-Step Authentication

```
STEP 1: Client Initialization
─────────────────────────────
Client Browser:
  ExotelCallRibbon.init({
    apiKey: 'client-api-key-123'
  });
  
  ↓ Sends over HTTPS

Your API Server:
  ✓ Received: Client API Key
  ✓ Validates domain: 'acme.com'
  ✓ Checks usage: 125/10000 calls used
  
  ↓ Looks up in database

Database:
  client-api-key-123 → {
    exotelToken: '9875596a...',
    exotelUserId: 'f6e23a8c...'
  }
  
  ↓ Returns session config

Client Browser:
  ✓ Widget initialized
  ✓ Ready to make calls
  ✗ Never received Exotel credentials


STEP 2: Making a Call
─────────────────────
Client Browser:
  Customer selected: +919876543210
  Widget sends dial request
  
  ↓ HTTPS request to your server

Your API Server:
  ✓ Validates Client API Key
  ✓ Retrieves Exotel credentials from DB
  ✓ Authenticates with Exotel using stored token
  
  ↓ HTTPS request to Exotel

Exotel API:
  ✓ Validates Exotel token
  ✓ Initiates call
  ✓ Returns call status
  
  ↓ Response back to client

Client Browser:
  ✓ Call connected
  ✓ Timer starts
  ✗ Still never saw Exotel credentials
```

---

## 🔑 Credential Management

### What Gets Stored Where

```
┌─────────────────────────────────────────────────────────────┐
│  CLIENT SIDE (Browser)                                       │
├─────────────────────────────────────────────────────────────┤
│  ✅ Client API Key: 'client-api-key-123'                    │
│  ✅ Session tokens (temporary, managed by widget)           │
│  ✅ Customer data (phone numbers, names)                    │
│  ✅ Call state (active, muted, on hold)                     │
│                                                               │
│  ❌ Exotel Token: NOT STORED                                │
│  ❌ Exotel User ID: NOT STORED                              │
│  ❌ Exotel Account Info: NOT STORED                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  SERVER SIDE (Your Backend)                                  │
├─────────────────────────────────────────────────────────────┤
│  ✅ Client API Key: 'client-api-key-123'                    │
│  ✅ Client metadata (name, plan, limits)                    │
│  ✅ Domain whitelist                                         │
│  ✅ Usage statistics                                         │
│                                                               │
│  🔒 Exotel Token: ENCRYPTED IN DATABASE                     │
│  🔒 Exotel User ID: ENCRYPTED IN DATABASE                   │
│  🔒 Exotel Account SID: ENCRYPTED IN DATABASE               │
└─────────────────────────────────────────────────────────────┘
```

### Credential Lifecycle

```
┌──────────────────┐
│  Client Signs Up │
└────────┬─────────┘
         │
         ▼
┌────────────────────────────────┐
│  We Generate:                   │
│  • Client API Key              │
│  • Database entry              │
│  • Domain whitelist            │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│  We Link (Server-Side):         │
│  • Client API Key →             │
│  • Your Exotel Token            │
│  • Your Exotel User ID          │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│  We Send Client:                │
│  • Client API Key ONLY          │
│  • Integration docs             │
│  • Widget script URL            │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│  Client Integrates:             │
│  • Uses Client API Key          │
│  • Never sees Exotel creds      │
│  • Calls work seamlessly        │
└────────────────────────────────┘
```

---

## 🛡️ Security Layers

### Layer 1: Transport Security
```
┌─────────────────────────────────────────┐
│  TLS 1.3 Encryption                     │
│  • All traffic encrypted                │
│  • Certificate validation               │
│  • Perfect forward secrecy              │
└─────────────────────────────────────────┘
```

### Layer 2: API Key Validation
```
┌─────────────────────────────────────────┐
│  Client API Key Verification            │
│  • Key exists in database               │
│  • Domain matches whitelist             │
│  • Account is active                    │
│  • Usage within limits                  │
└─────────────────────────────────────────┘
```

### Layer 3: Credential Isolation
```
┌─────────────────────────────────────────┐
│  Server-Side Credential Management      │
│  • Exotel creds in encrypted DB         │
│  • Never sent to client                 │
│  • Rotatable without client changes     │
│  • Separate per environment             │
└─────────────────────────────────────────┘
```

### Layer 4: Domain Restrictions
```
┌─────────────────────────────────────────┐
│  Origin Validation                      │
│  • Requests from allowed domains only   │
│  • CORS policy enforced                 │
│  • Subdomain restrictions optional      │
└─────────────────────────────────────────┘
```

### Layer 5: Usage Metering
```
┌─────────────────────────────────────────┐
│  Call Tracking & Limits                 │
│  • Real-time usage counting             │
│  • Monthly limits enforced              │
│  • Overage protection                   │
│  • Billing integration                  │
└─────────────────────────────────────────┘
```

---

## 🔄 Comparison: Traditional vs Our Architecture

### ❌ Traditional Approach (Insecure)

```
Client Code:
  const exotelToken = '9875596a...';  // ← Exposed in browser!
  const exotelUserId = 'f6e23a8c...'; // ← Visible to anyone!
  
  ExotelSDK.init({
    token: exotelToken,
    userId: exotelUserId
  });

Problems:
  ❌ Credentials visible in browser DevTools
  ❌ Exposed in JavaScript source
  ❌ Can be stolen from client-side
  ❌ Hard to rotate (requires code changes)
  ❌ No usage tracking
  ❌ No domain restrictions
```

### ✅ Our Approach (Secure)

```
Client Code:
  const clientApiKey = 'client-api-key-123'; // ← Safe to expose
  
  ExotelCallRibbon.init({
    apiKey: clientApiKey  // ← Domain-restricted, tracked
  });
  
  // Exotel credentials managed server-side automatically

Benefits:
  ✅ Credentials never in browser
  ✅ Safe to commit to version control
  ✅ Easy credential rotation
  ✅ Built-in usage tracking
  ✅ Domain restrictions enforced
  ✅ Multi-tenant ready
```

---

## 📊 Data Flow Diagram

### Call Initiation Flow

```
1. User Action
   │
   ├─> Client clicks "Call Customer"
   │
   ▼
2. Widget Request
   │
   ├─> POST /api/ribbon/init
   │   {
   │     apiKey: 'client-api-key-123',
   │     domain: 'acme.com'
   │   }
   │
   ▼
3. Server Validation
   │
   ├─> ✓ API key valid?
   ├─> ✓ Domain allowed?
   ├─> ✓ Usage within limit?
   │
   ▼
4. Database Lookup
   │
   ├─> Retrieve Exotel credentials
   │   {
   │     exotelToken: '9875596a...',
   │     exotelUserId: 'f6e23a8c...'
   │   }
   │
   ▼
5. Server → Exotel
   │
   ├─> Authenticate with Exotel
   ├─> Request WebRTC session
   │
   ▼
6. Exotel → Server
   │
   ├─> Return session config
   ├─> SIP credentials (temporary)
   │
   ▼
7. Server → Client
   │
   ├─> Return widget config
   │   (Internal session tokens only)
   │
   ▼
8. Client Connects
   │
   ├─> WebRTC connection established
   ├─> Call initiated
   │
   ▼
9. Call Active
   │
   └─> User can now make/receive calls
```

---

## 🎯 Key Takeaways

### For Clients

1. **You only need:** One Client API Key
2. **You never handle:** Exotel credentials
3. **You get:** Full calling functionality
4. **You benefit from:** Our security infrastructure

### For Your Backend

1. **We manage:** All Exotel credential mapping
2. **We provide:** Secure API endpoints
3. **We handle:** Authentication, billing, analytics
4. **We ensure:** Zero credential exposure

### Security Guarantees

```
┌──────────────────────────────────────────────────────────┐
│  ✅ Exotel credentials NEVER in client JavaScript        │
│  ✅ Exotel credentials NEVER in browser storage          │
│  ✅ Exotel credentials NEVER in HTTP responses           │
│  ✅ Exotel credentials ENCRYPTED at rest                 │
│  ✅ All communication over TLS 1.3                       │
│  ✅ Domain restrictions enforced                         │
│  ✅ Usage limits enforced                                │
│  ✅ Complete audit trail                                 │
└──────────────────────────────────────────────────────────┘
```

---

*This architecture ensures maximum security while providing the simplest possible integration experience for your CRM application.*

