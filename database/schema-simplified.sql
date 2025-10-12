-- ============================================
-- IntalksAI Call Ribbon - SIMPLIFIED Schema
-- Focus: Call History + Basic Context Only
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. CLIENTS TABLE
-- Our paying customers who use the widget
-- ============================================

CREATE TABLE clients (
    client_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    api_key VARCHAR(255) UNIQUE NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    
    -- Exotel Credentials (We manage this, not them)
    exotel_token TEXT NOT NULL,
    exotel_user_id TEXT NOT NULL,
    
    -- Subscription & Limits
    plan_type VARCHAR(50) NOT NULL DEFAULT 'trial',
    monthly_call_limit INTEGER NOT NULL DEFAULT 100,
    calls_this_month INTEGER NOT NULL DEFAULT 0,
    
    -- Features enabled
    features JSONB DEFAULT '["call", "mute", "hold"]'::jsonb,
    
    -- Domain restrictions
    allowed_domains JSONB DEFAULT '["*"]'::jsonb,
    
    -- Status
    status VARCHAR(50) DEFAULT 'active',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clients_api_key ON clients(api_key);
CREATE INDEX idx_clients_status ON clients(status);

-- ============================================
-- 2. CALL_SESSIONS TABLE
-- Core table: Every call made through our widget
-- ============================================

CREATE TABLE call_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- Exotel Call Info
    exotel_call_sid VARCHAR(255),
    
    -- Customer Context (from their CRM, passed to us)
    customer_name VARCHAR(255),
    customer_phone VARCHAR(50) NOT NULL,
    customer_id_external VARCHAR(255), -- Their CRM's customer ID
    customer_context JSONB DEFAULT '{}'::jsonb, -- Any extra context they pass
    
    -- Call Details
    call_direction VARCHAR(20), -- inbound, outbound
    call_type VARCHAR(50), -- collections, sales, support, etc.
    
    -- Call Timeline
    initiated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    connected_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration INTEGER, -- seconds
    
    -- Call Outcome
    call_status VARCHAR(50), -- initiated, ringing, connected, completed, failed, missed
    end_reason VARCHAR(100), -- normal, busy, no_answer, failed, cancelled
    
    -- Agent Info (from their system)
    agent_id VARCHAR(255),
    agent_name VARCHAR(255),
    
    -- Flexible metadata for client-specific data
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_call_sessions_client ON call_sessions(client_id);
CREATE INDEX idx_call_sessions_customer_phone ON call_sessions(customer_phone);
CREATE INDEX idx_call_sessions_customer_external ON call_sessions(customer_id_external);
CREATE INDEX idx_call_sessions_initiated_at ON call_sessions(initiated_at DESC);
CREATE INDEX idx_call_sessions_status ON call_sessions(call_status);
CREATE INDEX idx_call_sessions_exotel_sid ON call_sessions(exotel_call_sid);

-- ============================================
-- 3. CALL_EVENTS TABLE
-- Detailed event log for each call
-- ============================================

CREATE TABLE call_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES call_sessions(session_id) ON DELETE CASCADE,
    
    event_type VARCHAR(100) NOT NULL, -- initiated, ringing, connected, muted, held, transferred, dtmf, ended
    event_data JSONB DEFAULT '{}'::jsonb, -- Any event-specific data
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_call_events_session ON call_events(session_id);
CREATE INDEX idx_call_events_type ON call_events(event_type);
CREATE INDEX idx_call_events_created ON call_events(created_at DESC);

-- ============================================
-- 4. CALL_NOTES TABLE (Optional)
-- Agent notes during/after call
-- ============================================

CREATE TABLE call_notes (
    note_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES call_sessions(session_id) ON DELETE CASCADE,
    
    note_text TEXT NOT NULL,
    note_type VARCHAR(50), -- during_call, after_call, follow_up
    
    agent_id VARCHAR(255),
    agent_name VARCHAR(255),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_call_notes_session ON call_notes(session_id);

-- ============================================
-- 5. USAGE_TRACKING TABLE
-- Track API usage for billing
-- ============================================

CREATE TABLE usage_tracking (
    usage_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    
    usage_date DATE NOT NULL,
    call_count INTEGER DEFAULT 0,
    total_duration INTEGER DEFAULT 0, -- seconds
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id, usage_date)
);

CREATE INDEX idx_usage_tracking_client ON usage_tracking(client_id);
CREATE INDEX idx_usage_tracking_date ON usage_tracking(usage_date DESC);

-- ============================================
-- 6. API_LOGS TABLE (Optional - for debugging)
-- Log API requests for troubleshooting
-- ============================================

CREATE TABLE api_logs (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES clients(client_id) ON DELETE SET NULL,
    
    endpoint VARCHAR(255) NOT NULL,
    method VARCHAR(10) NOT NULL,
    status_code INTEGER,
    
    request_data JSONB,
    response_data JSONB,
    error_message TEXT,
    
    ip_address VARCHAR(100),
    user_agent TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_api_logs_client ON api_logs(client_id);
CREATE INDEX idx_api_logs_created ON api_logs(created_at DESC);
CREATE INDEX idx_api_logs_endpoint ON api_logs(endpoint);

-- ============================================
-- TRIGGERS FOR AUTO-UPDATE
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_clients_updated_at
    BEFORE UPDATE ON clients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_call_sessions_updated_at
    BEFORE UPDATE ON call_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS FOR ANALYTICS
-- ============================================

-- Daily call stats per client
CREATE VIEW daily_call_stats AS
SELECT 
    client_id,
    DATE(initiated_at) as call_date,
    COUNT(*) as total_calls,
    COUNT(*) FILTER (WHERE call_status = 'completed') as completed_calls,
    COUNT(*) FILTER (WHERE call_status = 'missed') as missed_calls,
    SUM(duration) FILTER (WHERE duration IS NOT NULL) as total_duration,
    AVG(duration) FILTER (WHERE duration IS NOT NULL) as avg_duration
FROM call_sessions
GROUP BY client_id, DATE(initiated_at);

-- Customer call history summary
CREATE VIEW customer_call_summary AS
SELECT 
    client_id,
    customer_phone,
    customer_name,
    customer_id_external,
    COUNT(*) as total_calls,
    MAX(initiated_at) as last_call_date,
    MIN(initiated_at) as first_call_date,
    SUM(duration) as total_call_duration,
    AVG(duration) as avg_call_duration
FROM call_sessions
WHERE customer_phone IS NOT NULL
GROUP BY client_id, customer_phone, customer_name, customer_id_external;

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE clients IS 'Our customers who use the call ribbon widget';
COMMENT ON TABLE call_sessions IS 'Every call made through our widget - the core data';
COMMENT ON TABLE call_events IS 'Detailed event log for each call (mute, hold, transfer, etc.)';
COMMENT ON TABLE call_notes IS 'Agent notes during or after calls';
COMMENT ON TABLE usage_tracking IS 'Daily usage summary for billing';
COMMENT ON TABLE api_logs IS 'API request logs for debugging';

COMMENT ON COLUMN call_sessions.customer_context IS 'Flexible JSONB field for any customer data from client CRM';
COMMENT ON COLUMN call_sessions.metadata IS 'Flexible JSONB field for call-specific data';

