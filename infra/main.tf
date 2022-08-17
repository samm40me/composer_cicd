locals {
  cloudbuild_config = yamldecode(file("./repoconfig.yaml"))
}

output "trigger" {
  value = [
  for trigger in local.cloudbuild_config.triggers :trigger.github.source_repo
  ]
}

resource "google_cloudbuild_trigger" "include-build-logs-trigger" {
  for_each = {for trigger in local.cloudbuild_config.triggers :trigger.name=> trigger}

  name     = each.value.name
  filename = each.value.github.source_repo

  github {
    owner = "hashicorp"
    name  = each.value.name
    push {
      branch = each.value.github.branch
    }
  }

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}