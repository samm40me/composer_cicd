data "google_project" "project" {}

output "bd_name" {
  value = [
    for trigger in var.triggers:trigger.name
  ]
}