terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.27.0"
    }
  }
}

provider "google" {
  project = "PROJECT_ID"
  region  = "LOCATION_ID"
}
