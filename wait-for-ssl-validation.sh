#!/bin/bash

# Monitor SSL certificate validation status

CERT_ARN="arn:aws:acm:us-east-1:844605843483:certificate/fa9fae7d-7fa0-4f6e-b06a-4d4e878047cd"
DISTRIBUTION_ID="E23RHJVEDGE3B2"

echo "⏳ Monitoring SSL Certificate Validation"
echo "========================================="
echo ""
echo "Certificate: $CERT_ARN"
echo "Checking every 30 seconds..."
echo ""

# Monitor for up to 30 minutes
COUNTER=0
MAX_ATTEMPTS=60

while [ $COUNTER -lt $MAX_ATTEMPTS ]; do
    STATUS=$(aws acm describe-certificate \
        --certificate-arn "$CERT_ARN" \
        --region us-east-1 \
        --output json | jq -r '.Certificate.Status')
    
    TIMESTAMP=$(date '+%H:%M:%S')
    
    if [ "$STATUS" = "ISSUED" ]; then
        echo ""
        echo "========================================="
        echo "✅ Certificate ISSUED!"
        echo "========================================="
        echo ""
        echo "🎉 SSL Certificate is ready!"
        echo ""
        echo "🚀 Now updating CloudFront..."
        echo ""
        
        # Auto-run the CloudFront update
        chmod +x update-cloudfront-with-ssl.sh
        ./update-cloudfront-with-ssl.sh
        
        exit 0
    elif [ "$STATUS" = "FAILED" ]; then
        echo "❌ Certificate validation FAILED"
        echo "   Please check DNS records and try again"
        exit 1
    else
        echo "[$TIMESTAMP] Status: $STATUS (checking again in 30 seconds...)"
        sleep 30
        COUNTER=$((COUNTER + 1))
    fi
done

echo ""
echo "⏰ Validation still pending after 30 minutes"
echo "   This can take up to 72 hours in some cases"
echo "   Current status: $STATUS"
echo ""
echo "Keep checking manually:"
echo "   aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1 | jq '.Certificate.Status'"

