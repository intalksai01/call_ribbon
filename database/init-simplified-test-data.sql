-- ============================================
-- Initialize Simplified Database with Test Data
-- ============================================

-- Insert Test Clients
INSERT INTO clients (
    client_id,
    api_key,
    client_name,
    email,
    exotel_token,
    exotel_user_id,
    plan_type,
    monthly_call_limit,
    calls_this_month,
    features,
    allowed_domains,
    status
) VALUES 
-- South India Finvest
(
    '550e8400-e29b-41d4-a716-446655440001',
    'southindia-finvest-api-key-2024',
    'South India Finvest',
    'admin@southindiafinvest.com',
    '9875596a6e1be7bfaa865f43a028ec40f980e57fdeb4de8c',
    'f6e23a8c3ce28cda4a76bce715dd714e1d138183f58179df',
    'enterprise',
    20000,
    4,
    '["call", "mute", "hold", "dtmf", "transfer", "recording"]'::jsonb,
    '["*"]'::jsonb,
    'active'
),
-- Demo Client
(
    '550e8400-e29b-41d4-a716-446655440002',
    'demo-api-key-789',
    'Demo Client',
    'demo@example.com',
    'demo-token-12345',
    'demo-user-12345',
    'trial',
    100,
    5,
    '["call", "mute", "hold"]'::jsonb,
    '["*"]'::jsonb,
    'active'
),
-- Collections CRM Client
(
    '550e8400-e29b-41d4-a716-446655440003',
    'collections-crm-api-key-123',
    'Collections CRM Pro',
    'admin@collectionscrm.com',
    'collections-token-67890',
    'collections-user-67890',
    'enterprise',
    10000,
    152,
    '["call", "mute", "hold", "dtmf", "transfer"]'::jsonb,
    '["collectionscrm.com", "*.collectionscrm.com"]'::jsonb,
    'active'
);

-- ============================================
-- Insert Sample Call Sessions
-- ============================================

-- Call 1: Rajesh Kumar - Business Loan Collection
INSERT INTO call_sessions (
    session_id,
    client_id,
    exotel_call_sid,
    customer_name,
    customer_phone,
    customer_id_external,
    customer_context,
    call_direction,
    call_type,
    initiated_at,
    connected_at,
    ended_at,
    duration,
    call_status,
    end_reason,
    agent_id,
    agent_name,
    metadata
) VALUES (
    '86e2ed8c-7be1-401b-9a9e-eb9c966f5e0f',
    '550e8400-e29b-41d4-a716-446655440001',
    'CA778503936',
    'Rajesh Kumar',
    '+919876543210',
    'LOAN001',
    '{"loanType": "Business Loan", "loanAmount": 500000, "outstandingBalance": 150000, "daysOverdue": 45, "emiAmount": 15000}'::jsonb,
    'outbound',
    'collections',
    NOW() - INTERVAL '25 hours',
    NOW() - INTERVAL '25 hours' + INTERVAL '25 seconds',
    NOW() - INTERVAL '25 hours' + INTERVAL '360 seconds',
    335,
    'completed',
    'normal',
    'AGT001',
    'Suresh Kumar',
    '{"campaign": "overdue_45days", "attempt": 3}'::jsonb
);

-- Call 2: Rajesh Kumar - Follow-up call
INSERT INTO call_sessions (
    session_id,
    client_id,
    exotel_call_sid,
    customer_name,
    customer_phone,
    customer_id_external,
    customer_context,
    call_direction,
    call_type,
    initiated_at,
    connected_at,
    ended_at,
    duration,
    call_status,
    end_reason,
    agent_id,
    agent_name,
    metadata
) VALUES (
    '48b3a826-78b4-4006-a65a-a5c6d8f61fd8',
    '550e8400-e29b-41d4-a716-446655440001',
    'CA473456643',
    'Rajesh Kumar',
    '+919876543210',
    'LOAN001',
    '{"loanType": "Business Loan", "loanAmount": 500000, "outstandingBalance": 150000, "daysOverdue": 45}'::jsonb,
    'outbound',
    'collections',
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '2 hours' + INTERVAL '30 seconds',
    NOW() - INTERVAL '2 hours' + INTERVAL '300 seconds',
    270,
    'completed',
    'normal',
    'AGT001',
    'Suresh Kumar',
    '{"campaign": "overdue_45days", "attempt": 4, "paymentPromise": "5 days"}'::jsonb
);

