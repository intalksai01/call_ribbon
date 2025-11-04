/**
 * Unified Server - Serves both Widget and API
 * 
 * This single server handles:
 * - Widget files (static HTML/CSS/JS)
 * - API endpoints (authentication, logging)
 * 
 * Deploy this to a single platform (Heroku, Railway, etc.)
 */

const express = require('express');
const cors = require('cors');
const path = require('path');
const app = express();

// Middleware
app.use(express.json());
app.use(cors({
  origin: '*', // Configure properly in production
  methods: ['POST', 'GET']
}));

// ============================================
// SERVE WIDGET (Static Files)
// ============================================

// Serve widget build files
const widgetPath = path.join(__dirname, '../widget/build');
app.use(express.static(widgetPath));

// ============================================
// CLIENT DATABASE
// ============================================

const clients = {
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
  'demo-api-key-789': {
    clientId: 'client-003',
    name: 'Demo Client',
    exotelToken: 'demo-token-12345',
    exotelUserId: 'demo-user-12345',
    features: ['call', 'mute', 'hold', 'dtmf'],
    allowedDomains: ['*'],
    plan: 'demo',
    monthlyCallLimit: 100,
    callsThisMonth: 0
  },

  // Real Exotel credentials
  'real-exotel-api-key': {
    clientId: 'client-real',
    name: 'Real Exotel Client-SIF',
    exotelToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImM5ODIwZTA4LWM0YjktNDY1Yy05YWYyLTBmNzIxN2IwNmU3NSIsImV4cCI6MTc2OTg4NTczMH0.3SMgQta_slHFVZbdFEEzFcbt0DZ15TcqpwkRt7z8WOw',
    exotelUserId: 'laksh',
    virtualNumber: '08044318948',
    features: ['call', 'mute', 'hold', 'dtmf', 'transfer'],
    allowedDomains: ['*'],
    plan: 'professional',
    monthlyCallLimit: 5000,
    callsThisMonth: 0
  },
  
  // Also add to demo key for quick testing
  'demo-api-key-999': {
    clientId: 'client-real-test',
    name: 'Real Exotel Test Client',
    exotelToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImM5ODIwZTA4LWM0YjktNDY1Yy05YWYyLTBmNzIxN2IwNmU3NSIsImV4cCI6MTc2OTg4NTczMH0.3SMgQta_slHFVZbdFEEzFcbt0DZ15TcqpwkRt7z8WOw',
    exotelUserId: 'laksh',
    virtualNumber: '08044318948',
    features: ['call', 'mute', 'hold', 'dtmf', 'transfer'],
    allowedDomains: ['*'],
    plan: 'professional',
    monthlyCallLimit: 5000,
    callsThisMonth: 0
  }
};

// ============================================
// API ENDPOINTS
// ============================================

/**
 * Initialize ribbon - Get Exotel credentials
 */
app.post('/api/ribbon/init', (req, res) => {
  const { apiKey, domain, agentUserId, clientName } = req.body;

  console.log('====================================================================');
  console.log('[Ribbon Init] Request received');
  console.log('====================================================================');
  console.log('[Ribbon Init] API Key:', apiKey);
  console.log('[Ribbon Init] Domain:', domain);
  console.log('[Ribbon Init] Agent User ID:', agentUserId || 'Not provided');
  console.log('[Ribbon Init] Client Name:', clientName || 'Not provided');
  console.log('[Ribbon Init] Timestamp:', new Date().toISOString());

  // Validate API key
  const client = clients[apiKey];
  if (!client) {
    console.error('[Ribbon Init] ❌ Invalid API key');
    return res.status(401).json({
      error: 'Invalid API key',
      message: 'Please check your API key and try again'
    });
  }

  console.log('[Ribbon Init] ✅ Valid API key');
  console.log('[Ribbon Init] Client:', client.name);
  console.log('[Ribbon Init] Exotel Token:', client.exotelToken.substring(0, 20) + '...');
  console.log('[Ribbon Init] Exotel User ID:', client.exotelUserId);

  // Check domain whitelist
  const isAllowedDomain = client.allowedDomains.includes('*') || 
                          client.allowedDomains.includes(domain) ||
                          domain === 'localhost';

  if (!isAllowedDomain) {
    console.error('[Ribbon Init] ❌ Domain not allowed:', domain);
    return res.status(403).json({
      error: 'Domain not allowed',
      message: `Domain ${domain} is not whitelisted for this API key`
    });
  }

  console.log('[Ribbon Init] ✅ Domain allowed');

  // Check call limits
  if (client.callsThisMonth >= client.monthlyCallLimit) {
    console.error('[Ribbon Init] ❌ Call limit exceeded');
    return res.status(429).json({
      error: 'Call limit exceeded',
      message: `Monthly limit of ${client.monthlyCallLimit} calls reached`
    });
  }

  console.log('[Ribbon Init] ✅ Call limits OK');
  console.log('[Ribbon Init] Returning credentials to client');
  console.log('====================================================================');

  // Return Exotel credentials
  res.json({
    exotelToken: client.exotelToken,
    userId: client.exotelUserId,
    clientId: client.clientId,
    features: client.features,
    plan: client.plan,
    callsRemaining: client.monthlyCallLimit - client.callsThisMonth,
    virtualNumber: client.virtualNumber || null
  });
});

