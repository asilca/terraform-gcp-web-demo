# Using the default VPC for the sandbox, but defining specific firewall rules
# to adhere to "Least Privilege" (Pillar 5).

data "google_compute_network" "default" {
  name = var.network_name
}

# Allow Health Checks from Google's centralized health check ranges
resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.resource_prefix}-allow-health-check"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = [var.resource_prefix]
}

# Allow HTTP/HTTPS to backends (if accessed directly, though LB proxies traffic)
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.resource_prefix}-allow-http-https"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.resource_prefix]
}
