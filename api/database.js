// ============================================
// Database Module - Simplified Schema
// PostgreSQL RDS Connection
// ============================================

const { Pool } = require('pg');
require('dotenv').config();

// Connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  },
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test connection
pool.on('connect', () => {
  console.log('✅ Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('❌ Unexpected database error:', err);
});

// ============================================
// CLIENTS
// ============================================

const clients = {
  // Get client by API key
  async getByApiKey(apiKey) {
    const query = 'SELECT * FROM clients WHERE api_key = $1 AND status = $2';
    const result = await pool.query(query, [apiKey, 'active']);
    return result.rows[0];
  },

  // Get all clients
  async getAll() {
    const query = 'SELECT * FROM clients ORDER BY created_at DESC';
    const result = await pool.query(query);
    return result.rows;
  },

  // Update client usage
  async incrementCallCount(clientId) {
    const query = `
      UPDATE clients 
      SET calls_this_month = calls_this_month + 1,
          updated_at = CURRENT_TIMESTAMP
      WHERE client_id = $1
      RETURNING calls_this_month, monthly_call_limit
    `;
    const result = await pool.query(query, [clientId]);
    return result.rows[0];
  }
};

// ============================================
// CALL SESSIONS
// ============================================

const callSessions = {
  // Create new call session
  async create(sessionData) {
    const query = `
      INSERT INTO call_sessions (
        client_id,
        exotel_call_sid,
        customer_name,
        customer_phone,
        customer_id_external,
        customer_context,
        call_direction,
        call_type,
        initiated_at,
        call_status,
        agent_id,
        agent_name,
        metadata
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      RETURNING *
    `;
    
    const values = [
      sessionData.clientId,
      sessionData.exotelCallSid,
      sessionData.customerName,
      sessionData.customerPhone,
      sessionData.customerIdExternal,
      JSON.stringify(sessionData.customerContext || {}),
      sessionData.callDirection || 'outbound',
      sessionData.callType,
      sessionData.initiatedAt || new Date(),
      sessionData.callStatus || 'initiated',
      sessionData.agentId,
      sessionData.agentName,
      JSON.stringify(sessionData.metadata || {})
    ];
    
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // Update call session
  async update(sessionId, updates) {
    const setClauses = [];
    const values = [];
    let paramCount = 1;

    if (updates.connectedAt !== undefined) {
      setClauses.push(`connected_at = $${paramCount++}`);
      values.push(updates.connectedAt);
    }
    if (updates.endedAt !== undefined) {
      setClauses.push(`ended_at = $${paramCount++}`);
      values.push(updates.endedAt);
    }
    if (updates.duration !== undefined) {
      setClauses.push(`duration = $${paramCount++}`);
      values.push(updates.duration);
    }
    if (updates.callStatus !== undefined) {
      setClauses.push(`call_status = $${paramCount++}`);
      values.push(updates.callStatus);
    }
    if (updates.endReason !== undefined) {
      setClauses.push(`end_reason = $${paramCount++}`);
      values.push(updates.endReason);
    }

    if (setClauses.length === 0) return null;

    values.push(sessionId);
    const query = `
      UPDATE call_sessions 
      SET ${setClauses.join(', ')}
      WHERE session_id = $${paramCount}
      RETURNING *
    `;

    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // Get call session by ID
  async getById(sessionId) {
    const query = 'SELECT * FROM call_sessions WHERE session_id = $1';
    const result = await pool.query(query, [sessionId]);
    return result.rows[0];
  },

  // Get call history with filters
  async getHistory(clientId, filters = {}) {
    let query = `
      SELECT * FROM call_sessions 
      WHERE client_id = $1
    `;
    const values = [clientId];
    let paramCount = 2;

    if (filters.startDate) {
      query += ` AND initiated_at >= $${paramCount++}`;
      values.push(filters.startDate);
    }
    if (filters.endDate) {
      query += ` AND initiated_at <= $${paramCount++}`;
      values.push(filters.endDate);
    }
    if (filters.customerIdExternal) {
      query += ` AND customer_id_external = $${paramCount++}`;
      values.push(filters.customerIdExternal);
    }
    if (filters.callDirection) {
      query += ` AND call_direction = $${paramCount++}`;
      values.push(filters.callDirection);
    }
    if (filters.callStatus) {
      query += ` AND call_status = $${paramCount++}`;
      values.push(filters.callStatus);
    }

    query += ' ORDER BY initiated_at DESC';

    if (filters.limit) {
      query += ` LIMIT $${paramCount++}`;
      values.push(filters.limit);
    }
    if (filters.offset) {
      query += ` OFFSET $${paramCount++}`;
      values.push(filters.offset);
    }

    const result = await pool.query(query, values);
    return result.rows;
  },

  // Get customer calls
  async getCustomerCalls(clientId, customerIdExternal, limit = 50) {
    const query = `
      SELECT * FROM call_sessions 
      WHERE client_id = $1 AND customer_id_external = $2
      ORDER BY initiated_at DESC
      LIMIT $3
    `;
    const result = await pool.query(query, [clientId, customerIdExternal, limit]);
    return result.rows;
  },

  // Get active calls
  async getActive(clientId) {
    const query = `
      SELECT * FROM call_sessions 
      WHERE client_id = $1 AND call_status IN ('initiated', 'ringing', 'connected')
      ORDER BY initiated_at DESC
    `;
    const result = await pool.query(query, [clientId]);
    return result.rows;
  }
};

// ============================================
// CALL EVENTS
// ============================================

const callEvents = {
  // Log event
  async log(sessionId, eventType, eventData = {}) {
    const query = `
      INSERT INTO call_events (session_id, event_type, event_data)
      VALUES ($1, $2, $3)
      RETURNING *
    `;
    const result = await pool.query(query, [sessionId, eventType, JSON.stringify(eventData)]);
    return result.rows[0];
  },

  // Get events for session
  async getBySession(sessionId) {
    const query = `
      SELECT * FROM call_events 
      WHERE session_id = $1 
      ORDER BY created_at ASC
    `;
    const result = await pool.query(query, [sessionId]);
    return result.rows;
  }
};

// ============================================
// CALL NOTES
// ============================================

const callNotes = {
  // Add note
  async add(noteData) {
    const query = `
      INSERT INTO call_notes (session_id, note_text, note_type, agent_id, agent_name)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `;
    const values = [
      noteData.sessionId,
      noteData.noteText,
      noteData.noteType || 'after_call',
      noteData.agentId,
      noteData.agentName
    ];
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // Get notes for session
  async getBySession(sessionId) {
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
// USAGE TRACKING
// ============================================

const usageTracking = {
  // Update daily usage
  async updateDaily(clientId, callDuration = 0) {
    const query = `
      INSERT INTO usage_tracking (client_id, usage_date, call_count, total_duration)
      VALUES ($1, CURRENT_DATE, 1, $2)
      ON CONFLICT (client_id, usage_date)
      DO UPDATE SET 
        call_count = usage_tracking.call_count + 1,
        total_duration = usage_tracking.total_duration + $2
      RETURNING *
    `;
    const result = await pool.query(query, [clientId, callDuration]);
    return result.rows[0];
  },

  // Get usage for date range
  async getByDateRange(clientId, startDate, endDate) {
    const query = `
      SELECT * FROM usage_tracking 
      WHERE client_id = $1 
        AND usage_date >= $2 
        AND usage_date <= $3
      ORDER BY usage_date DESC
    `;
    const result = await pool.query(query, [clientId, startDate, endDate]);
    return result.rows;
  }
};

// ============================================
// ANALYTICS
// ============================================

const analytics = {
  // Get basic stats
  async getBasicStats(clientId, startDate, endDate) {
    let query = `
      SELECT 
        COUNT(*) as total_calls,
        COUNT(*) FILTER (WHERE call_status = 'completed') as completed_calls,
        COUNT(*) FILTER (WHERE call_status = 'missed') as missed_calls,
        COUNT(*) FILTER (WHERE call_direction = 'inbound') as inbound_calls,
        COUNT(*) FILTER (WHERE call_direction = 'outbound') as outbound_calls,
        COALESCE(SUM(duration), 0) as total_duration,
        COALESCE(AVG(duration), 0) as avg_duration
      FROM call_sessions
      WHERE client_id = $1
    `;
    
    const values = [clientId];
    let paramCount = 2;

    if (startDate) {
      query += ` AND initiated_at >= $${paramCount++}`;
      values.push(startDate);
    }
    if (endDate) {
      query += ` AND initiated_at <= $${paramCount++}`;
      values.push(endDate);
    }

    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // Get calls by hour
  async getCallsByHour(clientId, startDate, endDate) {
    let query = `
      SELECT 
        EXTRACT(HOUR FROM initiated_at) as hour,
        COUNT(*) as call_count
      FROM call_sessions
      WHERE client_id = $1
    `;
    
    const values = [clientId];
    let paramCount = 2;

    if (startDate) {
      query += ` AND initiated_at >= $${paramCount++}`;
      values.push(startDate);
    }
    if (endDate) {
      query += ` AND initiated_at <= $${paramCount++}`;
      values.push(endDate);
    }

    query += ` GROUP BY hour ORDER BY hour`;

    const result = await pool.query(query, values);
    
    // Format as object with hours 0-23
    const hourly = {};
    for (let i = 0; i < 24; i++) hourly[i] = 0;
    result.rows.forEach(row => {
      hourly[row.hour] = parseInt(row.call_count);
    });
    
    return hourly;
  },

  // Get calls by day of week
  async getCallsByDayOfWeek(clientId, startDate, endDate) {
    let query = `
      SELECT 
        EXTRACT(DOW FROM initiated_at) as day_of_week,
        COUNT(*) as call_count
      FROM call_sessions
      WHERE client_id = $1
    `;
    
    const values = [clientId];
    let paramCount = 2;

    if (startDate) {
      query += ` AND initiated_at >= $${paramCount++}`;
      values.push(startDate);
    }
    if (endDate) {
      query += ` AND initiated_at <= $${paramCount++}`;
      values.push(endDate);
    }

    query += ` GROUP BY day_of_week ORDER BY day_of_week`;

    const result = await pool.query(query, values);
    
    // Format as object with days 0-6 (Sunday-Saturday)
    const weekly = {};
    for (let i = 0; i < 7; i++) weekly[i] = 0;
    result.rows.forEach(row => {
      weekly[row.day_of_week] = parseInt(row.call_count);
    });
    
    return weekly;
  },

  // Get top customers
  async getTopCustomers(clientId, limit = 10, startDate, endDate) {
    let query = `
      SELECT 
        customer_id_external,
        customer_name,
        customer_phone,
        COUNT(*) as call_count,
        COALESCE(SUM(duration), 0) as total_duration
      FROM call_sessions
      WHERE client_id = $1
        AND customer_id_external IS NOT NULL
    `;
    
    const values = [clientId];
    let paramCount = 2;

    if (startDate) {
      query += ` AND initiated_at >= $${paramCount++}`;
      values.push(startDate);
    }
    if (endDate) {
      query += ` AND initiated_at <= $${paramCount++}`;
      values.push(endDate);
    }

    query += `
      GROUP BY customer_id_external, customer_name, customer_phone
      ORDER BY call_count DESC
      LIMIT $${paramCount}
    `;
    values.push(limit);

    const result = await pool.query(query, values);
    return result.rows;
  },

  // Get duration buckets
  async getDurationBuckets(clientId, startDate, endDate) {
    let query = `
      SELECT 
        CASE 
          WHEN duration < 30 THEN '0-30s'
          WHEN duration < 60 THEN '30s-1m'
          WHEN duration < 180 THEN '1m-3m'
          WHEN duration < 300 THEN '3m-5m'
          ELSE '5m+'
        END as duration_bucket,
        COUNT(*) as call_count
      FROM call_sessions
      WHERE client_id = $1
        AND duration IS NOT NULL
    `;
    
    const values = [clientId];
    let paramCount = 2;

    if (startDate) {
      query += ` AND initiated_at >= $${paramCount++}`;
      values.push(startDate);
    }
    if (endDate) {
      query += ` AND initiated_at <= $${paramCount++}`;
      values.push(endDate);
    }

    query += ` GROUP BY duration_bucket`;

    const result = await pool.query(query, values);
    
    // Format as object
    const buckets = {
      '0-30s': 0,
      '30s-1m': 0,
      '1m-3m': 0,
      '3m-5m': 0,
      '5m+': 0
    };
    
    result.rows.forEach(row => {
      buckets[row.duration_bucket] = parseInt(row.call_count);
    });
    
    return buckets;
  }
};

// ============================================
// EXPORT
// ============================================

module.exports = {
  pool,
  clients,
  callSessions,
  callEvents,
  callNotes,
  usageTracking,
  analytics
};
