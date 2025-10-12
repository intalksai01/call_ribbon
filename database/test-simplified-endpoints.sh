#!/bin/bash

# ============================================
# Test All Endpoints with Simplified Schema
# ============================================

API_URL="http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com"
API_KEY="southindia-finvest-api-key-2024"

echo "🧪 Testing Simplified API Endpoints"
echo "===================================="
echo ""
echo "Client: South India Finvest"
echo "API Key: $API_KEY"
echo "Base URL: $API_URL"
echo ""

# Test 1: Health Check
echo "1️⃣  Testing Health Check"
echo "GET /health"
curl -s "$API_URL/health" | jq '.'
echo ""
echo ""

# Test 2: Initialize Ribbon
echo "2️⃣  Testing Initialize Ribbon"
echo "POST /api/ribbon/init"
curl -s -X POST "$API_URL/api/ribbon/init" \
  -H "Content-Type: application/json" \
  -d "{
    \"apiKey\": \"$API_KEY\",
    \"domain\": \"test.com\"
  }" | jq '.'
echo ""
echo ""

# Test 3: Get Configuration
echo "3️⃣  Testing Get Configuration"
echo "GET /api/ribbon/config"
curl -s -H "x-api-key: $API_KEY" \
  "$API_URL/api/ribbon/config" | jq '.'
echo ""
echo ""

# Test 4: Get Basic Analytics
echo "4️⃣  Testing Basic Analytics"
echo "GET /api/ribbon/analytics"
curl -s -H "x-api-key: $API_KEY" \
  "$API_URL/api/ribbon/analytics" | jq '.'
echo ""
echo ""

# Test 5: Get Detailed Analytics
echo "5️⃣  Testing Detailed Analytics"
echo "GET /api/ribbon/analytics/detailed"
curl -s -H "x-api-key: $API_KEY" \
  "$API_URL/api/ribbon/analytics/detailed" | jq '.'
echo ""
echo ""

# Test 6: Get Call Logs
echo "6️⃣  Testing Get Call Logs"
echo "GET /api/ribbon/call-logs?page=1&pageSize=10"
curl -s -H "x-api-key: $API_KEY" \
  "$API_URL/api/ribbon/call-logs?page=1&pageSize=10" | jq '.'
echo ""
echo ""

# Test 7: Get Active Calls
echo "7️⃣  Testing Get Active Calls"
echo "GET /api/ribbon/active-calls"
curl -s -H "x-api-key: $API_KEY" \
  "$API_URL/api/ribbon/active-calls" | jq '.'
echo ""
echo ""

# Test 8: Get Customer Call History
echo "8️⃣  Testing Get Customer Call History"
echo "GET /api/ribbon/customer/LOAN001/calls"
curl -s -H "x-api-key: $API_KEY" \
  "$API_URL/api/ribbon/customer/LOAN001/calls" | jq '.'
echo ""
echo ""

# Test 9: Export Calls (JSON)
echo "9️⃣  Testing Export Calls (JSON)"
echo "GET /api/ribbon/export/calls?format=json"
curl -s -H "x-api-key: $API_KEY" \
  "$API_URL/api/ribbon/export/calls?format=json" | jq '.'
echo ""
echo ""

# Test 10: Admin - List Clients
echo "🔟 Testing Admin - List Clients"
echo "GET /api/admin/clients"
curl -s -H "x-api-key: $API_KEY" \
  "$API_URL/api/admin/clients" | jq '.'
echo ""
echo ""

# Test 11: Admin - All Clients Analytics
echo "1️⃣1️⃣  Testing Admin - All Clients Analytics"
echo "GET /api/admin/analytics/all"
curl -s -H "x-api-key: $API_KEY" \
  "$API_URL/api/admin/analytics/all" | jq '.'
echo ""
echo ""

echo "==========================================="
echo "✅ All Endpoint Tests Complete!"
echo "==========================================="
echo ""
echo "Summary:"
echo "- Tested 11 endpoints"
echo "- Using simplified database schema"
echo "- Client: South India Finvest"
echo ""