-- Call 3: Priya Sharma - Personal Loan
INSERT INTO call_sessions (
    session_id,
    client_id,
    exotel_call_sid,
    customer_name,
    customer_phone,
    customer_id_external,
    customer_context,
    call_direction,
    call_type,
    initiated_at,
    connected_at,
    ended_at,
    duration,
    call_status,
    end_reason,
    agent_id,
    agent_name,
    metadata
) VALUES (
    '53bb22e2-a33d-47ef-9db8-f841df1060d8',
    '550e8400-e29b-41d4-a716-446655440001',
    'CA739160780',
    'Priya Sharma',
    '+918765432109',
    'LOAN002',
    '{"loanType": "Personal Loan", "loanAmount": 200000, "outstandingBalance": 75000, "daysOverdue": 30}'::jsonb,
    'outbound',
    'collections',
    NOW() - INTERVAL '10 hours',
    NOW() - INTERVAL '10 hours' + INTERVAL '20 seconds',
    NOW() - INTERVAL '10 hours' + INTERVAL '180 seconds',
    160,
    'completed',
    'normal',
    'AGT002',
    'Meena Iyer',
    '{"campaign": "overdue_30days", "satisfaction": "high"}'::jsonb
);

-- Call 4: Venkatesh Iyer - Missed Call
INSERT INTO call_sessions (
    session_id,
    client_id,
    exotel_call_sid,
    customer_name,
    customer_phone,
    customer_id_external,
    customer_context,
    call_direction,
    call_type,
    initiated_at,
    connected_at,
    ended_at,
    duration,
    call_status,
    end_reason,
    agent_id,
    agent_name,
    metadata
) VALUES (
    '291018f1-237b-45bf-ab63-a9f0e6c72433',
    '550e8400-e29b-41d4-a716-446655440001',
    'CA694879731',
    'Venkatesh Iyer',
    '+917654321098',
    'LOAN003',
    '{"loanType": "Home Loan EMI", "loanAmount": 5000000, "outstandingBalance": 250000, "daysOverdue": 60}'::jsonb,
    'outbound',
    'collections',
    NOW() - INTERVAL '3 hours',
    NULL,
    NOW() - INTERVAL '3 hours' + INTERVAL '35 seconds',
    0,
    'missed',
    'no_answer',
    'AGT001',
    'Suresh Kumar',
    '{"campaign": "overdue_60days", "attempt": 9}'::jsonb
);

-- Call 5: Lakshmi Sundaram - Gold Loan (Sales Lead converted)
INSERT INTO call_sessions (
    session_id,
    client_id,
    exotel_call_sid,
    customer_name,
    customer_phone,
    customer_id_external,
    customer_context,
    call_direction,
    call_type,
    initiated_at,
    connected_at,
    ended_at,
    duration,
    call_status,
    end_reason,
    agent_id,
    agent_name,
    metadata
) VALUES (
    '239577b9-e15b-4de9-8589-f33e683ee801',
    '550e8400-e29b-41d4-a716-446655440001',
    'CA312562576',
    'Lakshmi Sundaram',
    '+919988776655',
    'LOAN004',
    '{"loanType": "Gold Loan", "loanAmount": 100000, "outstandingBalance": 50000, "daysOverdue": 15}'::jsonb,
    'outbound',
    'collections',
    NOW() - INTERVAL '7 hours',
    NOW() - INTERVAL '7 hours' + INTERVAL '15 seconds',
    NOW() - INTERVAL '7 hours' + INTERVAL '480 seconds',
    465,
    'completed',
    'normal',
    'AGT003',
    'Rahul Verma',
    '{"campaign": "overdue_15days", "result": "payment_done"}'::jsonb
);

-- ============================================
-- Insert Call Events
-- ============================================

-- Events for Call 1 (Rajesh Kumar - first call)
INSERT INTO call_events (session_id, event_type, event_data) VALUES
('86e2ed8c-7be1-401b-9a9e-eb9c966f5e0f', 'initiated', '{"phoneNumber": "+919876543210"}'::jsonb),
('86e2ed8c-7be1-401b-9a9e-eb9c966f5e0f', 'ringing', '{}'::jsonb),
('86e2ed8c-7be1-401b-9a9e-eb9c966f5e0f', 'connected', '{}'::jsonb),
('86e2ed8c-7be1-401b-9a9e-eb9c966f5e0f', 'muted', '{"muted": true}'::jsonb),
('86e2ed8c-7be1-401b-9a9e-eb9c966f5e0f', 'unmuted', '{"muted": false}'::jsonb),
('86e2ed8c-7be1-401b-9a9e-eb9c966f5e0f', 'ended', '{"duration": 335, "reason": "normal"}'::jsonb);

