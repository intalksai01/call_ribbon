-- ============================================
-- Initialize Database with Test Data
-- Client: South India Finvest Pvt Ltd
-- ============================================

-- First, run the main schema
\i schema.sql

-- ============================================
-- Add South India Finvest Pvt Ltd Client
-- ============================================

INSERT INTO clients (
    client_id,
    api_key,
    client_name,
    company_name,
    email,
    phone,
    exotel_token,
    exotel_user_id,
    plan_type,
    monthly_call_limit,
    calls_this_month,
    features,
    allowed_domains,
    billing_email,
    status
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    'southindia-finvest-api-key-2024',
    'South India Finvest',
    'South India Finvest Pvt Ltd',
    'admin@southindiafinvest.com',
    '+919876543210',
    '9875596a6e1be7bfaa865f43a028ec40f980e57fdeb4de8c',
    'f6e23a8c3ce28cda4a76bce715dd714e1d138183f58179df',
    'enterprise',
    20000,
    0,
    '["call", "mute", "hold", "dtmf", "transfer", "recording"]'::jsonb,
    '["southindiafinvest.com", "app.southindiafinvest.com", "localhost"]'::jsonb,
    'billing@southindiafinvest.com',
    'active'
);

-- ============================================
-- Add Customers for South India Finvest
-- ============================================

-- Customer 1: Rajesh Kumar (High Priority - Overdue Loan)
INSERT INTO customers (
    customer_id,
    client_id,
    external_customer_id,
    first_name,
    last_name,
    full_name,
    email,
    phone_number,
    alternate_phone,
    company_name,
    address_line1,
    city,
    state,
    country,
    postal_code,
    customer_type,
    segment,
    priority,
    tags,
    custom_fields,
    status
) VALUES (
    uuid_generate_v4(),
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    'LOAN001',
    'Rajesh',
    'Kumar',
    'Rajesh Kumar',
    'rajesh.kumar@email.com',
    '+919876543210',
    '+919876543211',
    'Kumar Enterprises',
    '123 MG Road',
    'Bangalore',
    'Karnataka',
    'India',
    '560001',
    'customer',
    'smb',
    'high',
    '["overdue", "collections", "high_value"]'::jsonb,
    '{
      "loanAmount": 500000,
      "outstandingBalance": 150000,
      "daysOverdue": 45,
      "lastPaymentDate": "2025-08-15",
      "loanType": "Business Loan",
      "interestRate": 12.5,
      "emiAmount": 15000,
      "collectionAttempts": 3
    }'::jsonb,
    'active'
);

-- Customer 2: Priya Sharma (VIP Customer - Regular Payments)
INSERT INTO customers (
    customer_id,
    client_id,
    external_customer_id,
    first_name,
    last_name,
    full_name,
    email,
    phone_number,
    company_name,
    city,
    state,
    country,
    customer_type,
    segment,
    priority,
    tags,
    custom_fields,
    status
) VALUES (
    uuid_generate_v4(),
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    'LOAN002',
    'Priya',
    'Sharma',
    'Priya Sharma',
    'priya.sharma@email.com',
    '+918765432109',
    NULL,
    'Bangalore',
    'Karnataka',
    'India',
    'customer',
    'individual',
    'medium',
    '["vip", "regular_payer", "home_loan"]'::jsonb,
    '{
      "loanAmount": 2500000,
      "outstandingBalance": 1800000,
      "daysOverdue": 0,
      "lastPaymentDate": "2025-10-01",
      "loanType": "Home Loan",
      "interestRate": 8.5,
      "emiAmount": 25000,
      "paymentHistory": "excellent"
    }'::jsonb,
    'active'
);

-- Customer 3: Amit Patel (New Lead - Personal Loan Inquiry)
INSERT INTO customers (
    customer_id,
    client_id,
    external_customer_id,
    first_name,
    last_name,
    full_name,
    email,
    phone_number,
    city,
    state,
    country,
    customer_type,
    segment,
    priority,
    tags,
    custom_fields,
    status
) VALUES (
    uuid_generate_v4(),
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    'LEAD001',
    'Amit',
    'Patel',
    'Amit Patel',
    'amit.patel@email.com',
    '+917654321098',
    'Mumbai',
    'Maharashtra',
    'India',
    'lead',
    'individual',
    'high',
    '["hot_lead", "personal_loan", "salaried"]'::jsonb,
    '{
      "requestedAmount": 300000,
      "purpose": "Personal Loan",
      "monthlyIncome": 80000,
      "employer": "TCS",
      "creditScore": 750,
      "leadSource": "Website",
      "leadDate": "2025-10-10",
      "followUpRequired": true
    }'::jsonb,
    'active'
);

