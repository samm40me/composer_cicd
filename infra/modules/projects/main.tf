locals {
  default_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "dataproc.googleapis.com",
    "composer.googleapis.com",
    "cloudfunctions.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com"
  ]

  projects = [
  for project in var.projects.projects : {
    name = project.name
  }
  ]

  google_services = flatten([
  for project in var.projects.projects : [
  for service in distinct(concat(try(project.apis,[]),local.default_apis)) : {
    service_name = service
    project_name = project.name
  }
  ]
  ])
}

#resource "random_id" "random_project_id_suffix" {
#  byte_length = 3
#}

resource "google_project" "my_project-in-a-folder" {
  for_each        = {for project in local.projects : project.name=>project}
  name            = each.value.name
  project_id      = each.value.name
  folder_id       = var.folder
  billing_account = var.billing_account
}


resource "google_project_service" "project" {
  for_each = { for service in local.google_services: "${service.project_name}.${service.service_name}"=>service}
  project = each.value.project_name
  service = each.value.service_name
  disable_dependent_services = true
  depends_on = [google_project.my_project-in-a-folder]
}