-- Events for Call 2 (Rajesh Kumar - follow-up)
INSERT INTO call_events (session_id, event_type, event_data) VALUES
('48b3a826-78b4-4006-a65a-a5c6d8f61fd8', 'initiated', '{"phoneNumber": "+919876543210"}'::jsonb),
('48b3a826-78b4-4006-a65a-a5c6d8f61fd8', 'ringing', '{}'::jsonb),
('48b3a826-78b4-4006-a65a-a5c6d8f61fd8', 'connected', '{}'::jsonb),
('48b3a826-78b4-4006-a65a-a5c6d8f61fd8', 'ended', '{"duration": 270, "reason": "normal"}'::jsonb);

-- Events for Call 3 (Priya Sharma)
INSERT INTO call_events (session_id, event_type, event_data) VALUES
('53bb22e2-a33d-47ef-9db8-f841df1060d8', 'initiated', '{"phoneNumber": "+918765432109"}'::jsonb),
('53bb22e2-a33d-47ef-9db8-f841df1060d8', 'ringing', '{}'::jsonb),
('53bb22e2-a33d-47ef-9db8-f841df1060d8', 'connected', '{}'::jsonb),
('53bb22e2-a33d-47ef-9db8-f841df1060d8', 'held', '{"held": true}'::jsonb),
('53bb22e2-a33d-47ef-9db8-f841df1060d8', 'resumed', '{"held": false}'::jsonb),
('53bb22e2-a33d-47ef-9db8-f841df1060d8', 'ended', '{"duration": 160, "reason": "normal"}'::jsonb);

-- ============================================
-- Insert Call Notes
-- ============================================

-- Notes for Rajesh Kumar calls
INSERT INTO call_notes (session_id, note_text, note_type, agent_id, agent_name) VALUES
('86e2ed8c-7be1-401b-9a9e-eb9c966f5e0f', 
 'Customer acknowledged the overdue amount. Promised to pay 50% by week end. Will follow up on Friday.',
 'after_call',
 'AGT001',
 'Suresh Kumar'
);

INSERT INTO call_notes (session_id, note_text, note_type, agent_id, agent_name) VALUES
('48b3a826-78b4-4006-a65a-a5c6d8f61fd8', 
 'Follow-up call. Customer confirmed payment will be made in 5 days. Set reminder for next Tuesday.',
 'after_call',
 'AGT001',
 'Suresh Kumar'
);

-- Note for Priya Sharma
INSERT INTO call_notes (session_id, note_text, note_type, agent_id, agent_name) VALUES
('53bb22e2-a33d-47ef-9db8-f841df1060d8', 
 'Customer was very cooperative. Explained financial difficulties due to medical expenses. Agreed on partial payment plan.',
 'after_call',
 'AGT002',
 'Meena Iyer'
);

-- Note for Venkatesh Iyer (missed)
INSERT INTO call_notes (session_id, note_text, note_type, agent_id, agent_name) VALUES
('291018f1-237b-45bf-ab63-a9f0e6c72433', 
 'Call not answered. 9th attempt. Need to try different time slots. Consider sending SMS.',
 'after_call',
 'AGT001',
 'Suresh Kumar'
);

-- ============================================
-- Insert Usage Tracking
-- ============================================

INSERT INTO usage_tracking (client_id, usage_date, call_count, total_duration) VALUES
('550e8400-e29b-41d4-a716-446655440001', CURRENT_DATE, 4, 1230),
('550e8400-e29b-41d4-a716-446655440001', CURRENT_DATE - INTERVAL '1 day', 12, 3420),
('550e8400-e29b-41d4-a716-446655440002', CURRENT_DATE, 5, 650),
('550e8400-e29b-41d4-a716-446655440003', CURRENT_DATE, 152, 45600);

-- ============================================
-- Verification Queries
-- ============================================

-- Check all data
SELECT 'Clients' as table_name, COUNT(*) as count FROM clients
UNION ALL
SELECT 'Call Sessions', COUNT(*) FROM call_sessions
UNION ALL
SELECT 'Call Events', COUNT(*) FROM call_events
UNION ALL
SELECT 'Call Notes', COUNT(*) FROM call_notes
UNION ALL
SELECT 'Usage Tracking', COUNT(*) FROM usage_tracking;