-- Customer 4: Sunita Reddy (Active Customer - Education Loan)
INSERT INTO customers (
    customer_id,
    client_id,
    external_customer_id,
    first_name,
    last_name,
    full_name,
    email,
    phone_number,
    city,
    state,
    country,
    customer_type,
    segment,
    priority,
    tags,
    custom_fields,
    status
) VALUES (
    uuid_generate_v4(),
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    'LOAN003',
    'Sunita',
    'Reddy',
    'Sunita Reddy',
    'sunita.reddy@email.com',
    '+919988776655',
    'Hyderabad',
    'Telangana',
    'India',
    'customer',
    'individual',
    'low',
    '["education_loan", "regular_payer"]'::jsonb,
    '{
      "loanAmount": 800000,
      "outstandingBalance": 600000,
      "daysOverdue": 0,
      "lastPaymentDate": "2025-10-05",
      "loanType": "Education Loan",
      "interestRate": 10.0,
      "emiAmount": 12000,
      "studentName": "Rahul Reddy",
      "institute": "IIT Madras"
    }'::jsonb,
    'active'
);

-- Customer 5: Venkatesh Iyer (Collections - Multiple Attempts)
INSERT INTO customers (
    customer_id,
    client_id,
    external_customer_id,
    first_name,
    last_name,
    full_name,
    email,
    phone_number,
    city,
    state,
    country,
    customer_type,
    segment,
    priority,
    tags,
    custom_fields,
    status
) VALUES (
    uuid_generate_v4(),
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    'LOAN004',
    'Venkatesh',
    'Iyer',
    'Venkatesh Iyer',
    'venkatesh.iyer@email.com',
    '+918877665544',
    'Chennai',
    'Tamil Nadu',
    'India',
    'customer',
    'individual',
    'high',
    '["overdue", "collections", "multiple_attempts"]'::jsonb,
    '{
      "loanAmount": 400000,
      "outstandingBalance": 180000,
      "daysOverdue": 60,
      "lastPaymentDate": "2025-08-01",
      "loanType": "Personal Loan",
      "interestRate": 15.0,
      "emiAmount": 18000,
      "collectionAttempts": 8,
      "lastCollectionDate": "2025-10-10",
      "paymentPlan": "restructuring_needed"
    }'::jsonb,
    'active'
);

-- Customer 6: Lakshmi Menon (Premium Customer)
INSERT INTO customers (
    customer_id,
    client_id,
    external_customer_id,
    first_name,
    last_name,
    full_name,
    email,
    phone_number,
    city,
    state,
    country,
    customer_type,
    segment,
    priority,
    tags,
    custom_fields,
    status
) VALUES (
    uuid_generate_v4(),
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    'LOAN005',
    'Lakshmi',
    'Menon',
    'Lakshmi Menon',
    'lakshmi.menon@email.com',
    '+917766554433',
    'Kochi',
    'Kerala',
    'India',
    'customer',
    'enterprise',
    'medium',
    '["vip", "premium", "commercial_property"]'::jsonb,
    '{
      "loanAmount": 5000000,
      "outstandingBalance": 3500000,
      "daysOverdue": 0,
      "lastPaymentDate": "2025-10-01",
      "loanType": "Commercial Property Loan",
      "interestRate": 9.5,
      "emiAmount": 65000,
      "propertyValue": 8000000,
      "relationshipManager": "Suresh Kumar"
    }'::jsonb,
    'active'
);

-- ============================================
-- Add Dispositions for South India Finvest
-- ============================================

INSERT INTO dispositions (client_id, disposition_code, disposition_name, disposition_category, sort_order) VALUES
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'payment_promised', 'Payment Promised', 'success', 1),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'partial_payment', 'Partial Payment Received', 'success', 2),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'full_payment', 'Full Payment Received', 'success', 3),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'callback_requested', 'Callback Requested', 'callback', 4),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'payment_plan_agreed', 'Payment Plan Agreed', 'success', 5),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'unable_to_pay', 'Unable to Pay', 'failure', 6),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'no_answer', 'No Answer', 'failure', 7),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'wrong_number', 'Wrong Number', 'failure', 8),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'phone_switched_off', 'Phone Switched Off', 'failure', 9),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'dispute_raised', 'Dispute Raised', 'callback', 10),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'legal_notice_required', 'Legal Notice Required', 'escalation', 11),
('550e8400-e29b-41d4-a716-446655440001'::uuid, 'settlement_discussion', 'Settlement Discussion', 'callback', 12);

