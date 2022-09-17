terraform {
  backend "gcs" {
    bucket  = "PROJECT_ID-PROJECT_NUMBER-tfstate"
    prefix  = "triggers"
  }
}
