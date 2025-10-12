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
  const { startDate, endDate, customerId, limit = 100 } = req.query;

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  // Filter logs for this client
  let clientLogs = callLogs.filter(log => log.clientId === client.clientId);

  // Apply date filters
  if (startDate) {
    clientLogs = clientLogs.filter(log => new Date(log.timestamp) >= new Date(startDate));
  }
  if (endDate) {
    clientLogs = clientLogs.filter(log => new Date(log.timestamp) <= new Date(endDate));
  }

  // Apply customer filter
  if (customerId) {
    clientLogs = clientLogs.filter(log => log.data?.customerData?.customerId === customerId);
  }

  // Get completed call sessions for this client
  const completedSessions = Object.values(callSessions).filter(
    session => session.clientId === client.clientId && session.status === 'completed'
  );

  // Calculate total duration
  const totalDuration = completedSessions.reduce((sum, session) => sum + (session.duration || 0), 0);

  // Calculate average duration
  const avgDuration = completedSessions.length > 0 ? Math.round(totalDuration / completedSessions.length) : 0;

  // Group calls by date
  const callsByDate = {};
  clientLogs.filter(log => log.event === 'connected').forEach(log => {
    const date = log.timestamp.split('T')[0];
    callsByDate[date] = (callsByDate[date] || 0) + 1;
  });

  // Calculate statistics
  const stats = {
    totalCalls: clientLogs.filter(log => log.event === 'connected').length,
    totalDuration,
    avgDuration,
    incomingCalls: clientLogs.filter(log => log.event === 'incoming').length,
    outgoingCalls: clientLogs.filter(log => log.event === 'connected' && log.data?.callDirection === 'outbound').length,
    missedCalls: clientLogs.filter(log => log.event === 'callEnded' && log.data?.duration === 0).length,
    callsByDate,
    recentCalls: completedSessions.slice(-parseInt(limit)).reverse(),
    usage: {
      callsThisMonth: client.callsThisMonth,
      limit: client.monthlyCallLimit,
      remaining: client.monthlyCallLimit - client.callsThisMonth
    }
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
 * Save/Update Customer Information
 */
app.post('/api/ribbon/customer', (req, res) => {
  const { apiKey, customerData } = req.body;

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  const customerId = customerData.customerId || `cust-${Date.now()}`;
  const customerKey = `${client.clientId}-${customerId}`;

  // Store/update customer info
  customers[customerKey] = {
    customerId,
    clientId: client.clientId,
    ...customerData,
    lastUpdated: new Date().toISOString(),
    createdAt: customers[customerKey]?.createdAt || new Date().toISOString()
  };

  console.log(`[API] Customer saved: ${customerData.name} for ${client.name}`);

  res.json({
    success: true,
    customerId,
    message: 'Customer information saved'
  });
});

/**
 * Get Customer Information
 */
app.get('/api/ribbon/customer/:customerId', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { customerId } = req.params;

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  const customerKey = `${client.clientId}-${customerId}`;
  const customer = customers[customerKey];

  if (!customer) {
    return res.status(404).json({ error: 'Customer not found' });
  }

  // Get call history for this customer
  const customerCalls = Object.values(callSessions).filter(
    session => session.clientId === client.clientId && 
               session.customerData?.customerId === customerId
  );

  res.json({
    customer,
    callHistory: customerCalls,
    totalCalls: customerCalls.length,
    totalDuration: customerCalls.reduce((sum, call) => sum + (call.duration || 0), 0)
  });
});

/**
 * Get All Call Logs with Filters
 */