/**
 * Log call events
 */
app.post('/api/ribbon/log-call', (req, res) => {
  const { apiKey, event, data, timestamp, domain, agentUserId, clientName } = req.body;

  console.log('====================================================================');
  console.log('[Call Event] Logging event');
  console.log('====================================================================');
  console.log('[Call Event] API Key:', apiKey);
  console.log('[Call Event] Agent User ID:', agentUserId || 'Not provided');
  console.log('[Call Event] Client Name:', clientName || 'Not provided');
  console.log('[Call Event] Event:', event);
  console.log('[Call Event] Timestamp:', timestamp);
  console.log('[Call Event] Data:', JSON.stringify(data, null, 2));

  // Validate API key
  const client = clients[apiKey];
  if (!client) {
    console.error('[Call Event] ❌ Invalid API key');
    return res.status(401).json({ error: 'Invalid API key' });
  }

  console.log('[Call Event] ✅ Valid client:', client.name);

  // Increment call counter for certain events
  if (event === 'connected') {
    client.callsThisMonth++;
    console.log('[Call Event] 📞 Call connected! Total this month:', client.callsThisMonth);
  }

  // In production, save to database
  // await db.callLogs.insert({ 
  //   clientId: client.clientId, 
  //   event, 
  //   data, 
  //   timestamp,
  //   agentUserId: agentUserId || null,
  //   clientName: clientName || null,
  //   domain: domain || null
  // });

  console.log('[Call Event] ✅ Event logged successfully');
  console.log('====================================================================');

  res.json({
    success: true,
    callsThisMonth: client.callsThisMonth,
    callsRemaining: client.monthlyCallLimit - client.callsThisMonth
  });
});

/**
 * Health check endpoint
 */
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

/**
 * Get client stats (for admin dashboard)
 */
app.get('/api/admin/stats', (req, res) => {
  const stats = Object.values(clients).map(client => ({
    clientId: client.clientId,
    name: client.name,
    plan: client.plan,
    callsThisMonth: client.callsThisMonth,
    callsRemaining: client.monthlyCallLimit - client.callsThisMonth,
    utilizationPercent: Math.round((client.callsThisMonth / client.monthlyCallLimit) * 100)
  }));

  res.json({ stats });
});

// ============================================
// CUSTOMER-FACING ANALYTICS ENDPOINTS
// ============================================

/**
 * Get call logs
 */
app.get('/api/ribbon/call-logs', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  
  console.log('[Call Logs] Request received');
  console.log('[Call Logs] API Key:', apiKey);
  
  // Validate API key
  const client = clients[apiKey];
  if (!client) {
    console.error('[Call Logs] ❌ Invalid API key');
    return res.status(401).json({
      error: 'Invalid API key',
      message: 'Please check your API key and try again'
    });
  }
  
  const { page = 1, pageSize = 50, customerId, callDirection, startDate, endDate } = req.query;
  
  console.log('[Call Logs] ✅ Valid client:', client.name);
  console.log('[Call Logs] Filters:', { page, pageSize, customerId, callDirection });
  
  // In production, fetch from database
  // For now, return mock data
  const logs = [
    {
      session_id: 'session-' + Date.now(),
      customer_name: 'Rajesh Kumar',
      customer_phone: '+919876543210',
      customer_id_external: 'LOAN001',
      customer_context: {
        loanType: 'Business Loan',
        outstandingBalance: 150000
      },
      call_type: 'collections',
      call_status: 'completed',
      duration: 270,
      initiated_at: new Date().toISOString(),
      connected_at: new Date(Date.now() + 10000).toISOString(),
      ended_at: new Date(Date.now() + 300000).toISOString(),
      agent_name: 'Test Agent',
      metadata: {
        campaign: 'overdue_45days'
      }
    }
  ];
  
  res.json({
    logs: logs.slice((page - 1) * pageSize, page * pageSize),
    pagination: {
      page: parseInt(page),
      pageSize: parseInt(pageSize),
      total: logs.length,
      totalPages: Math.ceil(logs.length / pageSize)
    }
  });
});

