# --- Health Check ---
resource "google_compute_health_check" "tcp_health_check" {
  name = "${var.resource_prefix}-health-check"

  tcp_health_check {
    port = var.health_check_port
  }
}

# --- Backend Service (Compute) ---
resource "google_compute_backend_service" "cat_backend_service" {
  name          = "${var.project_name}-backend-service"
  protocol      = "HTTP"
  port_name     = "http"
  timeout_sec   = var.backend_timeout_sec
  health_checks = [google_compute_health_check.tcp_health_check.id]

  backend {
    group = google_compute_region_instance_group_manager.web_server_mig.instance_group
  }
}

# --- URL Map (Routing Rules) ---
resource "google_compute_url_map" "default" {
  name = "${var.project_name}-url-map"
  # Set the default service to the Compute Backend (VMs)
  default_service = google_compute_backend_service.cat_backend_service.id

  host_rule {
    hosts        = [var.domain_name]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    # Set the default for the path matcher as well
    default_service = google_compute_backend_service.cat_backend_service.id

    path_rule {
      paths   = ["/cat.jpg", "/cat/*"]
      service = google_compute_backend_service.cat_backend_service.id
    }

  }
}

# --- SSL Certificate ---
resource "google_compute_ssl_certificate" "pets_cert" {
  name        = "${var.project_name}-cert"
  private_key = file(var.ssl_private_key_path)
  certificate = file(var.ssl_certificate_path)
}

# --- HTTPS Proxy & Forwarding Rule ---
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "${var.project_name}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_ssl_certificate.pets_cert.id]
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name       = "${var.project_name}-https-forwarding-rule"
  target     = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
}

# --- HTTP to HTTPS Redirect ---
resource "google_compute_url_map" "http_redirect" {
  name = "http-redirect"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "${var.project_name}-http-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
}
