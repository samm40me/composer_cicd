resource "google_artifact_registry_repository" "aftest" {
  provider      = google-beta
  project       = var.project
  location      = var.location
  repository_id = "airflow-test-container"
  description   = "Repo to store Airflow Test Container"
  format        = "DOCKER"
}
