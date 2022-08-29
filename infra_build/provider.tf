terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.27.0"
    }
  }
}

provider "google-beta" {
  project     = "PROJECT_ID"
  region      = "LOCATION_ID"
}

provider "google" {
  project     = "PROJECT_ID"
  region      = "LOCATION_ID"
}
