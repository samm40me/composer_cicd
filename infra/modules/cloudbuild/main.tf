data "google_project" "project" {}

resource "google_cloudbuild_trigger" "composer-pre-merge-trigger" {
  for_each = { for trigger in var.triggers : trigger.github.pull_request }
  name     = "composer-pre-merge-trigger"
  description = "composer-pre-merge-trigger"
  filename = "./pre-merge.yaml"
  project = "kev-pinto-sandbox"



  github {
    owner = "kev-pinto-cts"
    name  = "composer_cicd"
    push {
      branch = "main"
    }
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}