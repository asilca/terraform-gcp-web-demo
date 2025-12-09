# Terraform GCP Web Server Demo

A beginner-friendly Terraform demo that deploys a highly available web server infrastructure on Google Cloud Platform (GCP).

## Architecture Overview

```
                                    Internet
                                       |
                                       v
                        ┌──────────────────────────┐
                        │   Global Load Balancer   │
                        │   (HTTP/HTTPS)           │
                        │   - SSL Termination      │
                        │   - HTTP → HTTPS         │
                        └──────────────────────────┘
                                       |
                                       v
                        ┌──────────────────────────┐
                        │   Backend Service        │
                        │   - Health Checks        │
                        └──────────────────────────┘
                                       |
                                       v
                        ┌──────────────────────────┐
                        │  Managed Instance Group  │
                        │  (Regional MIG)          │
                        │  - Auto-scaling (1-1)    │
                        │  - Auto-healing          │
                        └──────────────────────────┘
                                       |
                                       v
                        ┌──────────────────────────┐
                        │   Compute Instances      │
                        │   - Debian 11            │
                        │   - Nginx Web Server     │
                        │   - Cat Image Page       │
                        └──────────────────────────┘
                                       |
                        ┌──────────────────────────┐
                        │   Firewall Rules         │
                        │   - Health Check Access  │
                        │   - HTTP/HTTPS Access    │
                        └──────────────────────────┘
```

## What Gets Deployed

This Terraform configuration creates:

- **Global HTTPS Load Balancer** with SSL certificate
- **HTTP to HTTPS redirect** for secure connections
- **Regional Managed Instance Group (MIG)** with auto-scaling and auto-healing
- **Compute Engine instances** running Debian 11 with Nginx
- **Firewall rules** for health checks and web traffic
- **Service account** for Terraform automation
- **Custom web page** displaying a cat image

---

## Prerequisites

### 1. GCP Account & Project
- A Google Cloud Platform account
- An existing GCP project (sandbox/test project recommended)
- Billing enabled on the project
- Owner or Editor permissions on the project

### 2. Install Terraform

#### Windows Installation

**Option A: Using Chocolatey (Recommended)**
```powershell
# Install Chocolatey if not already installed
# Run PowerShell as Administrator
choco install terraform
```

**Option B: Manual Installation**
1. Download Terraform from https://www.terraform.io/downloads
2. Extract the `terraform.exe` file
3. Move it to a directory (e.g., `C:\terraform`)
4. Add the directory to your PATH:
   - Right-click "This PC" → Properties → Advanced System Settings
   - Click "Environment Variables"
   - Under "System Variables", find "Path" and click "Edit"
   - Click "New" and add `C:\terraform`
   - Click OK on all dialogs
5. Open a new Command Prompt and verify:
```cmd
terraform version
```

#### Linux Installation

**Option A: Using Package Manager (Ubuntu/Debian)**
```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt update && sudo apt install terraform
```

**Option B: Manual Installation**
```bash
# Download Terraform
wget https://releases.hashicorp.com/terraform/1.14.0/terraform_1.14.0_linux_amd64.zip

# Unzip and move to PATH
unzip terraform_1.14.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

### 3. Install Google Cloud SDK

#### Windows
Download and run the installer from: https://cloud.google.com/sdk/docs/install

#### Linux
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

### 4. Authenticate with GCP
```bash
# Login to your GCP account
gcloud auth login

# Set application default credentials for Terraform
gcloud auth application-default login

# Set your project (replace with your project ID)
gcloud config set project YOUR_PROJECT_ID
```

---

## Initial Setup

> **⚠️ Before You Begin**: You will need to update two files with your project-specific information:
> 1. `terraform/terraform.tfvars` - Set your `project_id`
> 2. `terraform/provider.tf` - Update the GCS `bucket` name in the backend configuration

### Step 1: Create a GCS Bucket for Terraform State

Terraform stores its state in a remote backend (GCS bucket) for team collaboration and state locking.

```bash
# Replace YOUR_PROJECT_ID with your actual project ID
export PROJECT_ID="YOUR_PROJECT_ID"
export BUCKET_NAME="${PROJECT_ID}-terraform-state"