app.get('/api/ribbon/call-logs', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { 
    startDate, 
    endDate, 
    customerId, 
    event, 
    callDirection,
    page = 1, 
    pageSize = 50 
  } = req.query;

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  // Filter logs
  let filteredLogs = callLogs.filter(log => log.clientId === client.clientId);

  if (startDate) {
    filteredLogs = filteredLogs.filter(log => new Date(log.timestamp) >= new Date(startDate));
  }
  if (endDate) {
    filteredLogs = filteredLogs.filter(log => new Date(log.timestamp) <= new Date(endDate));
  }
  if (customerId) {
    filteredLogs = filteredLogs.filter(log => log.data?.customerData?.customerId === customerId);
  }
  if (event) {
    filteredLogs = filteredLogs.filter(log => log.event === event);
  }
  if (callDirection) {
    filteredLogs = filteredLogs.filter(log => log.data?.callDirection === callDirection);
  }

  // Pagination
  const total = filteredLogs.length;
  const start = (parseInt(page) - 1) * parseInt(pageSize);
  const end = start + parseInt(pageSize);
  const paginatedLogs = filteredLogs.slice(start, end);

  res.json({
    logs: paginatedLogs,
    pagination: {
      page: parseInt(page),
      pageSize: parseInt(pageSize),
      total,
      totalPages: Math.ceil(total / parseInt(pageSize))
    }
  });
});

/**
 * Get Active Call Sessions
 */
app.get('/api/ribbon/active-calls', (req, res) => {
  const apiKey = req.headers['x-api-key'];

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  const activeCalls = Object.values(callSessions).filter(
    session => session.clientId === client.clientId && session.status === 'active'
  );

  res.json({
    activeCalls,
    count: activeCalls.length
  });
});

/**
 * Get Detailed Analytics Report
 */
app.get('/api/ribbon/analytics/detailed', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { startDate, endDate } = req.query;

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  // Filter logs
  let clientLogs = callLogs.filter(log => log.clientId === client.clientId);
  let clientSessions = Object.values(callSessions).filter(s => s.clientId === client.clientId);

  if (startDate) {
    clientLogs = clientLogs.filter(log => new Date(log.timestamp) >= new Date(startDate));
    clientSessions = clientSessions.filter(s => new Date(s.startTime) >= new Date(startDate));
  }
  if (endDate) {
    clientLogs = clientLogs.filter(log => new Date(log.timestamp) <= new Date(endDate));
    clientSessions = clientSessions.filter(s => new Date(s.startTime) <= new Date(endDate));
  }

  const completedSessions = clientSessions.filter(s => s.status === 'completed');
  
  // Calculate metrics
  const totalCalls = clientLogs.filter(log => log.event === 'connected').length;
  const totalDuration = completedSessions.reduce((sum, s) => sum + (s.duration || 0), 0);
  const avgDuration = totalCalls > 0 ? Math.round(totalDuration / totalCalls) : 0;
  
  // Calls by direction
  const outboundCalls = completedSessions.filter(s => s.callDirection === 'outbound').length;
  const inboundCalls = completedSessions.filter(s => s.callDirection === 'inbound').length;

  // Calls by hour of day
  const callsByHour = {};
  for (let i = 0; i < 24; i++) callsByHour[i] = 0;
  
  completedSessions.forEach(session => {
    const hour = new Date(session.startTime).getHours();
    callsByHour[hour]++;
  });

  // Calls by day of week
  const callsByDayOfWeek = {
    0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0 // Sunday = 0
  };
  
  completedSessions.forEach(session => {
    const day = new Date(session.startTime).getDay();
    callsByDayOfWeek[day]++;
  });

  // Top customers by call count
  const customerCallCounts = {};
  completedSessions.forEach(session => {
    const custId = session.customerData?.customerId || 'unknown';
    const custName = session.customerData?.name || session.phoneNumber;
    
    if (!customerCallCounts[custId]) {
      customerCallCounts[custId] = {
        customerId: custId,
        customerName: custName,
        phoneNumber: session.phoneNumber,
        callCount: 0,
        totalDuration: 0
      };
    }
    
    customerCallCounts[custId].callCount++;
    customerCallCounts[custId].totalDuration += (session.duration || 0);
  });

  const topCustomers = Object.values(customerCallCounts)
    .sort((a, b) => b.callCount - a.callCount)
    .slice(0, 10);

  // Duration distribution
  const durationBuckets = {
    '0-30s': 0,
    '30s-1m': 0,
    '1m-3m': 0,
    '3m-5m': 0,
    '5m+': 0
  };

  completedSessions.forEach(session => {
    const duration = session.duration || 0;
    if (duration < 30) durationBuckets['0-30s']++;
    else if (duration < 60) durationBuckets['30s-1m']++;
    else if (duration < 180) durationBuckets['1m-3m']++;
    else if (duration < 300) durationBuckets['3m-5m']++;
    else durationBuckets['5m+']++;
  });

  res.json({
    summary: {
      totalCalls,
      totalDuration,
      avgDuration,
      inboundCalls,
      outboundCalls,
      missedCalls: clientLogs.filter(log => log.event === 'incoming' && !clientLogs.some(l => l.event === 'connected' && l.data?.phoneNumber === log.data?.phoneNumber)).length
    },
    callsByHour,
    callsByDayOfWeek,
    topCustomers,
    durationBuckets,
    recentActivity: completedSessions.slice(-20).reverse()
  });
});

