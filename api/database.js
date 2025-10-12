/**
 * Database Connection Module
 * PostgreSQL connection using pg library
 */

const { Pool } = require('pg');

// Database configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'call_ribbon_db',
  user: process.env.DB_USER || 'call_ribbon_admin',
  password: process.env.DB_PASSWORD,
  
  // Connection pool settings
  max: 20, // Maximum pool size
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
  
  // SSL configuration
  ssl: process.env.DB_SSL === 'true' ? {
    rejectUnauthorized: false // For AWS RDS
  } : false
};

// Create connection pool
const pool = new Pool(dbConfig);

// Test connection
pool.on('connect', () => {
  console.log('[DB] Connected to PostgreSQL');
});

pool.on('error', (err) => {
  console.error('[DB] Unexpected error:', err);
});

// ============================================
// CLIENT QUERIES
// ============================================

const clientQueries = {
  // Get client by API key
  getByApiKey: async (apiKey) => {
    const query = `
      SELECT * FROM clients 
      WHERE api_key = $1 AND status = 'active'
    `;
    const result = await pool.query(query, [apiKey]);
    return result.rows[0];
  },

  // Update client usage
  incrementCallCount: async (clientId) => {
    const query = `
      UPDATE clients 
      SET calls_this_month = calls_this_month + 1,
          last_activity_at = CURRENT_TIMESTAMP
      WHERE client_id = $1
      RETURNING calls_this_month, monthly_call_limit
    `;
    const result = await pool.query(query, [clientId]);
    return result.rows[0];
  },

  // Get all clients
  getAll: async () => {
    const query = 'SELECT * FROM clients ORDER BY created_at DESC';
    const result = await pool.query(query);
    return result.rows;
  }
};

// ============================================
// CUSTOMER QUERIES
// ============================================