# Create the bucket
gcloud storage buckets create gs://${BUCKET_NAME} \
  --project=${PROJECT_ID} \
  --location=us-central1 \
  --uniform-bucket-level-access

# Enable versioning (recommended for state file safety)
gcloud storage buckets update gs://${BUCKET_NAME} --versioning
```

### Step 2: Configure Your Project Settings

1. **Update `terraform/terraform.tfvars`**:
```bash
cd terraform
```

Edit `terraform.tfvars` and replace the placeholder:
```hcl
project_id = "your-actual-project-id"
```

Optional: Customize other variables (see [VARIABLES.md](VARIABLES.md) for full list):
```hcl
project_id  = "your-actual-project-id"
region      = "us-central1"
zone        = "us-central1-a"
domain_name = "test.example.com"

# Autoscaling (increase max_replicas for production)
min_replicas = 1
max_replicas = 3

# Instance configuration
machine_type = "e2-small"
```

2. **Update `terraform/provider.tf`**:

Edit the backend configuration to use your bucket name (replace `YOUR_PROJECT_ID` with your actual project ID):
```hcl
backend "gcs" {
  bucket = "your-actual-project-id-terraform-state"
  prefix = "tfstate"
}
```

**Important**: The bucket name must match the bucket you created in Step 1. If you used a different naming convention, update accordingly.

### Step 3: SSL Certificates

The included certificates in `certs/` are **dummy certificates** for `test.example.com` and are for demonstration purposes only.

#### Option A: Create Your Own Self-Signed Certificates (Testing)

**Linux/macOS:**
```bash
# Create certs directory if it doesn't exist
mkdir -p certs

# Generate private key and certificate
openssl req -x509 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem \
  -days 365 -nodes \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=test.example.com"
```

**Windows (PowerShell):**
```powershell
# Ensure OpenSSL is installed (comes with Git for Windows)
# Or download from: https://slproweb.com/products/Win32OpenSSL.html

mkdir certs -Force
openssl req -x509 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem `
  -days 365 -nodes `
  -subj "/C=US/ST=State/L=City/O=Organization/CN=test.example.com"
```

#### Option B: Use Your Own Existing Certificates

If you have valid SSL certificates:

1. Copy your certificate file to `certs/cert.pem`
2. Copy your private key file to `certs/key.pem`
3. Update `domain_name` in `terraform.tfvars` to match your certificate's CN/SAN
4. Ensure the files are in PEM format

**Important**: Never commit real private keys to version control! Add them to `.gitignore`.

---

## Terraform Workflow

### Step 1: Initialize Terraform

Initialize the Terraform working directory and download required providers:

```bash
cd terraform
terraform init
```

Expected output:
```
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 2: Format and Validate

**Format your code** (ensures consistent style):
```bash
terraform fmt -recursive
```

**Validate configuration** (checks for syntax errors):
```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 3: Plan the Deployment

Generate an execution plan to see what Terraform will create:

```bash
terraform plan
```

Review the output carefully. You should see:
- Resources to be created (indicated by `+`)
- Approximately 15-20 resources including:
  - Compute instance template
  - Managed instance group
  - Load balancer components
  - Firewall rules
  - SSL certificate
  - Service account

**Save the plan** (optional but recommended):
```bash
terraform plan -out=tfplan
```

### Step 4: Apply the Configuration

Deploy the infrastructure:

```bash
# If you saved a plan
terraform apply tfplan

# Or apply directly (will prompt for confirmation)
terraform apply
```

Type `yes` when prompted to confirm.

The deployment takes approximately **5-10 minutes**. Terraform will show progress as it creates each resource.

### Step 5: Validate the Deployment

After successful deployment, Terraform will output important information:

```bash
# View outputs
terraform output
```

You should see:
- `load_balancer_ip`: The public IP address of your load balancer
- `terraform_service_account_email`: The service account email

**Test the deployment:**

1. **Get the Load Balancer IP**:
```bash
LB_IP=$(terraform output -raw load_balancer_ip)
echo $LB_IP
```

2. **Test HTTP (should redirect to HTTPS)**:
```bash
curl -I http://$LB_IP
```

3. **Test HTTPS** (with self-signed cert, use -k to skip verification):
```bash
curl -k https://$LB_IP
```

4. **View in browser**:
   - Navigate to `https://<LOAD_BALANCER_IP>`
   - You'll see a certificate warning (expected with self-signed certs)
   - Accept the warning to view the cat image page