/**
 * Get customer call history
 */
app.get('/api/ribbon/customer/:customerId/calls', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { customerId } = req.params;
  const { limit = 50 } = req.query;
  
  console.log('[Customer Calls] Request received');
  console.log('[Customer Calls] Customer ID:', customerId);
  
  // Validate API key
  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }
  
  // Mock data
  const calls = [
    {
      session_id: 'session-' + Date.now(),
      customer_name: 'Rajesh Kumar',
      customer_phone: '+919876543210',
      call_status: 'completed',
      duration: 270,
      initiated_at: new Date().toISOString(),
      agent_name: 'Test Agent'
    }
  ];
  
  res.json({
    customerId,
    calls,
    totalCalls: calls.length,
    totalDuration: calls.reduce((sum, call) => sum + call.duration, 0)
  });
});

/**
 * Get analytics summary
 */
app.get('/api/ribbon/analytics', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  
  console.log('[Analytics] Request received');
  
  // Validate API key
  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }
  
  console.log('[Analytics] ✅ Valid client:', client.name);
  
  // Mock analytics
  const analytics = {
    summary: {
      totalCalls: client.callsThisMonth || 0,
      totalDuration: 0,
      avgDuration: 0,
      inboundCalls: 0,
      outboundCalls: client.callsThisMonth || 0,
      missedCalls: 0
    },
    callsByDate: {},
    recentCalls: [],
    usage: {
      callsThisMonth: client.callsThisMonth,
      limit: client.monthlyCallLimit,
      remaining: client.monthlyCallLimit - client.callsThisMonth
    }
  };
  
  res.json(analytics);
});

/**
 * Get detailed analytics
 */
app.get('/api/ribbon/analytics/detailed', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  
  console.log('[Detailed Analytics] Request received');
  
  // Validate API key
  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }
  
  // Mock detailed analytics
  const detailed = {
    summary: {
      totalCalls: client.callsThisMonth || 0,
      totalDuration: 0,
      avgDuration: 0,
      inboundCalls: 0,
      outboundCalls: client.callsThisMonth || 0,
      missedCalls: 0
    },
    callsByHour: {},
    callsByDayOfWeek: {},
    topCustomers: [],
    durationBuckets: {
      '0-30s': 0,
      '30s-2m': 0,
      '2m-5m': 0,
      '5m-10m': 0,
      '10m+': 0
    }
  };
  
  res.json(detailed);
});

/**
 * Export call data
 */
app.get('/api/ribbon/export/calls', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  const { format = 'json' } = req.query;
  
  console.log('[Export Calls] Request received');
  console.log('[Export Calls] Format:', format);
  
  // Validate API key
  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }
  
  // Mock export data
  const exportData = [
    {
      session_id: 'session-' + Date.now(),
      customer_name: 'Rajesh Kumar',
      customer_phone: '+919876543210',
      duration: 270,
      initiated_at: new Date().toISOString()
    }
  ];
  
  if (format === 'csv') {
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="calls-export.csv"');
    // Return CSV format
    res.send('Session ID,Customer Name,Phone,Duration,Initiated At\n' +
      exportData.map(row => `${row.session_id},${row.customer_name},${row.customer_phone},${row.duration},${row.initiated_at}`).join('\n'));
  } else {
    res.json({ calls: exportData });
  }
});

// ============================================
// SERVE WIDGET FOR ALL OTHER ROUTES
// ============================================

// Serve index.html for all non-API routes
app.get('*', (req, res) => {
  res.sendFile(path.join(widgetPath, 'index.html'));
});

// ============================================
// START SERVER
// ============================================

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log('');
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║                                                            ║');
  console.log('║        🚀 IntalksAI Call Ribbon - Unified Server         ║');
  console.log('║                                                            ║');
  console.log('╚════════════════════════════════════════════════════════════╝');
  console.log('');
  console.log(`✅ Server running on: http://localhost:${PORT}`);
  console.log('');
  console.log('📱 Widget Demo:  http://localhost:' + PORT);
  console.log('🔧 API Health:   http://localhost:' + PORT + '/api/health');
  console.log('📊 Admin Stats:  http://localhost:' + PORT + '/api/admin/stats');
  console.log('');
  console.log('Ready to accept calls! 📞');
  console.log('');
});

module.exports = app;
