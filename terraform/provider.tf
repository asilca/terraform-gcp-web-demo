terraform {
  required_version = ">= 1.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
  backend "gcs" {
    bucket = "YOUR_PROJECT_ID-terraform-state"
    prefix = "tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region

}
