terraform {
  backend "gcs" {
    bucket = "TFSTATE_BUCKET"
    prefix = "triggers"
  }
}
