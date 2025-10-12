#!/bin/bash

# Setup PostgreSQL RDS in AWS Mumbai (ap-south-1)
# This script creates RDS instance and initializes the database

set -e

REGION="ap-south-1"
DB_INSTANCE_ID="intalksai-call-ribbon-db"
DB_NAME="call_ribbon_db"
DB_USERNAME="call_ribbon_admin"
DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
DB_INSTANCE_CLASS="db.t3.micro" # Free tier eligible
STORAGE_SIZE=20 # GB
STORAGE_TYPE="gp3"

echo "🗄️  Setting up PostgreSQL RDS in Mumbai"
echo "========================================="
echo ""

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found"
    exit 1
fi

echo "✅ AWS CLI found"
echo ""

# Get default VPC
echo "📋 Getting VPC information..."
VPC_ID=$(aws ec2 describe-vpcs --region $REGION --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)
echo "   VPC ID: $VPC_ID"

# Create DB subnet group
echo ""
echo "🌐 Creating DB subnet group..."
SUBNETS=$(aws ec2 describe-subnets --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output json)

aws rds create-db-subnet-group \
    --db-subnet-group-name "${DB_INSTANCE_ID}-subnet-group" \
    --db-subnet-group-description "Subnet group for ${DB_INSTANCE_ID}" \
    --subnet-ids $(echo $SUBNETS | jq -r '.[]' | tr '\n' ' ') \
    --region $REGION 2>/dev/null || echo "   Subnet group already exists"

# Create security group
echo ""
echo "🔒 Creating security group..."
SG_ID=$(aws ec2 create-security-group \
    --group-name "${DB_INSTANCE_ID}-sg" \
    --description "Security group for ${DB_INSTANCE_ID}" \
    --vpc-id $VPC_ID \
    --region $REGION \
    --output text 2>/dev/null || \
    aws ec2 describe-security-groups \
        --region $REGION \
        --filters "Name=group-name,Values=${DB_INSTANCE_ID}-sg" \
        --query 'SecurityGroups[0].GroupId' \
        --output text)

echo "   Security Group ID: $SG_ID"

# Allow PostgreSQL access from anywhere (restrict in production!)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 5432 \
    --cidr 0.0.0.0/0 \
    --region $REGION 2>/dev/null || echo "   Port 5432 already open"

# Create RDS instance
echo ""
echo "🚀 Creating PostgreSQL RDS instance..."
echo "   Instance ID: $DB_INSTANCE_ID"
echo "   Database Name: $DB_NAME"
echo "   Username: $DB_USERNAME"
echo "   Password: $DB_PASSWORD"
echo "   Instance Class: $DB_INSTANCE_CLASS"
echo "   Storage: ${STORAGE_SIZE}GB ($STORAGE_TYPE)"
echo ""
echo "   ⏳ This will take 5-10 minutes..."
echo ""

aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE_ID \
    --db-instance-class $DB_INSTANCE_CLASS \
    --engine postgres \
    --engine-version 16.10 \
    --master-username $DB_USERNAME \
    --master-user-password "$DB_PASSWORD" \
    --allocated-storage $STORAGE_SIZE \
    --storage-type $STORAGE_TYPE \
    --db-name $DB_NAME \
    --vpc-security-group-ids $SG_ID \
    --db-subnet-group-name "${DB_INSTANCE_ID}-subnet-group" \
    --backup-retention-period 7 \
    --preferred-backup-window "03:00-04:00" \
    --preferred-maintenance-window "mon:04:00-mon:05:00" \
    --publicly-accessible \
    --storage-encrypted \
    --region $REGION \
    --tags "Key=Name,Value=IntalksAI Call Ribbon DB" "Key=Environment,Value=Production"

echo "✅ RDS instance creation initiated"
echo ""

# Wait for instance to be available
echo "⏳ Waiting for RDS instance to be available..."
echo "   This typically takes 5-10 minutes..."
echo ""

aws rds wait db-instance-available \
    --db-instance-identifier $DB_INSTANCE_ID \
    --region $REGION

echo ""
echo "✅ RDS instance is available!"
echo ""

