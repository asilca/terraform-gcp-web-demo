# Terraform Variables Reference

This document describes all configurable variables in this Terraform configuration.

## Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `project_id` | Your GCP Project ID | `my-gcp-project-123` |

## Optional Variables

### Regional Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `us-central1` | GCP region for resources |
| `zone` | `us-central1-a` | GCP zone for the MIG |
| `domain_name` | `cloudfreak.co.uk` | Domain name for SSL certificate |

### SSL Certificates

| Variable | Default | Description |
|----------|---------|-------------|
| `ssl_certificate_path` | `../certs/cert.pem` | Path to SSL certificate file |
| `ssl_private_key_path` | `../certs/key.pem` | Path to SSL private key file |

### Compute Instance Configuration

| Variable | Default | Description | Options |
|----------|---------|-------------|---------|
| `machine_type` | `e2-micro` | Machine type for instances | `e2-micro`, `e2-small`, `e2-medium`, `n1-standard-1`, etc. |
| `disk_image` | `debian-cloud/debian-11` | Boot disk image | Any valid GCP image |
| `disk_size_gb` | `10` | Boot disk size in GB | Minimum 10 GB |

### Autoscaling Configuration

| Variable | Default | Description | Range |
|----------|---------|-------------|-------|
| `min_replicas` | `1` | Minimum number of instances | 0-1000 |
| `max_replicas` | `1` | Maximum number of instances | 1-1000 |
| `cpu_utilization_target` | `0.6` | Target CPU utilization for scaling | 0.0-1.0 |
| `cooldown_period` | `60` | Cooldown period in seconds | 60+ |

**Example for production auto-scaling:**
```hcl
min_replicas           = 2
max_replicas           = 10
cpu_utilization_target = 0.7
cooldown_period        = 120
```

### MIG Update Policy

| Variable | Default | Description |
|----------|---------|-------------|
| `max_surge_fixed` | `3` | Max instances to create during rolling update |
| `max_unavailable_fixed` | `0` | Max instances unavailable during update |
| `auto_healing_initial_delay_sec` | `300` | Delay before auto-healing starts (seconds) |

### Health Check & Backend

| Variable | Default | Description |
|----------|---------|-------------|
| `health_check_port` | `80` | Port for health checks |
| `backend_timeout_sec` | `30` | Backend service timeout in seconds |

### Network Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `network_name` | `default` | VPC network name to use |

### Resource Naming

| Variable | Default | Description | Used For |
|----------|---------|-------------|----------|
| `resource_prefix` | `web-server` | Prefix for compute resources | Instances, MIG, autoscaler, firewall rules |
| `project_name` | `pets` | Name for load balancer resources | Load balancer, URL map, SSL cert |

### OS Patching Configuration

| Variable | Default | Description | Options |
|----------|---------|-------------|---------|
| `patch_schedule_timezone` | `America/New_York` | Timezone for patch schedule | Any valid timezone |
| `patch_schedule_day` | `TUESDAY` | Day of week for patching | `MONDAY`, `TUESDAY`, `WEDNESDAY`, `THURSDAY`, `FRIDAY`, `SATURDAY`, `SUNDAY` |
| `patch_schedule_hour` | `2` | Hour of day for patching | 0-23 |
| `patch_schedule_minute` | `0` | Minute of hour for patching | 0-59 |

## Common Configuration Scenarios

### Development Environment
```hcl
project_id             = "dev-project-123"
machine_type           = "e2-micro"
min_replicas           = 1
max_replicas           = 1
resource_prefix        = "dev-web"
project_name           = "dev-pets"
```

### Staging Environment
```hcl
project_id             = "staging-project-456"
machine_type           = "e2-small"
min_replicas           = 1
max_replicas           = 3
cpu_utilization_target = 0.7
resource_prefix        = "staging-web"
project_name           = "staging-pets"
```

### Production Environment
```hcl
project_id                     = "prod-project-789"
machine_type                   = "e2-medium"
min_replicas                   = 2
max_replicas                   = 10
cpu_utilization_target         = 0.7
cooldown_period                = 120
max_surge_fixed                = 5
auto_healing_initial_delay_sec = 600
backend_timeout_sec            = 60
resource_prefix                = "prod-web"
project_name                   = "prod-pets"
```

### Custom Network Configuration
```hcl
project_id      = "my-project"
network_name    = "my-custom-vpc"
resource_prefix = "app-server"
project_name    = "my-app"
```

### Different Region
```hcl
project_id  = "my-project"
region      = "europe-west1"
zone        = "europe-west1-b"
domain_name = "eu.example.com"
```

### Custom Patching Schedule
```hcl
# Patch on Sundays at 3:30 AM Pacific Time
patch_schedule_timezone = "America/Los_Angeles"
patch_schedule_day      = "SUNDAY"
patch_schedule_hour     = 3
patch_schedule_minute   = 30
```

## What Was Parameterized

Previously hardcoded values that are now configurable:

### Compute Resources
- ✅ Machine type (`e2-micro`)
- ✅ Disk image (`debian-cloud/debian-11`)
- ✅ Disk size (now configurable, default 10 GB)
- ✅ Resource naming prefixes (`web-server-*`)

### Autoscaling
- ✅ Min/max replicas (was hardcoded to 1/1)
- ✅ CPU utilization target (was 0.6)
- ✅ Cooldown period (was 60 seconds)

### MIG Update Policy
- ✅ Max surge (was 3)
- ✅ Max unavailable (was 0)
- ✅ Auto-healing delay (was 300 seconds)

### Load Balancer
- ✅ Health check port (was 80)
- ✅ Backend timeout (was 30 seconds)
- ✅ Resource names (`pets-*`, `cat-*`)

### Network
- ✅ VPC network name (was hardcoded to "default")
- ✅ Firewall rule names

### OS Patching
- ✅ Patch schedule timezone (was `America/New_York`)
- ✅ Patch day (was `TUESDAY`)
- ✅ Patch time (was 2:00 AM)

## Usage

1. Copy the example file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your values:
```bash
nano terraform.tfvars
# or
vim terraform.tfvars
```

3. Apply the configuration:
```bash
terraform plan
terraform apply
```

## Best Practices

1. **Never commit `terraform.tfvars`** - It may contain sensitive information
2. **Use different tfvars files for different environments**:
   - `dev.tfvars`
   - `staging.tfvars`
   - `prod.tfvars`
3. **Apply with specific tfvars file**:
   ```bash
   terraform apply -var-file="prod.tfvars"
   ```
4. **Use Terraform workspaces** for managing multiple environments
5. **Document any custom values** in your tfvars file with comments

## Validation

After making changes, always validate:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

Review the plan output carefully before applying changes.