const customerQueries = {
  // Create or update customer
  upsert: async (clientId, customerData) => {
    const query = `
      INSERT INTO customers (
        client_id, external_customer_id, full_name, first_name, last_name,
        email, phone_number, company_name, customer_type, segment,
        priority, tags, custom_fields
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      ON CONFLICT (client_id, external_customer_id) 
      DO UPDATE SET
        full_name = EXCLUDED.full_name,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        email = EXCLUDED.email,
        phone_number = EXCLUDED.phone_number,
        company_name = EXCLUDED.company_name,
        customer_type = EXCLUDED.customer_type,
        segment = EXCLUDED.segment,
        priority = EXCLUDED.priority,
        tags = EXCLUDED.tags,
        custom_fields = EXCLUDED.custom_fields,
        updated_at = CURRENT_TIMESTAMP
      RETURNING *
    `;
    
    const values = [
      clientId,
      customerData.customerId || customerData.externalCustomerId,
      customerData.name || customerData.fullName,
      customerData.firstName,
      customerData.lastName,
      customerData.email,
      customerData.phoneNumber || customerData.phone,
      customerData.company || customerData.companyName,
      customerData.customerType || 'customer',
      customerData.segment,
      customerData.priority,
      JSON.stringify(customerData.tags || []),
      JSON.stringify(customerData.customFields || {})
    ];
    
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // Get customer by ID
  getById: async (clientId, customerId) => {
    const query = `
      SELECT * FROM customers 
      WHERE client_id = $1 AND external_customer_id = $2
    `;
    const result = await pool.query(query, [clientId, customerId]);
    return result.rows[0];
  },

  // Get customer by phone
  getByPhone: async (clientId, phoneNumber) => {
    const query = `
      SELECT * FROM customers 
      WHERE client_id = $1 AND phone_number = $2
    `;
    const result = await pool.query(query, [clientId, phoneNumber]);
    return result.rows[0];
  }
};

// ============================================
// CALL SESSION QUERIES
// ============================================

const callSessionQueries = {
  // Create call session
  create: async (sessionData) => {
    const query = `
      INSERT INTO call_sessions (
        client_id, customer_id, exotel_call_sid, phone_number,
        call_direction, call_type, call_status, agent_id, agent_name, metadata
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *
    `;
    
    const values = [
      sessionData.clientId,
      sessionData.customerId,
      sessionData.exotelCallSid,
      sessionData.phoneNumber,
      sessionData.callDirection || 'outbound',
      sessionData.callType,
      'initiated',
      sessionData.agentId,
      sessionData.agentName,
      JSON.stringify(sessionData.metadata || {})
    ];
    
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // Update call session
  update: async (sessionId, updates) => {
    const query = `
      UPDATE call_sessions 
      SET 
        connected_at = COALESCE($2, connected_at),
        ended_at = COALESCE($3, ended_at),
        duration = COALESCE($4, duration),
        call_status = COALESCE($5, call_status),
        end_reason = COALESCE($6, end_reason),
        updated_at = CURRENT_TIMESTAMP
      WHERE session_id = $1
      RETURNING *
    `;
    
    const values = [
      sessionId,
      updates.connectedAt,
      updates.endedAt,
      updates.duration,
      updates.callStatus,
      updates.endReason
    ];
    
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // Get active sessions
  getActive: async (clientId) => {
    const query = `
      SELECT cs.*, c.full_name as customer_name, c.email as customer_email
      FROM call_sessions cs
      LEFT JOIN customers c ON cs.customer_id = c.customer_id
      WHERE cs.client_id = $1 AND cs.call_status = 'connected'
      ORDER BY cs.connected_at DESC
    `;
    const result = await pool.query(query, [clientId]);
    return result.rows;
  },

  // Get call history with filters
  getHistory: async (clientId, filters = {}) => {
    let query = `
      SELECT cs.*, c.full_name as customer_name, c.email as customer_email
      FROM call_sessions cs
      LEFT JOIN customers c ON cs.customer_id = c.customer_id
      WHERE cs.client_id = $1
    `;
    
    const params = [clientId];
    let paramIndex = 2;
    
    if (filters.startDate) {
      query += ` AND cs.initiated_at >= $${paramIndex}`;
      params.push(filters.startDate);
      paramIndex++;
    }
    
    if (filters.endDate) {
      query += ` AND cs.initiated_at <= $${paramIndex}`;
      params.push(filters.endDate);
      paramIndex++;
    }
    
    if (filters.customerId) {
      query += ` AND c.external_customer_id = $${paramIndex}`;
      params.push(filters.customerId);
      paramIndex++;
    }
    
    if (filters.callDirection) {
      query += ` AND cs.call_direction = $${paramIndex}`;
      params.push(filters.callDirection);
      paramIndex++;
    }
    
    if (filters.callStatus) {
      query += ` AND cs.call_status = $${paramIndex}`;
      params.push(filters.callStatus);
      paramIndex++;
    }
    
    query += ` ORDER BY cs.initiated_at DESC`;
    
    if (filters.limit) {
      query += ` LIMIT $${paramIndex}`;
      params.push(filters.limit);
      paramIndex++;
    }
    
    if (filters.offset) {
      query += ` OFFSET $${paramIndex}`;
      params.push(filters.offset);
    }
    
    const result = await pool.query(query, params);
    return result.rows;
  },

  // Get customer call history
  getCustomerCalls: async (clientId, customerId, limit = 50) => {
    const query = `
      SELECT cs.*, c.full_name as customer_name
      FROM call_sessions cs
      LEFT JOIN customers c ON cs.customer_id = c.customer_id
      WHERE cs.client_id = $1 AND c.external_customer_id = $2
      ORDER BY cs.initiated_at DESC
      LIMIT $3
    `;
    const result = await pool.query(query, [clientId, customerId, limit]);
    return result.rows;
  }
};

// ============================================
// CALL EVENT QUERIES
// ============================================

const callEventQueries = {
  // Log event
  create: async (eventData) => {
    const query = `
      INSERT INTO call_events (
        session_id, client_id, event_type, event_data,
        source, domain, ip_address, metadata
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *
    `;
    
    const values = [
      eventData.sessionId,
      eventData.clientId,
      eventData.eventType,
      JSON.stringify(eventData.eventData || {}),
      eventData.source || 'widget',
      eventData.domain,
      eventData.ipAddress,
      JSON.stringify(eventData.metadata || {})
    ];
    
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // Get events for session
  getBySession: async (sessionId) => {
    const query = `
      SELECT * FROM call_events 
      WHERE session_id = $1 
      ORDER BY event_timestamp ASC
    `;
    const result = await pool.query(query, [sessionId]);
    return result.rows;
  }
};

// ============================================
// ANALYTICS QUERIES
// ============================================

const analyticsQueries = {
  // Get basic analytics
  getBasicStats: async (clientId, startDate, endDate) => {
    const query = `
      SELECT 
        COUNT(*) FILTER (WHERE call_status = 'completed') as total_calls,
        SUM(duration) FILTER (WHERE call_status = 'completed') as total_duration,
        AVG(duration) FILTER (WHERE call_status = 'completed') as avg_duration,
        COUNT(*) FILTER (WHERE call_direction = 'inbound') as inbound_calls,
        COUNT(*) FILTER (WHERE call_direction = 'outbound') as outbound_calls,
        COUNT(*) FILTER (WHERE call_status = 'missed') as missed_calls,
        COUNT(DISTINCT customer_id) as unique_customers
      FROM call_sessions
      WHERE client_id = $1
        AND ($2::timestamp IS NULL OR initiated_at >= $2)
        AND ($3::timestamp IS NULL OR initiated_at <= $3)
    `;
    
    const result = await pool.query(query, [clientId, startDate, endDate]);
    return result.rows[0];
  },

  // Get calls by hour
  getCallsByHour: async (clientId, startDate, endDate) => {
    const query = `
      SELECT 
        EXTRACT(HOUR FROM initiated_at) as hour,
        COUNT(*) as call_count
      FROM call_sessions
      WHERE client_id = $1
        AND ($2::timestamp IS NULL OR initiated_at >= $2)
        AND ($3::timestamp IS NULL OR initiated_at <= $3)
      GROUP BY EXTRACT(HOUR FROM initiated_at)
      ORDER BY hour
    `;
    
    const result = await pool.query(query, [clientId, startDate, endDate]);
    
    // Convert to object
    const byHour = {};
    for (let i = 0; i < 24; i++) byHour[i] = 0;
    result.rows.forEach(row => {
      byHour[row.hour] = parseInt(row.call_count);
    });
    
    return byHour;
  },

  // Get calls by day of week
  getCallsByDayOfWeek: async (clientId, startDate, endDate) => {
    const query = `
      SELECT 
        EXTRACT(DOW FROM initiated_at) as day_of_week,
        COUNT(*) as call_count
      FROM call_sessions
      WHERE client_id = $1
        AND ($2::timestamp IS NULL OR initiated_at >= $2)
        AND ($3::timestamp IS NULL OR initiated_at <= $3)
      GROUP BY EXTRACT(DOW FROM initiated_at)
      ORDER BY day_of_week
    `;
    
    const result = await pool.query(query, [clientId, startDate, endDate]);
    
    // Convert to object (0=Sunday, 6=Saturday)
    const byDay = { 0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0 };
    result.rows.forEach(row => {
      byDay[row.day_of_week] = parseInt(row.call_count);
    });
    
    return byDay;
  },

  // Get top customers
  getTopCustomers: async (clientId, limit = 10, startDate, endDate) => {
    const query = `
      SELECT 
        c.external_customer_id as customer_id,
        c.full_name as customer_name,
        c.phone_number,
        COUNT(cs.session_id) as call_count,
        SUM(cs.duration) as total_duration
      FROM customers c
      INNER JOIN call_sessions cs ON c.customer_id = cs.customer_id
      WHERE c.client_id = $1
        AND ($2::timestamp IS NULL OR cs.initiated_at >= $2)
        AND ($3::timestamp IS NULL OR cs.initiated_at <= $3)
        AND cs.call_status = 'completed'
      GROUP BY c.customer_id, c.external_customer_id, c.full_name, c.phone_number
      ORDER BY call_count DESC
      LIMIT $4
    `;
    
    const result = await pool.query(query, [clientId, startDate, endDate, limit]);
    return result.rows;
  },

  // Get duration distribution
  getDurationBuckets: async (clientId, startDate, endDate) => {
    const query = `
      SELECT 
        COUNT(*) FILTER (WHERE duration < 30) as "0-30s",
        COUNT(*) FILTER (WHERE duration >= 30 AND duration < 60) as "30s-1m",
        COUNT(*) FILTER (WHERE duration >= 60 AND duration < 180) as "1m-3m",
        COUNT(*) FILTER (WHERE duration >= 180 AND duration < 300) as "3m-5m",
        COUNT(*) FILTER (WHERE duration >= 300) as "5m+"
      FROM call_sessions
      WHERE client_id = $1
        AND call_status = 'completed'
        AND ($2::timestamp IS NULL OR initiated_at >= $2)
        AND ($3::timestamp IS NULL OR initiated_at <= $3)
    `;
    
    const result = await pool.query(query, [clientId, startDate, endDate]);
    return result.rows[0];
  }
};

// ============================================
// CALL NOTE QUERIES
// ============================================

const callNoteQueries = {
  // Add note to call
  create: async (sessionId, clientId, noteData) => {
    const query = `
      INSERT INTO call_notes (
        session_id, client_id, customer_id, note_text,
        note_type, created_by, is_internal
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;
    
    const values = [
      sessionId,
      clientId,
      noteData.customerId,
      noteData.noteText,
      noteData.noteType || 'general',
      noteData.createdBy,
      noteData.isInternal || false
    ];
    
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // Get notes for session
  getBySession: async (sessionId) => {
    const query = `
      SELECT * FROM call_notes 
      WHERE session_id = $1 
      ORDER BY created_at DESC
    `;
    const result = await pool.query(query, [sessionId]);
    return result.rows;
  }
};

// ============================================
// USAGE TRACKING QUERIES
// ============================================

const usageQueries = {
  // Track daily usage
  trackDaily: async (clientId, usageData) => {
    const query = `
      INSERT INTO usage_tracking (
        client_id, usage_date, usage_month, api_calls_total, call_minutes
      ) VALUES ($1, CURRENT_DATE, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), $2, $3)
      ON CONFLICT (client_id, usage_date)
      DO UPDATE SET
        api_calls_total = usage_tracking.api_calls_total + EXCLUDED.api_calls_total,
        call_minutes = usage_tracking.call_minutes + EXCLUDED.call_minutes,
        updated_at = CURRENT_TIMESTAMP
      RETURNING *
    `;
    
    const values = [clientId, usageData.apiCalls || 1, usageData.callMinutes || 0];
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // Get monthly usage
  getMonthlyUsage: async (clientId, month) => {
    const query = `
      SELECT 
        SUM(api_calls_total) as total_api_calls,
        SUM(call_minutes) as total_call_minutes
      FROM usage_tracking
      WHERE client_id = $1 AND usage_month = $2
    `;
    const result = await pool.query(query, [clientId, month]);
    return result.rows[0];
  }
};

// ============================================
// EXPORT MODULE
// ============================================

module.exports = {
  pool,
  query: (text, params) => pool.query(text, params),
  
  // Query objects
  clients: clientQueries,
  customers: customerQueries,
  callSessions: callSessionQueries,
  callEvents: callEventQueries,
  callNotes: callNoteQueries,
  usage: usageQueries,
  
  // Utility functions
  beginTransaction: async () => {
    const client = await pool.connect();
    await client.query('BEGIN');
    return client;
  },
  
  commitTransaction: async (client) => {
    await client.query('COMMIT');
    client.release();
  },
  
  rollbackTransaction: async (client) => {
    await client.query('ROLLBACK');
    client.release();
  },
  
  // Close pool
  close: () => pool.end()
};