/**
 * Get Call History for Specific Customer
 */
app.get('/api/ribbon/customer/:customerId/calls', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { customerId } = req.params;
  const { limit = 50 } = req.query;

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  // Get all calls for this customer
  const customerCalls = Object.values(callSessions).filter(
    session => session.clientId === client.clientId && 
               session.customerData?.customerId === customerId
  );

  // Get call events
  const customerEvents = callLogs.filter(
    log => log.clientId === client.clientId && 
           log.data?.customerData?.customerId === customerId
  );

  res.json({
    customerId,
    calls: customerCalls.slice(-parseInt(limit)).reverse(),
    events: customerEvents.slice(-parseInt(limit) * 3).reverse(),
    totalCalls: customerCalls.length,
    totalDuration: customerCalls.reduce((sum, call) => sum + (call.duration || 0), 0)
  });
});

/**
 * Export Call Logs (CSV)
 */
app.get('/api/ribbon/export/calls', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { startDate, endDate, format = 'json' } = req.query;

  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  // Filter sessions
  let sessions = Object.values(callSessions).filter(s => s.clientId === client.clientId && s.status === 'completed');

  if (startDate) {
    sessions = sessions.filter(s => new Date(s.startTime) >= new Date(startDate));
  }
  if (endDate) {
    sessions = sessions.filter(s => new Date(s.startTime) <= new Date(endDate));
  }

  if (format === 'csv') {
    // Generate CSV
    const csv = [
      'Session ID,Customer Name,Phone Number,Direction,Start Time,End Time,Duration (s),Customer ID',
      ...sessions.map(s => [
        s.sessionId,
        s.customerData?.name || '',
        s.phoneNumber,
        s.callDirection,
        s.startTime,
        s.endTime || '',
        s.duration || 0,
        s.customerData?.customerId || ''
      ].join(','))
    ].join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename="call-logs-${client.clientId}-${Date.now()}.csv"`);
    res.send(csv);
  } else {
    // JSON format
    res.json({
      client: {
        clientId: client.clientId,
        name: client.name
      },
      exportDate: new Date().toISOString(),
      dateRange: { startDate, endDate },
      calls: sessions
    });
  }
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

/**
 * Admin Dashboard - All Clients Analytics
 */
app.get('/api/admin/analytics/all', (req, res) => {
  // Add admin authentication here
  
  const allStats = Object.entries(clients).map(([apiKey, client]) => {
    const clientLogs = callLogs.filter(log => log.clientId === client.clientId);
    const clientSessions = Object.values(callSessions).filter(s => s.clientId === client.clientId && s.status === 'completed');
    
    return {
      clientId: client.clientId,
      clientName: client.name,
      plan: client.plan,
      totalCalls: clientLogs.filter(log => log.event === 'connected').length,
      totalDuration: clientSessions.reduce((sum, s) => sum + (s.duration || 0), 0),
      callsThisMonth: client.callsThisMonth,
      limit: client.monthlyCallLimit,
      utilizationPercent: Math.round((client.callsThisMonth / client.monthlyCallLimit) * 100)
    };
  });

  res.json({
    clients: allStats,
    totalClients: allStats.length,
    totalCallsAllClients: allStats.reduce((sum, c) => sum + c.totalCalls, 0)
  });
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
