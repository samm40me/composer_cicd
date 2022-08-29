terraform {
  backend "gcs" {
    bucket  = "PROJECT_ID-composercicd-tfstate"
    prefix  = "dags"
  }
}