# Get endpoint
DB_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier $DB_INSTANCE_ID \
    --region $REGION \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

DB_PORT=$(aws rds describe-db-instances \
    --db-instance-identifier $DB_INSTANCE_ID \
    --region $REGION \
    --query 'DBInstances[0].Endpoint.Port' \
    --output text)

echo "========================================="
echo "✅ PostgreSQL RDS Setup Complete!"
echo "========================================="
echo ""
echo "📋 Connection Details:"
echo "   Endpoint: $DB_ENDPOINT"
echo "   Port: $DB_PORT"
echo "   Database: $DB_NAME"
echo "   Username: $DB_USERNAME"
echo "   Password: $DB_PASSWORD"
echo ""
echo "🔗 Connection String:"
echo "   postgresql://$DB_USERNAME:$DB_PASSWORD@$DB_ENDPOINT:$DB_PORT/$DB_NAME"
echo ""

# Save connection info
cat > ../rds-connection-info.txt <<EOF
PostgreSQL RDS - Mumbai
========================

Created: $(date)
Region: ap-south-1 (Mumbai)
Instance ID: $DB_INSTANCE_ID

Connection Details:
-------------------
Host: $DB_ENDPOINT
Port: $DB_PORT
Database: $DB_NAME
Username: $DB_USERNAME
Password: $DB_PASSWORD

Connection String (for Node.js):
---------------------------------
DATABASE_URL=postgresql://$DB_USERNAME:$DB_PASSWORD@$DB_ENDPOINT:$DB_PORT/$DB_NAME

Connection String (with SSL):
------------------------------
DATABASE_URL=postgresql://$DB_USERNAME:$DB_PASSWORD@$DB_ENDPOINT:$DB_PORT/$DB_NAME?sslmode=require

psql Command:
-------------
psql -h $DB_ENDPOINT -p $DB_PORT -U $DB_USERNAME -d $DB_NAME

Next Steps:
-----------
1. Initialize schema:
   psql -h $DB_ENDPOINT -p $DB_PORT -U $DB_USERNAME -d $DB_NAME -f schema.sql

2. Update api/.env:
   DATABASE_URL=postgresql://$DB_USERNAME:$DB_PASSWORD@$DB_ENDPOINT:$DB_PORT/$DB_NAME

3. Install pg module:
   cd api && npm install pg

4. Update server.js to use PostgreSQL

5. Redeploy API:
   eb deploy production-mumbai --region ap-south-1

Management:
-----------
View logs:
aws rds describe-db-log-files --db-instance-identifier $DB_INSTANCE_ID --region $REGION

Create snapshot:
aws rds create-db-snapshot --db-instance-identifier $DB_INSTANCE_ID --db-snapshot-identifier ${DB_INSTANCE_ID}-snapshot-\$(date +%Y%m%d) --region $REGION

Modify instance:
aws rds modify-db-instance --db-instance-identifier $DB_INSTANCE_ID --region $REGION

Delete (when needed):
aws rds delete-db-instance --db-instance-identifier $DB_INSTANCE_ID --skip-final-snapshot --region $REGION

Security:
---------
⚠️  Database is publicly accessible for easy setup
✅ Restrict security group in production
✅ Use SSL connections
✅ Rotate password regularly
✅ Enable automated backups (configured: 7 days)

Cost Estimate:
--------------
db.t3.micro: ~$15/month
20GB storage: ~$2.30/month
Backup storage: ~$0.10/GB/month
Total: ~$18-20/month
EOF

echo "💾 Connection info saved to: ../rds-connection-info.txt"
echo ""
echo "🎯 Next Steps:"
echo ""
echo "1. Initialize the database schema:"
echo "   psql -h $DB_ENDPOINT -p $DB_PORT -U $DB_USERNAME -d $DB_NAME -f schema.sql"
echo "   (You'll be prompted for password: $DB_PASSWORD)"
echo ""
echo "2. Install PostgreSQL client (if not installed):"
echo "   brew install postgresql"
echo ""
echo "3. Test connection:"
echo "   psql -h $DB_ENDPOINT -p $DB_PORT -U $DB_USERNAME -d $DB_NAME"
echo ""
echo "✨ Done!"