-- ============================================
-- Add Sample Call Sessions
-- ============================================

-- Get customer IDs
DO $$
DECLARE
    v_client_id UUID := '550e8400-e29b-41d4-a716-446655440001'::uuid;
    v_customer_loan001 UUID;
    v_customer_loan002 UUID;
    v_customer_loan003 UUID;
    v_customer_loan004 UUID;
    v_session_id UUID;
BEGIN
    -- Get customer UUIDs
    SELECT customer_id INTO v_customer_loan001 FROM customers WHERE external_customer_id = 'LOAN001' AND client_id = v_client_id;
    SELECT customer_id INTO v_customer_loan002 FROM customers WHERE external_customer_id = 'LOAN002' AND client_id = v_client_id;
    SELECT customer_id INTO v_customer_loan003 FROM customers WHERE external_customer_id = 'LEAD001' AND client_id = v_client_id;
    SELECT customer_id INTO v_customer_loan004 FROM customers WHERE external_customer_id = 'LOAN004' AND client_id = v_client_id;

    -- Call Session 1: Rajesh Kumar - Payment Promise
    v_session_id := uuid_generate_v4();
    INSERT INTO call_sessions (
        session_id, client_id, customer_id, exotel_call_sid, phone_number,
        call_direction, call_type, call_status, end_reason,
        initiated_at, connected_at, ended_at, duration,
        agent_id, agent_name, quality_score,
        metadata
    ) VALUES (
        v_session_id, v_client_id, v_customer_loan001, 'CA' || floor(random() * 1000000000)::text,
        '+919876543210', 'outbound', 'collections', 'completed', 'normal',
        NOW() - INTERVAL '2 hours', NOW() - INTERVAL '2 hours' + INTERVAL '30 seconds',
        NOW() - INTERVAL '2 hours' + INTERVAL '5 minutes', 270,
        'AGT001', 'Suresh Kumar', 4,
        '{"campaign": "overdue_45days", "attempt": 4}'::jsonb
    );

    -- Add events for this call
    INSERT INTO call_events (session_id, client_id, event_type, event_data, event_timestamp) VALUES
    (v_session_id, v_client_id, 'initiated', '{}'::jsonb, NOW() - INTERVAL '2 hours'),
    (v_session_id, v_client_id, 'ringing', '{}'::jsonb, NOW() - INTERVAL '2 hours' + INTERVAL '10 seconds'),
    (v_session_id, v_client_id, 'connected', '{}'::jsonb, NOW() - INTERVAL '2 hours' + INTERVAL '30 seconds'),
    (v_session_id, v_client_id, 'hold', '{}'::jsonb, NOW() - INTERVAL '2 hours' + INTERVAL '2 minutes'),
    (v_session_id, v_client_id, 'resume', '{}'::jsonb, NOW() - INTERVAL '2 hours' + INTERVAL '2 minutes 30 seconds'),
    (v_session_id, v_client_id, 'callEnded', '{"reason": "normal"}'::jsonb, NOW() - INTERVAL '2 hours' + INTERVAL '5 minutes');

    -- Add note
    INSERT INTO call_notes (session_id, client_id, customer_id, note_text, note_type, created_by) VALUES
    (v_session_id, v_client_id, v_customer_loan001, 
     'Customer promised to pay Rs. 50,000 by October 15th. Agreed to payment plan for remaining amount.',
     'follow_up', 'AGT001');

    -- Add disposition
    INSERT INTO call_dispositions (session_id, disposition_id, notes, set_by) VALUES
    (v_session_id, (SELECT disposition_id FROM dispositions WHERE client_id = v_client_id AND disposition_code = 'payment_promised'),
     'Payment of Rs. 50,000 promised by Oct 15', 'AGT001');

    -- Call Session 2: Priya Sharma - Regular Check-in
    v_session_id := uuid_generate_v4();
    INSERT INTO call_sessions (
        session_id, client_id, customer_id, exotel_call_sid, phone_number,
        call_direction, call_type, call_status, end_reason,
        initiated_at, connected_at, ended_at, duration,
        agent_id, agent_name, quality_score,
        metadata
    ) VALUES (
        v_session_id, v_client_id, v_customer_loan002, 'CA' || floor(random() * 1000000000)::text,
        '+918765432109', 'outbound', 'customer_service', 'completed', 'normal',
        NOW() - INTERVAL '4 hours', NOW() - INTERVAL '4 hours' + INTERVAL '20 seconds',
        NOW() - INTERVAL '4 hours' + INTERVAL '3 minutes', 160,
        'AGT002', 'Meena Iyer', 5,
        '{"campaign": "courtesy_call", "satisfaction": "high"}'::jsonb
    );

    INSERT INTO call_events (session_id, client_id, event_type, event_timestamp) VALUES
    (v_session_id, v_client_id, 'initiated', NOW() - INTERVAL '4 hours'),
    (v_session_id, v_client_id, 'connected', NOW() - INTERVAL '4 hours' + INTERVAL '20 seconds'),
    (v_session_id, v_client_id, 'callEnded', NOW() - INTERVAL '4 hours' + INTERVAL '3 minutes');

    INSERT INTO call_notes (session_id, client_id, customer_id, note_text, note_type, created_by) VALUES
    (v_session_id, v_client_id, v_customer_loan002,
     'Customer happy with service. No issues. EMI payments are on track.',
     'general', 'AGT002');

    -- Call Session 3: Amit Patel - Lead Follow-up
    v_session_id := uuid_generate_v4();
    INSERT INTO call_sessions (
        session_id, client_id, customer_id, exotel_call_sid, phone_number,
        call_direction, call_type, call_status, end_reason,
        initiated_at, connected_at, ended_at, duration,
        agent_id, agent_name, quality_score,
        metadata
    ) VALUES (
        v_session_id, v_client_id, v_customer_loan003, 'CA' || floor(random() * 1000000000)::text,
        '+917654321098', 'outbound', 'sales', 'completed', 'normal',
        NOW() - INTERVAL '1 hour', NOW() - INTERVAL '1 hour' + INTERVAL '15 seconds',
        NOW() - INTERVAL '1 hour' + INTERVAL '8 minutes', 465,
        'AGT003', 'Rahul Verma', 5,
        '{"campaign": "new_leads", "product": "personal_loan"}'::jsonb
    );

    INSERT INTO call_events (session_id, client_id, event_type, event_timestamp) VALUES
    (v_session_id, v_client_id, 'initiated', NOW() - INTERVAL '1 hour'),
    (v_session_id, v_client_id, 'connected', NOW() - INTERVAL '1 hour' + INTERVAL '15 seconds'),
    (v_session_id, v_client_id, 'callEnded', NOW() - INTERVAL '1 hour' + INTERVAL '8 minutes');

    INSERT INTO call_notes (session_id, client_id, customer_id, note_text, note_type, created_by) VALUES
    (v_session_id, v_client_id, v_customer_loan003,
     'Customer interested. Shared loan details. Documents to be submitted by Oct 14. Follow up required.',
     'follow_up', 'AGT003');

    -- Call Session 4: Venkatesh Iyer - No Answer
    v_session_id := uuid_generate_v4();
    INSERT INTO call_sessions (
        session_id, client_id, customer_id, exotel_call_sid, phone_number,
        call_direction, call_type, call_status, end_reason,
        initiated_at, connected_at, ended_at, duration,
        agent_id, agent_name,
        metadata
    ) VALUES (
        v_session_id, v_client_id, v_customer_loan004, 'CA' || floor(random() * 1000000000)::text,
        '+918877665544', 'outbound', 'collections', 'missed', 'no_answer',
        NOW() - INTERVAL '30 minutes', NULL, NOW() - INTERVAL '30 minutes' + INTERVAL '35 seconds', 0,
        'AGT001', 'Suresh Kumar',
        '{"campaign": "overdue_60days", "attempt": 9}'::jsonb
    );

    INSERT INTO call_events (session_id, client_id, event_type, event_timestamp) VALUES
    (v_session_id, v_client_id, 'initiated', NOW() - INTERVAL '30 minutes'),
    (v_session_id, v_client_id, 'ringing', NOW() - INTERVAL '30 minutes' + INTERVAL '5 seconds'),
    (v_session_id, v_client_id, 'no_answer', NOW() - INTERVAL '30 minutes' + INTERVAL '35 seconds');

    INSERT INTO call_notes (session_id, client_id, customer_id, note_text, note_type, created_by) VALUES
    (v_session_id, v_client_id, v_customer_loan004,
     'No answer. Will try again in 2 hours. Consider sending SMS.',
     'follow_up', 'AGT001');

    -- Call Session 5: Rajesh Kumar - Earlier Call (Yesterday)
    v_session_id := uuid_generate_v4();
    INSERT INTO call_sessions (
        session_id, client_id, customer_id, exotel_call_sid, phone_number,
        call_direction, call_type, call_status, end_reason,
        initiated_at, connected_at, ended_at, duration,
        agent_id, agent_name, quality_score
    ) VALUES (
        v_session_id, v_client_id, v_customer_loan001, 'CA' || floor(random() * 1000000000)::text,
        '+919876543210', 'outbound', 'collections', 'completed', 'normal',
        NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '25 seconds',
        NOW() - INTERVAL '1 day' + INTERVAL '6 minutes', 335,
        'AGT001', 'Suresh Kumar', 3
    );

    INSERT INTO call_notes (session_id, client_id, customer_id, note_text, note_type, created_by) VALUES
    (v_session_id, v_client_id, v_customer_loan001,
     'Customer acknowledged overdue amount. Requested 1 week extension.',
     'general', 'AGT001');

    -- Update client call count
    UPDATE clients SET calls_this_month = 4 WHERE client_id = v_client_id;

