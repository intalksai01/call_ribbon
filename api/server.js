/**
 * Exotel Call Control Ribbon - Backend API Server
 * 
 * This server manages client authentication and Exotel credentials
 * 
 * Features:
 * - Client API key validation
 * - Exotel credential management
 * - Call logging and analytics
 * - Usage tracking for billing
 */

const express = require('express');
const cors = require('cors');
const app = express();

// Middleware
app.use(express.json());
app.use(cors({
  origin: '*', // Configure properly in production
  methods: ['POST', 'GET']
}));

// ============================================
// CLIENT DATABASE (Use real database in production)
// ============================================

const clients = {
  // Collections CRM Client
  'collections-crm-api-key-123': {
    clientId: 'client-001',
    name: 'Collections CRM Inc.',
    exotelToken: '9875596a6e1be7bfaa865f43a028ec40f980e57fdeb4de8c',
    exotelUserId: 'f6e23a8c3ce28cda4a76bce715dd714e1d138183f58179df',
    features: ['call', 'mute', 'hold', 'dtmf', 'transfer'],
    allowedDomains: ['collections-crm.com', 'localhost'],
    plan: 'enterprise',
    monthlyCallLimit: 10000,
    callsThisMonth: 0
  },

  // Marketing CRM Client
  'marketing-leads-api-key-456': {
    clientId: 'client-002',
    name: 'Marketing Leads Pro',
    exotelToken: 'different_exotel_token_here',
    exotelUserId: 'different_user_id_here',
    features: ['call', 'mute', 'hold'],
    allowedDomains: ['marketing-crm.com', 'localhost'],
    plan: 'professional',
    monthlyCallLimit: 5000,
    callsThisMonth: 0
  },

  // Demo/Testing Client
  'demo-api-key-789': {
    clientId: 'client-demo',
    name: 'Demo Client',
    exotelToken: '9875596a6e1be7bfaa865f43a028ec40f980e57fdeb4de8c', // Same as collections for demo
    exotelUserId: 'f6e23a8c3ce28cda4a76bce715dd714e1d138183f58179df',
    features: ['call', 'mute', 'hold', 'dtmf'],
    allowedDomains: ['*'], // Allow all domains for demo
    plan: 'trial',
    monthlyCallLimit: 100,
    callsThisMonth: 0
  }
};

// Call logs storage (Use real database in production)
const callLogs = [];

// ============================================
// API ENDPOINTS
// ============================================

/**
 * Initialize Ribbon - Get Exotel credentials
 */
app.post('/api/ribbon/init', (req, res) => {
  const { apiKey, domain } = req.body;

  console.log(`[API] Init request from domain: ${domain}, apiKey: ${apiKey?.substring(0, 10)}...`);

  // Validate API key
  const client = clients[apiKey];
  if (!client) {
    console.log('[API] Invalid API key');
    return res.status(401).json({ 
      error: 'Invalid API key',
      message: 'Please check your API key or contact support'
    });
  }

  // Check domain (skip for '*')
  if (!client.allowedDomains.includes('*') && !client.allowedDomains.includes(domain)) {
    console.log(`[API] Domain not allowed: ${domain}`);
    return res.status(403).json({ 
      error: 'Domain not allowed',
      message: `This API key is not authorized for domain: ${domain}`
    });
  }

  // Check usage limits
  if (client.callsThisMonth >= client.monthlyCallLimit) {
    console.log('[API] Monthly limit exceeded');
    return res.status(429).json({ 
      error: 'Usage limit exceeded',
      message: 'Monthly call limit reached. Please upgrade your plan.'
    });
  }

  console.log(`[API] Credentials provided for client: ${client.name}`);

  // Return credentials and configuration
  res.json({
    exotelToken: client.exotelToken,
    userId: client.exotelUserId,
    features: client.features,
    clientInfo: {
      name: client.name,
      plan: client.plan,
      remainingCalls: client.monthlyCallLimit - client.callsThisMonth
    }
  });
});

/**
 * Log Call Event
 */
app.post('/api/ribbon/log-call', (req, res) => {
  const { apiKey, event, data, timestamp, domain } = req.body;

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  // Create call log entry
  const logEntry = {
    logId: `log-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
    clientId: client.clientId,
    clientName: client.name,
    event,
    data,
    timestamp: timestamp || new Date().toISOString(),
    domain
  };

  callLogs.push(logEntry);

  // Increment call counter for 'connected' events
  if (event === 'connected') {
    client.callsThisMonth++;
  }

  console.log(`[API] Call logged: ${event} for ${client.name}`);

  res.json({ 
    success: true,
    logId: logEntry.logId
  });
});

/**
 * Get Client Configuration
 */
app.get('/api/ribbon/config', (req, res) => {
  const apiKey = req.headers['x-api-key'];

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  res.json({
    features: client.features,
    plan: client.plan,
    usage: {
      callsThisMonth: client.callsThisMonth,
      limit: client.monthlyCallLimit,
      remaining: client.monthlyCallLimit - client.callsThisMonth
    }
  });
});

/**
 * Get Call Analytics (Admin/Client Dashboard)
 */
app.get('/api/ribbon/analytics', (req, res) => {
  const apiKey = req.headers['x-api-key'];

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  // Filter logs for this client
  const clientLogs = callLogs.filter(log => log.clientId === client.clientId);

  // Calculate statistics
  const stats = {
    totalCalls: clientLogs.filter(log => log.event === 'connected').length,
    totalDuration: 0, // Calculate from call data
    incomingCalls: clientLogs.filter(log => log.event === 'incoming').length,
    outgoingCalls: clientLogs.filter(log => log.event === 'connected' && log.data.callDirection === 'outbound').length,
    recentCalls: clientLogs.slice(-10).reverse()
  };

  res.json(stats);
});

/**
 * Health Check
 */
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    version: '1.0.0',
    uptime: process.uptime()
  });
});

/**
 * List Clients (Admin only - add auth in production)
 */
app.get('/api/admin/clients', (req, res) => {
  // Add admin authentication here
  
  const clientList = Object.entries(clients).map(([apiKey, client]) => ({
    clientId: client.clientId,
    name: client.name,
    plan: client.plan,
    callsThisMonth: client.callsThisMonth,
    limit: client.monthlyCallLimit,
    apiKey: apiKey.substring(0, 10) + '...' // Masked
  }));

  res.json(clientList);
});

// ============================================
// ERROR HANDLING
// ============================================

app.use((err, req, res, next) => {
  console.error('[API] Error:', err);
  res.status(500).json({ 
    error: 'Internal server error',
    message: err.message
  });
});

// ============================================
// START SERVER
// ============================================

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════╗
║   Exotel Call Control Ribbon - API Server            ║
║   Version: 1.0.0                                      ║
║   Port: ${PORT}                                           ║
╚═══════════════════════════════════════════════════════╝

📋 Registered Clients:
${Object.values(clients).map(c => `   - ${c.name} (${c.plan})`).join('\n')}

🔗 API Endpoints:
   POST /api/ribbon/init        - Initialize ribbon
   POST /api/ribbon/log-call    - Log call events
   GET  /api/ribbon/config      - Get configuration
   GET  /api/ribbon/analytics   - Get analytics
   GET  /health                 - Health check

🚀 Server is ready!
  `);
});

module.exports = app;
