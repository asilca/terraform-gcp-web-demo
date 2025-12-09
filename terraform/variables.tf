variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for the MIG"
  type        = string
  default     = "us-central1-a"
}

variable "domain_name" {
  description = "The domain name for the certificate"
  type        = string
  default     = "cloudfreak.co.uk"
}

# Paths to your certificate files
# In a real demo, place these files in the same directory or update paths
variable "ssl_certificate_path" {
  description = "Path to the SSL certificate file (PEM)"
  type        = string
  default     = "../certs/cert.pem"
}

variable "ssl_private_key_path" {
  description = "Path to the SSL private key file (PEM)"
  type        = string
  default     = "../certs/key.pem"
}

# Compute Instance Configuration
variable "machine_type" {
  description = "Machine type for compute instances"
  type        = string
  default     = "e2-micro"
}

variable "disk_image" {
  description = "Boot disk image for compute instances"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10
}

# Autoscaling Configuration
variable "min_replicas" {
  description = "Minimum number of instances in the MIG"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of instances in the MIG"
  type        = number
  default     = 1
}

variable "cpu_utilization_target" {
  description = "Target CPU utilization for autoscaling (0.0 to 1.0)"
  type        = number
  default     = 0.6
}

variable "cooldown_period" {
  description = "Cooldown period in seconds for autoscaling"
  type        = number
  default     = 60
}

# MIG Update Policy
variable "max_surge_fixed" {
  description = "Maximum number of instances to create during rolling update"
  type        = number
  default     = 3
}

variable "max_unavailable_fixed" {
  description = "Maximum number of instances that can be unavailable during update"
  type        = number
  default     = 0
}

variable "auto_healing_initial_delay_sec" {
  description = "Initial delay in seconds before auto-healing starts"
  type        = number
  default     = 300
}

# Health Check Configuration
variable "health_check_port" {
  description = "Port for health checks"
  type        = number
  default     = 80
}

variable "backend_timeout_sec" {
  description = "Backend service timeout in seconds"
  type        = number
  default     = 30
}

# Network Configuration
variable "network_name" {
  description = "Name of the VPC network to use"
  type        = string
  default     = "default"
}

# Resource Naming
variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "web-server"
}

variable "project_name" {
  description = "Project name for resource naming (e.g., 'pets', 'cat')"
  type        = string
  default     = "pets"
}

# OS Patching Configuration
variable "patch_schedule_timezone" {
  description = "Timezone for patch schedule"
  type        = string
  default     = "America/New_York"
}

variable "patch_schedule_day" {
  description = "Day of week for patching (MONDAY, TUESDAY, etc.)"
  type        = string
  default     = "TUESDAY"
}

variable "patch_schedule_hour" {
  description = "Hour of day for patching (0-23)"
  type        = number
  default     = 2
}

variable "patch_schedule_minute" {
  description = "Minute of hour for patching (0-59)"
  type        = number
  default     = 0
}