5. **Check GCP Console**:
   - Navigate to Compute Engine → Instance Groups
   - Navigate to Network Services → Load Balancing
   - Verify instances are healthy

### Step 6: Destroy the Deployment

When you're done testing, clean up all resources to avoid charges:

```bash
terraform destroy
```

Review the resources to be destroyed and type `yes` to confirm.

**Important**: This will delete all resources created by Terraform. The GCS bucket with state files will remain.

---

## Git Workflow

### Initialize Git Repository

1. **Initialize the repository**:
```bash
# From the project root directory
git init
```

2. **Review `.gitignore`**:

Ensure your `.gitignore` includes:
```
# Terraform
**/.terraform/*
*.tfstate
*.tfstate.*
*.tfvars
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc

# Certificates (if using real certs)
certs/*.pem

# OS
.DS_Store
Thumbs.db
```

3. **Create initial commit**:
```bash
git add .
git commit -m "Initial commit: Terraform GCP web server demo"
```

4. **Create GitHub repository**:
   - Go to https://github.com/new
   - Create a new repository (e.g., `terraform-gcp-demo`)
   - Don't initialize with README (you already have one)

5. **Push to GitHub**:
```bash
# Add remote (replace with your repository URL)
git remote add origin https://github.com/YOUR_USERNAME/terraform-gcp-demo.git

# Push to master
git branch -M main
git push -u origin main
```

### Making Changes via Pull Request

Here's how to make a simple change to the startup script:

1. **Create a feature branch**:
```bash
git checkout -b update-welcome-message
```

2. **Make a visible change** to `scripts/startup-script.sh`:

Edit the file and change the welcome message:
```bash
# Change this line:
echo "<html><body><h1>Miaow!</h1><img src='/cat.jpg'/></body></html>" > /var/www/html/index.html

# To something like:
echo "<html><body><h1>Welcome to AcmeCorp! Miaow!</h1><p>This is our awesome cat page!</p><img src='/cat.jpg'/></body></html>" > /var/www/html/index.html
```

3. **Commit the change**:
```bash
git add scripts/startup-script.sh
git commit -m "Update welcome message with company branding"
```

4. **Push the branch**:
```bash
git push origin update-welcome-message
```

5. **Create Pull Request on GitHub**:
   - Go to your repository on GitHub
   - Click "Compare & pull request"
   - Add a description: "Updates the welcome message to include company branding"
   - Click "Create pull request"

6. **Review and Merge**:
   - Review the changes in the PR
   - If everything looks good, click "Merge pull request"
   - Click "Confirm merge"
   - Delete the branch (optional but recommended)

7. **Pull the changes locally**:
```bash
git checkout main
git pull origin main
```

### Applying Infrastructure Changes

After merging changes to the startup script:

1. **Review what will change**:
```bash
cd terraform
terraform plan
```

Terraform will detect that the instance template needs to be updated because the startup script changed.

2. **Apply the changes**:
```bash
terraform apply
```

3. **Understand the update process**:
   - Terraform will create a new instance template
   - The MIG will perform a rolling update
   - Old instances will be replaced with new ones running the updated script
   - The update policy is set to "PROACTIVE" with `max_surge_fixed = 3`

4. **Monitor the rollout**:
```bash
# Watch the MIG status
gcloud compute instance-groups managed list-instances web-server-mig \
  --region=us-central1
```

5. **Validate the change**:
   - Wait a few minutes for the new instance to be ready
   - Visit the load balancer IP in your browser
   - Verify the new welcome message appears

---

## Recommended Terraform Change Process

Follow this workflow for making infrastructure changes:

### 1. Planning Phase
- Identify the required change
- Review Terraform documentation for the resources involved
- Consider the impact on running infrastructure

