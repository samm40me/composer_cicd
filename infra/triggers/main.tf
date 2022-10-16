locals {
  cloudbuild_config = yamldecode(file("../../config/repoconfig.yaml"))

  triggers = [
    for trigger in local.cloudbuild_config.triggers : {
      name                = trigger.name
      project             = try(trigger.project, data.google_project.project.project_id)
      description         = try(trigger.description, trigger.name)
      tags                = try(trigger.tags, ["demo", "cicd"])
      disabled            = try(trigger.disabled, false)
      filename            = trigger.filename
      include_build_logs  = try(trigger.include_build_logs, "INCLUDE_BUILD_LOGS_WITH_STATUS")
      github              = try(trigger.github, null)
      github_pull_request = try(trigger.github.pull_request, null)
      github_push         = try(trigger.github.push, null)
      approval_required   = try(trigger.approval_required, false)
    }
  ]
}

data "google_project" "project" {}

resource "google_cloudbuild_trigger" "build_trigger" {
  for_each           = { for trg in local.triggers : trg.name => trg }
  name               = each.value.name
  description        = each.value.description
  filename           = each.value.filename
  project            = data.google_project.project.project_id
  include_build_logs = each.value.include_build_logs

  dynamic "github" {
    for_each = each.value.github != null ? { run = 1 } : {}
    content {
      owner = each.value.github.owner
      name  = each.value.github.name
      dynamic "push" {
        for_each = each.value.github_push != null ? { run = 1 } : {}
        content {
          branch       = each.value.github_push.branch
          invert_regex = try(each.value.github_pull_request.invert_regex, false)
        }
      }
      dynamic "pull_request" {
        for_each = each.value.github_pull_request != null ? { run = 1 } : {}
        content {
          branch          = each.value.github_pull_request.branch
          comment_control = try(each.value.github_pull_request.comment_control, "COMMENTS_DISABLED")
          invert_regex    = try(each.value.github_pull_request.invert_regex, false)
        }
      }
    }
  }
  dynamic "approval_config" {
    for_each = each.value.approval_required != null ? { run = 1 } : {}
    content {
      approval_required = try(each.value.approval_required, false)
    }
  }
}
