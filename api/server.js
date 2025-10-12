/**
 * IntalksAI Call Control Ribbon - Backend API Server
 * 
 * This server manages client authentication and telephony credentials
 * 
 * Features:
 * - Client API key validation
 * - Telephony credential management
 * - Call logging and analytics
 * - Usage tracking for billing
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./database'); // PostgreSQL database module
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

// Customer info storage (Use real database in production)
const customers = {};

// Call sessions (track ongoing calls)
const callSessions = {};

// ============================================
// API ENDPOINTS
// ============================================

/**
 * Initialize Ribbon - Get Exotel credentials
 */
app.post('/api/ribbon/init', async (req, res) => {
  const { apiKey, domain } = req.body;

  console.log(`[API] Init request from domain: ${domain}, apiKey: ${apiKey?.substring(0, 10)}...`);

  try {
    // Get client from database
    const client = await db.clients.getByApiKey(apiKey);
    
    if (!client) {
      console.log('[API] Invalid API key');
      return res.status(401).json({ 
        error: 'Invalid API key',
        message: 'Please check your API key or contact support'
      });
    }

    // Check domain (skip for '*')
    const allowedDomains = client.allowed_domains || [];
    if (!allowedDomains.includes('*') && !allowedDomains.includes(domain)) {
      console.log(`[API] Domain not allowed: ${domain}`);
      return res.status(403).json({ 
        error: 'Domain not allowed',
        message: `This API key is not authorized for domain: ${domain}`
      });
    }

    // Check usage limits
    if (client.calls_this_month >= client.monthly_call_limit) {
      console.log('[API] Monthly limit exceeded');
      return res.status(429).json({ 
        error: 'Usage limit exceeded',
        message: 'Monthly call limit reached. Please upgrade your plan.'
      });
    }

    console.log(`[API] Credentials provided for client: ${client.client_name}`);

    // Return credentials and configuration
    res.json({
      exotelToken: client.exotel_token,
      userId: client.exotel_user_id,
      features: client.features,
      clientInfo: {
        name: client.client_name,
        plan: client.plan_type,
        remainingCalls: client.monthly_call_limit - client.calls_this_month
      }
    });
  } catch (error) {
    console.error('[API] Init error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message
    });
  }
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
    
    // Create call session
    const sessionId = data.callSid || `session-${Date.now()}`;
    callSessions[sessionId] = {
      sessionId,
      clientId: client.clientId,
      startTime: new Date().toISOString(),
      customerData: data.customerData,
      phoneNumber: data.phoneNumber || data.customerData?.phoneNumber,
      callDirection: data.callDirection || 'outbound',
      status: 'active'
    };
  }

  // Update call session on end
  if (event === 'callEnded') {
    const sessionId = data.callSid || Object.keys(callSessions).find(
      id => callSessions[id].phoneNumber === data.phoneNumber && callSessions[id].status === 'active'
    );
    
    if (sessionId && callSessions[sessionId]) {
      callSessions[sessionId].endTime = new Date().toISOString();
      callSessions[sessionId].duration = data.duration;
      callSessions[sessionId].status = 'completed';
    }
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
app.get('/api/ribbon/config', async (req, res) => {
  const apiKey = req.headers['x-api-key'];

  try {
    const client = await db.clients.getByApiKey(apiKey);
    
    if (!client) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    res.json({
      features: client.features,
      plan: client.plan_type,
      usage: {
        callsThisMonth: client.calls_this_month,
        limit: client.monthly_call_limit,
        remaining: client.monthly_call_limit - client.calls_this_month
      }
    });
  } catch (error) {
    console.error('[API] Config error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
});

/**
 * Get Call Analytics (Admin/Client Dashboard)
 */
app.get('/api/ribbon/analytics', async (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { startDate, endDate, customerId, limit = 100 } = req.query;

  try {
    const client = await db.clients.getByApiKey(apiKey);
    
    if (!client) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    // Get call history from database
    const filters = { startDate, endDate, customerId, limit: parseInt(limit) };
    const callHistory = await db.callSessions.getHistory(client.client_id, filters);

    // Get basic stats
    const stats = await db.analytics.getBasicStats(client.client_id, startDate, endDate);

    // Group calls by date
    const callsByDate = {};
    callHistory.filter(call => call.call_status === 'completed').forEach(call => {
      const date = call.initiated_at.toISOString().split('T')[0];
      callsByDate[date] = (callsByDate[date] || 0) + 1;
    });

    res.json({
      summary: {
        totalCalls: parseInt(stats.total_calls) || 0,
        totalDuration: parseInt(stats.total_duration) || 0,
        avgDuration: parseInt(stats.avg_duration) || 0,
        inboundCalls: parseInt(stats.inbound_calls) || 0,
        outboundCalls: parseInt(stats.outbound_calls) || 0,
        missedCalls: parseInt(stats.missed_calls) || 0
      },
      callsByDate,
      recentCalls: callHistory.slice(0, parseInt(limit)),
      usage: {
        callsThisMonth: client.calls_this_month,
        limit: client.monthly_call_limit,
        remaining: client.monthly_call_limit - client.calls_this_month
      }
    });
  } catch (error) {
    console.error('[API] Analytics error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
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
 * Save/Update Customer Information
 */
app.post('/api/ribbon/customer', async (req, res) => {
  const { apiKey, customerData } = req.body;

  try {
    const client = await db.clients.getByApiKey(apiKey);
    
    if (!client) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    // Save customer to database
    const savedCustomer = await db.customers.upsert(client.client_id, customerData);

    console.log(`[API] Customer saved: ${customerData.name} for ${client.client_name}`);

    res.json({
      success: true,
      customerId: savedCustomer.external_customer_id,
      message: 'Customer information saved'
    });
  } catch (error) {
    console.error('[API] Save customer error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
});

/**
 * Get Customer Information
 */
app.get('/api/ribbon/customer/:customerId', async (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { customerId } = req.params;

  try {
    const client = await db.clients.getByApiKey(apiKey);
    
    if (!client) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    // Get customer from database
    const customer = await db.customers.getById(client.client_id, customerId);

    if (!customer) {
      return res.status(404).json({ error: 'Customer not found' });
    }

    // Get call history for this customer
    const customerCalls = await db.callSessions.getCustomerCalls(client.client_id, customerId, 50);

    res.json({
      customer,
      callHistory: customerCalls,
      totalCalls: customerCalls.length,
      totalDuration: customerCalls.reduce((sum, call) => sum + (parseInt(call.duration) || 0), 0)
    });
  } catch (error) {
    console.error('[API] Get customer error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
});

/**
 * Get All Call Logs with Filters
 */
app.get('/api/ribbon/call-logs', async (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { 
    startDate, 
    endDate, 
    customerId, 
    callDirection,
    page = 1, 
    pageSize = 50 
  } = req.query;

  try {
    const client = await db.clients.getByApiKey(apiKey);
    
    if (!client) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    // Build filters
    const filters = {
      startDate,
      endDate,
      customerId,
      callDirection,
      limit: parseInt(pageSize),
      offset: (parseInt(page) - 1) * parseInt(pageSize)
    };

    // Get logs from database
    const logs = await db.callSessions.getHistory(client.client_id, filters);

    // Get total count (without limit)
    const totalFilters = { startDate, endDate, customerId, callDirection };
    const allLogs = await db.callSessions.getHistory(client.client_id, totalFilters);
    const total = allLogs.length;

    res.json({
      logs,
      pagination: {
        page: parseInt(page),
        pageSize: parseInt(pageSize),
        total,
        totalPages: Math.ceil(total / parseInt(pageSize))
      }
    });
  } catch (error) {
    console.error('[API] Call logs error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
});

/**
 * Get Active Call Sessions
 */
app.get('/api/ribbon/active-calls', async (req, res) => {
  const apiKey = req.headers['x-api-key'];

  try {
    const client = await db.clients.getByApiKey(apiKey);
    
    if (!client) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    const activeCalls = await db.callSessions.getActive(client.client_id);

    res.json({
      activeCalls,
      count: activeCalls.length
    });
  } catch (error) {
    console.error('[API] Active calls error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
});

/**
 * Get Detailed Analytics Report
 */
app.get('/api/ribbon/analytics/detailed', async (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { startDate, endDate } = req.query;

  try {
    const client = await db.clients.getByApiKey(apiKey);
    
    if (!client) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    // Get all analytics data from database
    const [basicStats, callsByHour, callsByDayOfWeek, topCustomers, durationBuckets] = await Promise.all([
      db.analytics.getBasicStats(client.client_id, startDate, endDate),
      db.analytics.getCallsByHour(client.client_id, startDate, endDate),
      db.analytics.getCallsByDayOfWeek(client.client_id, startDate, endDate),
      db.analytics.getTopCustomers(client.client_id, 10, startDate, endDate),
      db.analytics.getDurationBuckets(client.client_id, startDate, endDate)
    ]);

    // Get recent activity
    const recentActivity = await db.callSessions.getHistory(client.client_id, { 
      startDate, 
      endDate, 
      limit: 20,
      callStatus: 'completed'
    });

    res.json({
      summary: {
        totalCalls: parseInt(basicStats.total_calls) || 0,
        totalDuration: parseInt(basicStats.total_duration) || 0,
        avgDuration: parseInt(basicStats.avg_duration) || 0,
        inboundCalls: parseInt(basicStats.inbound_calls) || 0,
        outboundCalls: parseInt(basicStats.outbound_calls) || 0,
        missedCalls: parseInt(basicStats.missed_calls) || 0
      },
      callsByHour,
      callsByDayOfWeek,
      topCustomers,
      durationBuckets,
      recentActivity
    });
  } catch (error) {
    console.error('[API] Detailed analytics error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
});

/**
 * Get Call History for Specific Customer
 */
app.get('/api/ribbon/customer/:customerId/calls', async (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { customerId } = req.params;
  const { limit = 50 } = req.query;

  try {
    const client = await db.clients.getByApiKey(apiKey);
    
    if (!client) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    // Get customer calls from database
    const customerCalls = await db.callSessions.getCustomerCalls(client.client_id, customerId, parseInt(limit));
    
    // Calculate totals
    const totalCalls = customerCalls.length;
    const totalDuration = customerCalls.reduce((sum, call) => sum + (parseInt(call.duration) || 0), 0);

    res.json({
      customerId,
      calls: customerCalls,
      totalCalls,
      totalDuration
    });
  } catch (error) {
    console.error('[API] Customer calls error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
});

/**
 * Export Call Logs (CSV)
 */
app.get('/api/ribbon/export/calls', async (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { startDate, endDate, format = 'json' } = req.query;

  try {
    const client = await db.clients.getByApiKey(apiKey);
    
    if (!client) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    // Get sessions from database
    const filters = { startDate, endDate, callStatus: 'completed' };
    const sessions = await db.callSessions.getHistory(client.client_id, filters);

    if (format === 'csv') {
      // Generate CSV
      const csv = [
        'Session ID,Customer Name,Phone Number,Direction,Start Time,End Time,Duration (s),Customer ID',
        ...sessions.map(s => [
          s.session_id,
          s.customer_name || '',
          s.phone_number,
          s.call_direction,
          s.initiated_at,
          s.ended_at || '',
          s.duration || 0,
          s.customer_id || ''
        ].join(','))
      ].join('\n');

      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename="call-logs-${client.client_id}-${Date.now()}.csv"`);
      res.send(csv);
    } else {
      // JSON format
      res.json({
        client: {
          clientId: client.client_id,
          name: client.client_name
        },
        exportDate: new Date().toISOString(),
        dateRange: { startDate, endDate },
        calls: sessions
      });
    }
  } catch (error) {
    console.error('[API] Export error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
});

/**
 * List Clients (Admin only - add auth in production)
 */
app.get('/api/admin/clients', async (req, res) => {
  // Add admin authentication here
  
  try {
    const allClients = await db.clients.getAll();
    
    const clientList = allClients.map(client => ({
      clientId: client.client_id,
      name: client.client_name,
      plan: client.plan_type,
      callsThisMonth: client.calls_this_month,
      limit: client.monthly_call_limit,
      apiKey: client.api_key.substring(0, 10) + '...' // Masked
    }));

    res.json(clientList);
  } catch (error) {
    console.error('[API] List clients error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
});

/**
 * Admin Dashboard - All Clients Analytics
 */
app.get('/api/admin/analytics/all', async (req, res) => {
  // Add admin authentication here
  
  try {
    const allClients = await db.clients.getAll();
    
    const allStats = await Promise.all(allClients.map(async (client) => {
      const stats = await db.analytics.getBasicStats(client.client_id, null, null);
      
      return {
        clientId: client.client_id,
        clientName: client.client_name,
        plan: client.plan_type,
        totalCalls: parseInt(stats.total_calls) || 0,
        totalDuration: parseInt(stats.total_duration) || 0,
        callsThisMonth: client.calls_this_month,
        limit: client.monthly_call_limit,
        utilizationPercent: Math.round((client.calls_this_month / client.monthly_call_limit) * 100)
      };
    }));

    res.json({
      clients: allStats,
      totalClients: allStats.length,
      totalCallsAllClients: allStats.reduce((sum, c) => sum + c.totalCalls, 0)
    });
  } catch (error) {
    console.error('[API] Admin analytics error:', error);
    res.status(500).json({ error: 'Internal server error', message: error.message });
  }
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
║   Version: 2.0.0                                      ║
║   Port: ${PORT}                                           ║
╚═══════════════════════════════════════════════════════╝

📋 Registered Clients:
${Object.values(clients).map(c => `   - ${c.name} (${c.plan})`).join('\n')}

🔗 Core API Endpoints:
   POST /api/ribbon/init                    - Initialize ribbon
   POST /api/ribbon/log-call                - Log call events
   GET  /api/ribbon/config                  - Get configuration
   GET  /api/ribbon/analytics               - Get analytics
   GET  /health                             - Health check

📞 Call Management:
   GET  /api/ribbon/call-logs               - Get call logs (with filters)
   GET  /api/ribbon/active-calls            - Get active calls
   GET  /api/ribbon/analytics/detailed      - Detailed analytics report
   GET  /api/ribbon/export/calls            - Export calls (CSV/JSON)

👥 Customer Management:
   POST /api/ribbon/customer                - Save/update customer
   GET  /api/ribbon/customer/:id            - Get customer info
   GET  /api/ribbon/customer/:id/calls      - Get customer call history

🔧 Admin Endpoints:
   GET  /api/admin/clients                  - List all clients
   GET  /api/admin/analytics/all            - All clients analytics

🚀 Server is ready!
  `);
});

module.exports = app;