END $$;

-- ============================================
-- Add Customer Interactions (Non-Call Touchpoints)
-- ============================================

INSERT INTO customer_interactions (
    client_id, customer_id, interaction_type, interaction_direction,
    subject, description, outcome, agent_name,
    started_at, ended_at, duration
)
SELECT 
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    customer_id,
    'email',
    'outbound',
    'Payment Reminder',
    'Sent automated payment reminder email for upcoming EMI',
    'sent',
    'System',
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '3 days',
    0
FROM customers 
WHERE external_customer_id = 'LOAN001' 
  AND client_id = '550e8400-e29b-41d4-a716-446655440001'::uuid;

-- ============================================
-- Summary
-- ============================================

SELECT 
    'Database initialized successfully!' as status,
    (SELECT COUNT(*) FROM clients WHERE client_id = '550e8400-e29b-41d4-a716-446655440001'::uuid) as clients_added,
    (SELECT COUNT(*) FROM customers WHERE client_id = '550e8400-e29b-41d4-a716-446655440001'::uuid) as customers_added,
    (SELECT COUNT(*) FROM call_sessions WHERE client_id = '550e8400-e29b-41d4-a716-446655440001'::uuid) as call_sessions_added,
    (SELECT COUNT(*) FROM call_events WHERE client_id = '550e8400-e29b-41d4-a716-446655440001'::uuid) as call_events_added,
    (SELECT COUNT(*) FROM call_notes WHERE client_id = '550e8400-e29b-41d4-a716-446655440001'::uuid) as call_notes_added,
    (SELECT COUNT(*) FROM dispositions WHERE client_id = '550e8400-e29b-41d4-a716-446655440001'::uuid) as dispositions_added;

-- Display client info
SELECT 
    client_name,
    api_key,
    plan_type,
    monthly_call_limit,
    calls_this_month,
    features
FROM clients 
WHERE client_id = '550e8400-e29b-41d4-a716-446655440001'::uuid;

-- Display customers
SELECT 
    external_customer_id,
    full_name,
    phone_number,
    customer_type,
    priority,
    tags,
    custom_fields->>'loanType' as loan_type,
    custom_fields->>'outstandingBalance' as outstanding
FROM customers 
WHERE client_id = '550e8400-e29b-41d4-a716-446655440001'::uuid
ORDER BY priority DESC, external_customer_id;

-- Display call sessions
SELECT 
    cs.exotel_call_sid,
    c.full_name,
    cs.phone_number,
    cs.call_direction,
    cs.call_type,
    cs.duration,
    cs.call_status,
    cs.agent_name,
    cs.initiated_at
FROM call_sessions cs
LEFT JOIN customers c ON cs.customer_id = c.customer_id
WHERE cs.client_id = '550e8400-e29b-41d4-a716-446655440001'::uuid
ORDER BY cs.initiated_at DESC;