### 2. Development Phase
```bash
# Create a feature branch
git checkout -b feature/your-change-name

# Make changes to .tf files
# Edit terraform/*.tf files as needed

# Format the code
terraform fmt -recursive

# Validate syntax
terraform validate
```

### 3. Testing Phase
```bash
# Generate and review the plan
terraform plan -out=tfplan

# Review the plan carefully:
# - What resources will be created (+)
# - What resources will be modified (~)
# - What resources will be destroyed (-)
# - Are there any unexpected changes?
```

### 4. Review Phase
```bash
# Commit your changes
git add .
git commit -m "Descriptive commit message"

# Push and create PR
git push origin feature/your-change-name
```

- Create a Pull Request on GitHub
- Have team members review the changes
- Include the `terraform plan` output in the PR description

### 5. Deployment Phase
```bash
# After PR approval and merge
git checkout main
git pull origin main

# Re-run plan to confirm
terraform plan

# Apply the changes
terraform apply

# Verify the deployment
terraform output
```

### 6. Validation Phase
- Test the deployed infrastructure
- Check GCP Console for resource status
- Monitor logs and metrics
- Verify application functionality

### 7. Rollback (if needed)
```bash
# If something goes wrong, you can:

# Option 1: Revert the commit
git revert <commit-hash>
git push origin main
terraform apply

# Option 2: Restore from a previous state
terraform state list
# Manually fix issues or restore from backup
```

---

## Common Commands Reference

### Terraform Commands
```bash
terraform init          # Initialize working directory
terraform fmt          # Format code
terraform validate     # Validate configuration
terraform plan         # Preview changes
terraform apply        # Apply changes
terraform destroy      # Destroy all resources
terraform output       # Show outputs
terraform state list   # List resources in state
terraform show         # Show current state
```

### GCP Commands
```bash
# List compute instances
gcloud compute instances list

# List instance groups
gcloud compute instance-groups managed list

# View load balancers
gcloud compute forwarding-rules list

# View firewall rules
gcloud compute firewall-rules list

# SSH into an instance
gcloud compute ssh INSTANCE_NAME --zone=us-central1-a
```

---

## Troubleshooting

### Issue: "Error creating instance template"
- **Cause**: Insufficient permissions or quota limits
- **Solution**: Verify you have Editor/Owner role and check project quotas

### Issue: "Backend initialization failed"
- **Cause**: GCS bucket doesn't exist or no access
- **Solution**: Create the bucket and ensure you have Storage Admin permissions

### Issue: "Certificate validation failed"
- **Cause**: Certificate and private key don't match
- **Solution**: Regenerate certificates ensuring they're a matching pair

### Issue: "Instances not healthy"
- **Cause**: Startup script failed or firewall blocking health checks
- **Solution**: SSH into instance and check `/var/log/syslog` for errors

### Issue: "Cannot access load balancer"
- **Cause**: DNS not configured or health checks failing
- **Solution**: Use the IP address directly and verify instances are healthy

---

## Cost Considerations

This demo uses minimal resources but will incur small charges:

- **Compute Engine**: e2-micro instance (~$7/month if running 24/7)
- **Load Balancer**: ~$18/month + data transfer
- **GCS Storage**: Minimal (<$1/month for state files)

**Estimated total**: ~$25-30/month if left running

**Cost-saving tips**:
- Run `terraform destroy` when not actively testing
- Use `gcloud compute instances stop` to stop instances without destroying
- Set up budget alerts in GCP Console

---

## Next Steps

- Customize the web application in `scripts/startup-script.sh`
- Add more instances by adjusting autoscaler min/max replicas
- Implement Cloud Armor for DDoS protection
- Add Cloud CDN for better performance
- Set up monitoring and alerting
- Implement CI/CD with Cloud Build or GitHub Actions
- Use Terraform workspaces for multiple environments

---

## Additional Resources

- [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Load Balancing Documentation](https://cloud.google.com/load-balancing/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [GCP Free Tier](https://cloud.google.com/free)

---

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review Terraform and GCP documentation
3. Check GCP Console logs and monitoring
4. Open an issue in this repository

---

## License

This is a demo project for educational purposes.
