# --- Service Account for Terraform ---
resource "google_service_account" "terraform_sa" {
  account_id   = "terraform-automation-sa"
  display_name = "Terraform Automation Service Account"
}

resource "google_project_iam_member" "terraform_sa_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}
