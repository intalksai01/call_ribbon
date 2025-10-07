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
    exotelToken: '9875596a6e1be7bfaa865f43a028ec40f980e57fdeb4de8c',
    exotelUserId: 'f6e23a8c3ce28cda4a76bce715dd714e1d138183f58179df',
    features: ['call', 'mute', 'hold', 'dtmf'],
    allowedDomains: ['*'],
    plan: 'demo',
    monthlyCallLimit: 100,
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
  const { apiKey, domain } = req.body;

  console.log('[Ribbon Init]', { apiKey, domain });

  // Validate API key
  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({
      error: 'Invalid API key',
      message: 'Please check your API key and try again'
    });
  }

  // Check domain whitelist
  const isAllowedDomain = client.allowedDomains.includes('*') || 
                          client.allowedDomains.includes(domain) ||
                          domain === 'localhost';

  if (!isAllowedDomain) {
    return res.status(403).json({
      error: 'Domain not allowed',
      message: `Domain ${domain} is not whitelisted for this API key`
    });
  }

  // Check call limits
  if (client.callsThisMonth >= client.monthlyCallLimit) {
    return res.status(429).json({
      error: 'Call limit exceeded',
      message: `Monthly limit of ${client.monthlyCallLimit} calls reached`
    });
  }

  // Return Exotel credentials
  res.json({
    exotelToken: client.exotelToken,
    userId: client.exotelUserId,
    clientId: client.clientId,
    features: client.features,
    plan: client.plan,
    callsRemaining: client.monthlyCallLimit - client.callsThisMonth
  });
});

/**
 * Log call events
 */
app.post('/api/ribbon/log-call', (req, res) => {
  const { apiKey, event, data, timestamp, domain } = req.body;

  console.log('[Call Event]', { apiKey, event, timestamp });

  // Validate API key
  const client = clients[apiKey];
  if (!client) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  // Increment call counter for certain events
  if (event === 'connected') {
    client.callsThisMonth++;
  }

  // In production, save to database
  // await db.callLogs.insert({ clientId: client.clientId, event, data, timestamp });

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
