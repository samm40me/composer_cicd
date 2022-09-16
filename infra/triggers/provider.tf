#locals {
#  terraform_service_account = "terraform@kev-pinto-sandbox.iam.gserviceaccount.com"
#}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.27.0"
    }
  }
}

#provider "google" {
#  alias  = "impersonation"
#  scopes = [
#    "https://www.googleapis.com/auth/cloud-platform",
#    "https://www.googleapis.com/auth/userinfo.email",
#  ]
#}
#
#data "google_service_account_access_token" "default" {
#  provider               = google.impersonation
#  target_service_account = local.terraform_service_account
#  scopes                 = ["userinfo-email", "cloud-platform"]
#  lifetime               = "1200s"
#}


provider "google" {
  project         = "PROJECT_ID"
  region          = "LOCATION_ID"
#  access_token    = data.google_service_account_access_token.default.access_token
#  request_timeout = "60s"
}
