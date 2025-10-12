-- ============================================
-- IntalksAI Call Ribbon Database Schema
-- Region: ap-south-1 (Mumbai)
-- Database: call_ribbon_db
-- Version: 1.0.0
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. CLIENTS TABLE
-- Stores client/tenant information
-- ============================================

CREATE TABLE clients (
    client_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    api_key VARCHAR(255) UNIQUE NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    company_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    
    -- Exotel Credentials (Encrypted in production)
    exotel_token TEXT NOT NULL,
    exotel_user_id TEXT NOT NULL,
    exotel_account_sid VARCHAR(255),
    
    -- Subscription & Limits
    plan_type VARCHAR(50) NOT NULL DEFAULT 'trial', -- trial, starter, professional, enterprise
    monthly_call_limit INTEGER NOT NULL DEFAULT 100,
    calls_this_month INTEGER NOT NULL DEFAULT 0,
    
    -- Features enabled for this client
    features JSONB DEFAULT '["call", "mute", "hold"]'::jsonb,
    
    -- Domain restrictions
    allowed_domains JSONB DEFAULT '["*"]'::jsonb,
    
    -- Billing
    billing_email VARCHAR(255),
    billing_cycle_start DATE,
    next_billing_date DATE,
    
    -- Status
    status VARCHAR(50) DEFAULT 'active', -- active, suspended, cancelled
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_clients_api_key ON clients(api_key);
CREATE INDEX idx_clients_status ON clients(status);
CREATE INDEX idx_clients_plan_type ON clients(plan_type);

-- ============================================
-- 2. CUSTOMERS TABLE
-- Stores customer/contact information
-- ============================================

CREATE TABLE customers (
    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- External customer ID from client's CRM
    external_customer_id VARCHAR(255),
    
    -- Basic Info
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    full_name VARCHAR(500),
    email VARCHAR(255),
    phone_number VARCHAR(50) NOT NULL,
    alternate_phone VARCHAR(50),
    
    -- Company Info
    company_name VARCHAR(255),
    job_title VARCHAR(255),
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    
    -- Customer Segmentation
    customer_type VARCHAR(50), -- prospect, lead, customer, vip
    segment VARCHAR(50), -- enterprise, smb, individual
    priority VARCHAR(50), -- high, medium, low
    tags JSONB DEFAULT '[]'::jsonb,
    
    -- Custom Fields (Flexible schema)
    custom_fields JSONB DEFAULT '{}'::jsonb,
    
    -- Statistics (Denormalized for performance)
    total_calls INTEGER DEFAULT 0,
    total_call_duration INTEGER DEFAULT 0, -- in seconds
    last_call_date TIMESTAMP WITH TIME ZONE,
    first_call_date TIMESTAMP WITH TIME ZONE,
    
    -- Status
    status VARCHAR(50) DEFAULT 'active', -- active, inactive, blocked
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Unique constraint
    UNIQUE(client_id, external_customer_id)
);

CREATE INDEX idx_customers_client_id ON customers(client_id);
CREATE INDEX idx_customers_phone ON customers(phone_number);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_external_id ON customers(client_id, external_customer_id);
CREATE INDEX idx_customers_type ON customers(customer_type);
CREATE INDEX idx_customers_segment ON customers(segment);
CREATE INDEX idx_customers_tags ON customers USING GIN(tags);

-- ============================================
-- 3. CALL_SESSIONS TABLE
-- Stores call session information
-- ============================================

CREATE TABLE call_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(customer_id) ON DELETE SET NULL,
    
    -- Call Identifiers
    exotel_call_sid VARCHAR(255),
    external_call_id VARCHAR(255), -- Client's CRM call ID
    
    -- Call Details
    phone_number VARCHAR(50) NOT NULL,
    call_direction VARCHAR(20) NOT NULL, -- inbound, outbound
    call_type VARCHAR(50), -- sales, support, collections, etc.
    
    -- Timing
    initiated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    connected_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration INTEGER, -- in seconds
    ring_duration INTEGER, -- time to answer in seconds
    
    -- Call Status
    call_status VARCHAR(50) NOT NULL, -- initiated, ringing, connected, completed, failed, missed, busy, no_answer
    end_reason VARCHAR(100), -- normal, busy, failed, no_answer, cancelled
    
    -- Quality Metrics
    quality_score INTEGER, -- 1-5
    has_recording BOOLEAN DEFAULT false,
    recording_url TEXT,
    
    -- Agent/User Info
    agent_id VARCHAR(255),
    agent_name VARCHAR(255),
    
    -- Call Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_call_sessions_client_id ON call_sessions(client_id);
CREATE INDEX idx_call_sessions_customer_id ON call_sessions(customer_id);
CREATE INDEX idx_call_sessions_phone ON call_sessions(phone_number);
CREATE INDEX idx_call_sessions_exotel_sid ON call_sessions(exotel_call_sid);
CREATE INDEX idx_call_sessions_direction ON call_sessions(call_direction);
CREATE INDEX idx_call_sessions_status ON call_sessions(call_status);
CREATE INDEX idx_call_sessions_initiated_at ON call_sessions(initiated_at DESC);
CREATE INDEX idx_call_sessions_connected_at ON call_sessions(connected_at DESC);
CREATE INDEX idx_call_sessions_client_date ON call_sessions(client_id, initiated_at DESC);

-- ============================================
-- 4. CALL_EVENTS TABLE
-- Stores detailed call events for tracking
-- ============================================

CREATE TABLE call_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES call_sessions(session_id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- Event Info
    event_type VARCHAR(50) NOT NULL, -- incoming, ringing, connected, muted, unmuted, hold, resume, dtmf, transferred, callEnded
    event_data JSONB DEFAULT '{}'::jsonb,
    
    -- Timing
    event_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Source
    source VARCHAR(50), -- widget, api, webhook
    domain VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_call_events_session_id ON call_events(session_id);
CREATE INDEX idx_call_events_client_id ON call_events(client_id);
CREATE INDEX idx_call_events_type ON call_events(event_type);
CREATE INDEX idx_call_events_timestamp ON call_events(event_timestamp DESC);
CREATE INDEX idx_call_events_client_timestamp ON call_events(client_id, event_timestamp DESC);

-- ============================================
-- 5. CALL_NOTES TABLE
-- Stores notes/comments for calls
-- ============================================

CREATE TABLE call_notes (
    note_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES call_sessions(session_id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(customer_id) ON DELETE SET NULL,
    
    -- Note Content
    note_text TEXT NOT NULL,
    note_type VARCHAR(50), -- general, follow_up, issue, success
    
    -- Author
    created_by VARCHAR(255), -- Agent ID or name
    
    -- Visibility
    is_internal BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_call_notes_session_id ON call_notes(session_id);
CREATE INDEX idx_call_notes_customer_id ON call_notes(customer_id);
CREATE INDEX idx_call_notes_created_at ON call_notes(created_at DESC);

-- ============================================
-- 6. CALL_RECORDINGS TABLE
-- Stores call recording information
-- ============================================

CREATE TABLE call_recordings (
    recording_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES call_sessions(session_id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- Recording Info
    recording_url TEXT NOT NULL,
    recording_duration INTEGER, -- in seconds
    file_size_bytes BIGINT,
    format VARCHAR(20), -- mp3, wav, etc.
    
    -- Storage Info
    storage_location VARCHAR(255), -- s3, local, etc.
    s3_bucket VARCHAR(255),
    s3_key VARCHAR(500),
    
    -- Processing
    is_transcribed BOOLEAN DEFAULT false,
    transcription_text TEXT,
    transcription_url TEXT,
    
    -- Security
    is_encrypted BOOLEAN DEFAULT false,
    encryption_key_id VARCHAR(255),
    
    -- Retention
    expires_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_call_recordings_session_id ON call_recordings(session_id);
CREATE INDEX idx_call_recordings_client_id ON call_recordings(client_id);

-- ============================================
-- 7. ANALYTICS_DAILY TABLE
-- Pre-aggregated daily statistics for performance
-- ============================================

CREATE TABLE analytics_daily (
    analytics_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- Date
    report_date DATE NOT NULL,
    
    -- Call Metrics
    total_calls INTEGER DEFAULT 0,
    inbound_calls INTEGER DEFAULT 0,
    outbound_calls INTEGER DEFAULT 0,
    missed_calls INTEGER DEFAULT 0,
    answered_calls INTEGER DEFAULT 0,
    
    -- Duration Metrics
    total_duration INTEGER DEFAULT 0, -- seconds
    avg_duration INTEGER DEFAULT 0,
    max_duration INTEGER DEFAULT 0,
    min_duration INTEGER DEFAULT 0,
    
    -- Quality Metrics
    avg_quality_score DECIMAL(3, 2),
    
    -- Unique Metrics
    unique_customers INTEGER DEFAULT 0,
    new_customers INTEGER DEFAULT 0,
    
    -- Hourly Distribution
    calls_by_hour JSONB DEFAULT '{}'::jsonb,
    
    -- Created
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id, report_date)
);

CREATE INDEX idx_analytics_daily_client_date ON analytics_daily(client_id, report_date DESC);

-- ============================================
-- 8. USAGE_TRACKING TABLE
-- Track API usage for billing
-- ============================================

CREATE TABLE usage_tracking (
    usage_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- Usage Info
    usage_date DATE NOT NULL,
    usage_month VARCHAR(7) NOT NULL, -- YYYY-MM format
    
    -- API Calls
    api_calls_init INTEGER DEFAULT 0,
    api_calls_log INTEGER DEFAULT 0,
    api_calls_total INTEGER DEFAULT 0,
    
    -- Call Minutes
    call_minutes INTEGER DEFAULT 0,
    
    -- Overage
    overage_calls INTEGER DEFAULT 0,
    overage_minutes INTEGER DEFAULT 0,
    
    -- Costs (for billing)
    base_cost DECIMAL(10, 2) DEFAULT 0,
    overage_cost DECIMAL(10, 2) DEFAULT 0,
    total_cost DECIMAL(10, 2) DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id, usage_date)
);

CREATE INDEX idx_usage_client_date ON usage_tracking(client_id, usage_date DESC);
CREATE INDEX idx_usage_month ON usage_tracking(usage_month);

-- ============================================
-- 9. AGENT_PERFORMANCE TABLE
-- Track individual agent performance
-- ============================================

CREATE TABLE agent_performance (
    performance_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- Agent Info
    agent_id VARCHAR(255) NOT NULL,
    agent_name VARCHAR(255),
    agent_email VARCHAR(255),
    
    -- Performance Metrics
    report_date DATE NOT NULL,
    total_calls INTEGER DEFAULT 0,
    total_duration INTEGER DEFAULT 0,
    avg_call_duration INTEGER DEFAULT 0,
    
    -- Quality
    avg_quality_score DECIMAL(3, 2),
    customer_satisfaction_score DECIMAL(3, 2),
    
    -- Activity
    login_time TIMESTAMP WITH TIME ZONE,
    logout_time TIMESTAMP WITH TIME ZONE,
    active_hours DECIMAL(5, 2),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id, agent_id, report_date)
);

CREATE INDEX idx_agent_performance_client_agent ON agent_performance(client_id, agent_id);
CREATE INDEX idx_agent_performance_date ON agent_performance(report_date DESC);

-- ============================================
-- 10. CUSTOMER_INTERACTIONS TABLE
-- Track all customer touchpoints
-- ============================================

CREATE TABLE customer_interactions (
    interaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(customer_id) ON DELETE CASCADE,
    session_id UUID REFERENCES call_sessions(session_id) ON DELETE SET NULL,
    
    -- Interaction Details
    interaction_type VARCHAR(50) NOT NULL, -- call, email, chat, sms, meeting
    interaction_direction VARCHAR(20), -- inbound, outbound
    
    -- Content
    subject VARCHAR(500),
    description TEXT,
    outcome VARCHAR(100), -- successful, failed, follow_up_needed, converted
    
    -- Agent
    agent_id VARCHAR(255),
    agent_name VARCHAR(255),
    
    -- Timing
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration INTEGER,
    
    -- Follow-up
    requires_follow_up BOOLEAN DEFAULT false,
    follow_up_date TIMESTAMP WITH TIME ZONE,
    follow_up_notes TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_interactions_customer_id ON customer_interactions(customer_id);
CREATE INDEX idx_interactions_session_id ON customer_interactions(session_id);
CREATE INDEX idx_interactions_type ON customer_interactions(interaction_type);
CREATE INDEX idx_interactions_started_at ON customer_interactions(started_at DESC);

-- ============================================
-- 11. CALL_TAGS TABLE
-- Tagging system for calls
-- ============================================

CREATE TABLE call_tags (
    tag_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES call_sessions(session_id) ON DELETE CASCADE,
    
    -- Tag Info
    tag_name VARCHAR(100) NOT NULL,
    tag_category VARCHAR(100), -- disposition, issue, resolution, product
    
    -- Added by
    added_by VARCHAR(255),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_call_tags_session_id ON call_tags(session_id);
CREATE INDEX idx_call_tags_name ON call_tags(tag_name);
CREATE INDEX idx_call_tags_category ON call_tags(tag_category);

-- ============================================
-- 12. DISPOSITIONS TABLE
-- Call outcomes/dispositions
-- ============================================

CREATE TABLE dispositions (
    disposition_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- Disposition Info
    disposition_code VARCHAR(50) NOT NULL,
    disposition_name VARCHAR(255) NOT NULL,
    disposition_category VARCHAR(100), -- success, failure, callback, no_answer
    
    -- Configuration
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id, disposition_code)
);

CREATE INDEX idx_dispositions_client_id ON dispositions(client_id);

-- ============================================
-- 13. CALL_DISPOSITIONS TABLE
-- Links calls to dispositions
-- ============================================

CREATE TABLE call_dispositions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES call_sessions(session_id) ON DELETE CASCADE,
    disposition_id UUID NOT NULL REFERENCES dispositions(disposition_id) ON DELETE CASCADE,
    
    -- Additional Info
    notes TEXT,
    set_by VARCHAR(255), -- Agent who set the disposition
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_call_dispositions_session_id ON call_dispositions(session_id);
CREATE INDEX idx_call_dispositions_disposition_id ON call_dispositions(disposition_id);

-- ============================================
-- 14. WEBHOOKS TABLE
-- Webhook configurations for clients
-- ============================================

CREATE TABLE webhooks (
    webhook_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- Webhook Config
    webhook_url TEXT NOT NULL,
    webhook_secret VARCHAR(255),
    
    -- Events to trigger
    trigger_events JSONB DEFAULT '["connected", "callEnded"]'::jsonb,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Stats
    total_sent INTEGER DEFAULT 0,
    last_sent_at TIMESTAMP WITH TIME ZONE,
    last_error TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_webhooks_client_id ON webhooks(client_id);

-- ============================================
-- 15. API_LOGS TABLE
-- Audit trail for API requests
-- ============================================

CREATE TABLE api_logs (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES clients(client_id) ON DELETE SET NULL,
    
    -- Request Info
    endpoint VARCHAR(255) NOT NULL,
    method VARCHAR(10) NOT NULL,
    api_key_prefix VARCHAR(20), -- First 10 chars
    
    -- Request Details
    request_body JSONB,
    query_params JSONB,
    headers JSONB,
    
    -- Response
    status_code INTEGER,
    response_time_ms INTEGER,
    
    -- Client Info
    ip_address INET,
    user_agent TEXT,
    domain VARCHAR(255),
    
    -- Error tracking
    error_message TEXT,
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_api_logs_client_id ON api_logs(client_id);
CREATE INDEX idx_api_logs_endpoint ON api_logs(endpoint);
CREATE INDEX idx_api_logs_created_at ON api_logs(created_at DESC);
CREATE INDEX idx_api_logs_status ON api_logs(status_code);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all tables with updated_at
CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_call_sessions_updated_at BEFORE UPDATE ON call_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_usage_tracking_updated_at BEFORE UPDATE ON usage_tracking
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_webhooks_updated_at BEFORE UPDATE ON webhooks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Update customer statistics
CREATE OR REPLACE FUNCTION update_customer_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.call_status = 'completed' AND NEW.customer_id IS NOT NULL THEN
        UPDATE customers
        SET 
            total_calls = total_calls + 1,
            total_call_duration = total_call_duration + COALESCE(NEW.duration, 0),
            last_call_date = NEW.ended_at,
            first_call_date = COALESCE(first_call_date, NEW.connected_at)
        WHERE customer_id = NEW.customer_id;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_customer_stats_trigger AFTER INSERT OR UPDATE ON call_sessions
    FOR EACH ROW EXECUTE FUNCTION update_customer_stats();

-- ============================================
-- VIEWS FOR COMMON QUERIES
-- ============================================

-- View: Recent calls with customer info
CREATE VIEW v_recent_calls AS
SELECT 
    cs.session_id,
    cs.client_id,
    cl.client_name,
    cs.customer_id,
    cust.full_name as customer_name,
    cust.phone_number,
    cs.call_direction,
    cs.call_status,
    cs.connected_at,
    cs.ended_at,
    cs.duration,
    cs.exotel_call_sid
FROM call_sessions cs
LEFT JOIN customers cust ON cs.customer_id = cust.customer_id
LEFT JOIN clients cl ON cs.client_id = cl.client_id
ORDER BY cs.initiated_at DESC;

-- View: Daily statistics per client
CREATE VIEW v_daily_stats AS
SELECT 
    client_id,
    DATE(initiated_at) as call_date,
    COUNT(*) as total_calls,
    COUNT(*) FILTER (WHERE call_direction = 'inbound') as inbound_calls,
    COUNT(*) FILTER (WHERE call_direction = 'outbound') as outbound_calls,
    COUNT(*) FILTER (WHERE call_status = 'completed') as completed_calls,
    COUNT(*) FILTER (WHERE call_status = 'missed') as missed_calls,
    SUM(duration) FILTER (WHERE call_status = 'completed') as total_duration,
    AVG(duration) FILTER (WHERE call_status = 'completed') as avg_duration,
    COUNT(DISTINCT customer_id) as unique_customers
FROM call_sessions
GROUP BY client_id, DATE(initiated_at);

-- View: Customer call history summary
CREATE VIEW v_customer_call_summary AS
SELECT 
    cust.customer_id,
    cust.client_id,
    cust.full_name,
    cust.phone_number,
    cust.email,
    cust.total_calls,
    cust.total_call_duration,
    cust.last_call_date,
    cust.first_call_date,
    COUNT(cs.session_id) FILTER (WHERE cs.call_status = 'completed') as completed_calls,
    COUNT(cs.session_id) FILTER (WHERE cs.call_status = 'missed') as missed_calls,
    MAX(cs.ended_at) as most_recent_call
FROM customers cust
LEFT JOIN call_sessions cs ON cust.customer_id = cs.customer_id
GROUP BY cust.customer_id, cust.client_id, cust.full_name, cust.phone_number, 
         cust.email, cust.total_calls, cust.total_call_duration, 
         cust.last_call_date, cust.first_call_date;

-- ============================================
-- SAMPLE DATA FOR DEMO
-- ============================================

-- Insert demo client (matches server.js)
INSERT INTO clients (
    client_id,
    api_key,
    client_name,
    company_name,
    email,
    exotel_token,
    exotel_user_id,
    plan_type,
    monthly_call_limit,
    features,
    allowed_domains
) VALUES (
    uuid_generate_v4(),
    'demo-api-key-789',
    'Demo Client',
    'IntalksAI Demo',
    'demo@intalksai.com',
    '9875596a6e1be7bfaa865f43a028ec40f980e57fdeb4de8c',
    'f6e23a8c3ce28cda4a76bce715dd714e1d138183f58179df',
    'trial',
    100,
    '["call", "mute", "hold", "dtmf"]'::jsonb,
    '["*"]'::jsonb
);

-- Insert enterprise client
INSERT INTO clients (
    client_id,
    api_key,
    client_name,
    company_name,
    email,
    exotel_token,
    exotel_user_id,
    plan_type,
    monthly_call_limit,
    features,
    allowed_domains
) VALUES (
    uuid_generate_v4(),
    'collections-crm-api-key-123',
    'Collections CRM Inc.',
    'Collections CRM',
    'admin@collections-crm.com',
    '9875596a6e1be7bfaa865f43a028ec40f980e57fdeb4de8c',
    'f6e23a8c3ce28cda4a76bce715dd714e1d138183f58179df',
    'enterprise',
    10000,
    '["call", "mute", "hold", "dtmf", "transfer"]'::jsonb,
    '["collections-crm.com", "localhost"]'::jsonb
);

-- Insert professional client
INSERT INTO clients (
    client_id,
    api_key,
    client_name,
    company_name,
    email,
    exotel_token,
    exotel_user_id,
    plan_type,
    monthly_call_limit,
    features,
    allowed_domains
) VALUES (
    uuid_generate_v4(),
    'marketing-leads-api-key-456',
    'Marketing Leads Pro',
    'Marketing CRM',
    'admin@marketing-crm.com',
    'different_exotel_token_here',
    'different_user_id_here',
    'professional',
    5000,
    '["call", "mute", "hold"]'::jsonb,
    '["marketing-crm.com", "localhost"]'::jsonb
);

-- Insert sample dispositions
INSERT INTO dispositions (client_id, disposition_code, disposition_name, disposition_category) 
SELECT 
    client_id,
    code,
    name,
    category
FROM clients, (VALUES
    ('success', 'Successfully Contacted', 'success'),
    ('no_answer', 'No Answer', 'failure'),
    ('busy', 'Busy', 'failure'),
    ('callback', 'Callback Requested', 'callback'),
    ('not_interested', 'Not Interested', 'failure'),
    ('wrong_number', 'Wrong Number', 'failure'),
    ('follow_up', 'Follow Up Required', 'callback'),
    ('converted', 'Converted/Closed', 'success')
) AS disp(code, name, category)
WHERE clients.plan_type IN ('enterprise', 'professional');

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE clients IS 'Stores client/tenant information and configuration';
COMMENT ON TABLE customers IS 'Stores customer/contact information with flexible custom fields';
COMMENT ON TABLE call_sessions IS 'Main call tracking table with comprehensive call details';
COMMENT ON TABLE call_events IS 'Detailed event log for each call state change';
COMMENT ON TABLE call_notes IS 'Notes and comments added during or after calls';
COMMENT ON TABLE call_recordings IS 'Call recording metadata and storage information';
COMMENT ON TABLE analytics_daily IS 'Pre-aggregated daily statistics for fast reporting';
COMMENT ON TABLE usage_tracking IS 'API usage tracking for billing purposes';
COMMENT ON TABLE agent_performance IS 'Agent performance metrics and KPIs';
COMMENT ON TABLE customer_interactions IS 'All customer touchpoints across channels';
COMMENT ON TABLE call_tags IS 'Flexible tagging system for calls';
COMMENT ON TABLE dispositions IS 'Pre-defined call dispositions/outcomes';
COMMENT ON TABLE call_dispositions IS 'Links calls to their dispositions';
COMMENT ON TABLE webhooks IS 'Webhook configurations for real-time integrations';
COMMENT ON TABLE api_logs IS 'Audit trail for all API requests';

-- ============================================
-- GRANTS (Adjust as needed)
-- ============================================

-- Grant permissions to application user
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO app_user;

-- ============================================
-- END OF SCHEMA
-- ============================================

