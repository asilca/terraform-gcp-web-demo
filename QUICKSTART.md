# Quick Start Guide

Get up and running in 10 minutes!

## Prerequisites Checklist

- [ ] GCP account with billing enabled
- [ ] GCP project created
- [ ] Terraform installed
- [ ] Google Cloud SDK installed
- [ ] Authenticated with `gcloud auth login`

## 5-Step Deployment

### 1. Create State Bucket
```bash
export PROJECT_ID="your-project-id"
export BUCKET_NAME="${PROJECT_ID}-terraform-state"

gcloud storage buckets create gs://${BUCKET_NAME} \
  --project=${PROJECT_ID} \
  --location=us-central1 \
  --uniform-bucket-level-access
```

### 2. Configure Project
```bash
cd terraform

# Copy and edit terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set your project_id

# IMPORTANT: Edit provider.tf and update the backend bucket name
# Change "YOUR_PROJECT_ID-terraform-state" to match your actual bucket name
```

### 3. Generate SSL Certificates
```bash
cd ..
mkdir -p certs
openssl req -x509 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem \
  -days 365 -nodes \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=test.example.com"
```

### 4. Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 5. Test It
```bash
# Get the load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)

# Test in browser
echo "Visit: https://$LB_IP"

# Or test with curl
curl -k https://$LB_IP
```

## Clean Up
```bash
terraform destroy
```

## Need Help?

See the full [README.md](README.md) for detailed instructions.
