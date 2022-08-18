locals {
  cloudbuild_config = yamldecode(file("./repoconfig.yaml"))
}

output "trigger" {
  value = [
  for trigger in local.cloudbuild_config.triggers :trigger.github.source_repo
  ]
}

resource "google_cloudbuild_trigger" "composer-pre-merge-trigger" {
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