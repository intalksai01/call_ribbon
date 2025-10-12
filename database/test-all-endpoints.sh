#!/bin/bash

# Test all API endpoints with South India Finvest data
# Run after database initialization

API_URL="http://production-mumbai.eba-jfgji9nq.ap-south-1.elasticbeanstalk.com"
API_KEY="southindia-finvest-api-key-2024"

echo "🧪 Testing All API Endpoints"
echo "============================="
echo ""
echo "Client: South India Finvest Pvt Ltd"
echo "API Key: $API_KEY"
echo "Base URL: $API_URL"
echo ""

# Test 1: Health Check
echo "1️⃣  Testing Health Check"
echo "GET /health"
curl -s "$API_URL/health" | jq .
echo ""

# Test 2: Initialize Ribbon
echo "2️⃣  Testing Initialize Ribbon"
echo "POST /api/ribbon/init"
curl -s -X POST "$API_URL/api/ribbon/init" \
  -H "Content-Type: application/json" \
  -d "{\"apiKey\":\"$API_KEY\",\"domain\":\"southindiafinvest.com\"}" | jq .
echo ""

# Test 3: Get Configuration
echo "3️⃣  Testing Get Configuration"
echo "GET /api/ribbon/config"
curl -s "$API_URL/api/ribbon/config" \
  -H "X-API-Key: $API_KEY" | jq .
echo ""

# Test 4: Get Basic Analytics
echo "4️⃣  Testing Basic Analytics"
echo "GET /api/ribbon/analytics"
curl -s "$API_URL/api/ribbon/analytics" \
  -H "X-API-Key: $API_KEY" | jq .
echo ""

# Test 5: Get Detailed Analytics
echo "5️⃣  Testing Detailed Analytics"
echo "GET /api/ribbon/analytics/detailed"
curl -s "$API_URL/api/ribbon/analytics/detailed" \
  -H "X-API-Key: $API_KEY" | jq .
echo ""

# Test 6: Get Call Logs
echo "6️⃣  Testing Get Call Logs"
echo "GET /api/ribbon/call-logs?page=1&pageSize=10"
curl -s "$API_URL/api/ribbon/call-logs?page=1&pageSize=10" \
  -H "X-API-Key: $API_KEY" | jq .
echo ""

# Test 7: Get Active Calls
echo "7️⃣  Testing Get Active Calls"
echo "GET /api/ribbon/active-calls"
curl -s "$API_URL/api/ribbon/active-calls" \
  -H "X-API-Key: $API_KEY" | jq .
echo ""

# Test 8: Save Customer
echo "8️⃣  Testing Save Customer"
echo "POST /api/ribbon/customer"
curl -s -X POST "$API_URL/api/ribbon/customer" \
  -H "Content-Type: application/json" \
  -d "{
    \"apiKey\":\"$API_KEY\",
    \"customerData\":{
      \"customerId\":\"TEST001\",
      \"name\":\"Test Customer\",
      \"email\":\"test@example.com\",
      \"phoneNumber\":\"+919999888877\",
      \"customFields\":{
        \"loanAmount\":100000,
        \"loanType\":\"Personal Loan\"
      }
    }
  }" | jq .
echo ""

# Test 9: Get Customer Info
echo "9️⃣  Testing Get Customer Info"
echo "GET /api/ribbon/customer/LOAN001"
curl -s "$API_URL/api/ribbon/customer/LOAN001" \
  -H "X-API-Key: $API_KEY" | jq .
echo ""

# Test 10: Get Customer Call History
echo "🔟 Testing Get Customer Call History"
echo "GET /api/ribbon/customer/LOAN001/calls"
curl -s "$API_URL/api/ribbon/customer/LOAN001/calls?limit=5" \
  -H "X-API-Key: $API_KEY" | jq .
echo ""

# Test 11: Export Calls (JSON)
echo "1️⃣1️⃣  Testing Export Calls (JSON)"
echo "GET /api/ribbon/export/calls?format=json"
curl -s "$API_URL/api/ribbon/export/calls?format=json" \
  -H "X-API-Key: $API_KEY" | jq .
echo ""

# Test 12: Export Calls (CSV)
echo "1️⃣2️⃣  Testing Export Calls (CSV)"
echo "GET /api/ribbon/export/calls?format=csv"
curl -s "$API_URL/api/ribbon/export/calls?format=csv" \
  -H "X-API-Key: $API_KEY" | head -10
echo ""

# Test 13: Log Call Event
echo "1️⃣3️⃣  Testing Log Call Event"
echo "POST /api/ribbon/log-call"
curl -s -X POST "$API_URL/api/ribbon/log-call" \
  -H "Content-Type: application/json" \
  -d "{
    \"apiKey\":\"$API_KEY\",
    \"event\":\"connected\",
    \"data\":{
      \"callSid\":\"CA123TEST\",
      \"phoneNumber\":\"+919876543210\",
      \"callDirection\":\"outbound\",
      \"customerData\":{
        \"customerId\":\"LOAN001\",
        \"name\":\"Rajesh Kumar\"
      }
    },
    \"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
    \"domain\":\"southindiafinvest.com\"
  }" | jq .
echo ""

echo "==========================================="
echo "✅ All Endpoint Tests Complete!"
echo "==========================================="
echo ""
echo "Summary:"
echo "- Tested 13 endpoints"
echo "- Client: South India Finvest"
echo "- API Key: $API_KEY"
echo ""
echo "📊 View results above to verify:"
echo "   ✅ All endpoints responding"
echo "   ✅ Data is persisting"
echo "   ✅ Analytics calculating correctly"
echo "   ✅ Customer data retrievable"
echo ""

