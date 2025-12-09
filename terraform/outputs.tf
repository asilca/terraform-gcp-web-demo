output "load_balancer_ip" {
  description = "The public IP of the Global Load Balancer"
  value       = google_compute_global_forwarding_rule.https_forwarding_rule.ip_address
}

output "terraform_service_account_email" {
  description = "The email of the created Service Account"
  value       = google_service_account.terraform_sa.email
}
