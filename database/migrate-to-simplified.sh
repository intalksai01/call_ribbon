#!/bin/bash

# ============================================
# Migrate to Simplified Database Schema
# ============================================

set -e  # Exit on error

DB_HOST="intalksai-call-ribbon-db.cviea4aicss0.ap-south-1.rds.amazonaws.com"
DB_PORT="5432"
DB_NAME="call_ribbon_db"
DB_USER="call_ribbon_admin"
DB_PASSWORD="9AYVOZVXas6tiAz3vYAqZM1NS"

echo "🔄 Migrating to Simplified Database Schema"
echo "==========================================="
echo "⚠️  WARNING: This will drop all existing tables and data!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Migration cancelled"
    exit 1
fi

echo ""
echo "📋 Step 1: Dropping old complex schema..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOF'
-- Drop all existing tables (cascade to drop dependencies)
DROP TABLE IF EXISTS api_logs CASCADE;
DROP TABLE IF EXISTS agent_performance CASCADE;
DROP TABLE IF EXISTS analytics_daily CASCADE;
DROP TABLE IF EXISTS webhooks CASCADE;
DROP TABLE IF EXISTS dispositions CASCADE;
DROP TABLE IF EXISTS call_tags CASCADE;
DROP TABLE IF EXISTS call_recordings CASCADE;
DROP TABLE IF EXISTS call_notes CASCADE;
DROP TABLE IF EXISTS call_events CASCADE;
DROP TABLE IF EXISTS call_sessions CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS usage_tracking CASCADE;
DROP TABLE IF EXISTS clients CASCADE;

-- Drop views
DROP VIEW IF EXISTS daily_call_stats CASCADE;
DROP VIEW IF EXISTS customer_call_summary CASCADE;
DROP VIEW IF EXISTS client_analytics CASCADE;

-- Drop functions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

\echo '✅ Old schema dropped'
EOF

echo ""
echo "📋 Step 2: Creating new simplified schema..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f schema-simplified.sql

echo ""
echo "📋 Step 3: Loading test data..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f init-simplified-test-data.sql

echo ""
echo "📋 Step 4: Verifying migration..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOF'
-- Show table counts
SELECT 
    'clients' as table_name, 
    COUNT(*) as record_count 
FROM clients
UNION ALL
SELECT 'call_sessions', COUNT(*) FROM call_sessions
UNION ALL
SELECT 'call_events', COUNT(*) FROM call_events
UNION ALL
SELECT 'call_notes', COUNT(*) FROM call_notes
UNION ALL
SELECT 'usage_tracking', COUNT(*) FROM usage_tracking
UNION ALL
SELECT 'api_logs', COUNT(*) FROM api_logs;

\echo ''
\echo '📊 Sample Call Session:'
SELECT 
    customer_name,
    customer_phone,
    customer_id_external,
    call_type,
    call_status,
    duration,
    agent_name
FROM call_sessions 
LIMIT 1;
EOF

echo ""
echo "==========================================="
echo "✅ Migration Complete!"
echo "==========================================="
echo ""
echo "📊 Database Summary:"
echo "   - 6 tables created (simplified schema)"
echo "   - 3 clients loaded"
echo "   - 5 call sessions with events and notes"
echo "   - Usage tracking initialized"
echo ""
echo "🎯 Next Steps:"
echo "   1. Update database.js to use new schema"
echo "   2. Update API endpoints"
echo "   3. Test all endpoints"
echo ""
echo "✨ Done!"

