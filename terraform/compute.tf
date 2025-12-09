# --- Instance Template ---
resource "google_compute_instance_template" "web_server_template" {
  name_prefix  = "${var.resource_prefix}-template-"
  machine_type = var.machine_type

  # Pillar 3: Environment Management - Explicitly using Debian as requested
  disk {
    source_image = var.disk_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.disk_size_gb
  }

  network_interface {
    network = data.google_compute_network.default.name
    access_config {
      # Ephemeral IP
    }
  }

  tags = [var.resource_prefix, "http-server", "https-server"]

  # Enable VM Manager (OS Config)
  metadata = {
    enable-osconfig         = "TRUE"
    enable-guest-attributes = "TRUE"
    startup-script          = file("${path.module}/../scripts/startup-script.sh")
  }

  service_account {
    # Using the Compute Engine default SA for simplicity in sandbox, 
    # but limiting scopes is a good practice.
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- Managed Instance Group (MIG) ---
resource "google_compute_region_instance_group_manager" "web_server_mig" {
  name               = "${var.resource_prefix}-mig"
  base_instance_name = var.resource_prefix
  region             = var.region

  version {
    instance_template = google_compute_instance_template.web_server_template.id
  }

  # Named Port mapping for the Load Balancer (maps "http" -> port 80)
  named_port {
    name = "http"
    port = 80
  }

  # Automatic Update Policy (Proactive)
  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = var.max_surge_fixed
    max_unavailable_fixed = var.max_unavailable_fixed
    replacement_method    = "SUBSTITUTE"
  }

  # Health check for the MIG auto-healing (distinct from LB health check)
  auto_healing_policies {
    health_check      = google_compute_health_check.tcp_health_check.id
    initial_delay_sec = var.auto_healing_initial_delay_sec
  }
}

# --- Autoscaler ---
resource "google_compute_region_autoscaler" "web_server_autoscaler" {
  name   = "${var.resource_prefix}-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.web_server_mig.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period

    cpu_utilization {
      target = var.cpu_utilization_target
    }
  }
}
