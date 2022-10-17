locals {
  default_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "dataproc.googleapis.com",
    "composer.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbilling.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "iamcredentials.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "notebooks.googleapis.com",
    "artifactregistry.googleapis.com",
    "aiplatform.googleapis.com",
    "container.googleapis.com"
  ]

  projects = [
    for project in var.projects.projects : {
      name = project.name
    }
  ]

  google_services = flatten([
    for project in var.projects.projects : [
      for service in distinct(concat(try(project.apis, []), local.default_apis)) : {
        service_name = service
        project_name = project.name
      }
    ]
  ])
}

resource "google_project" "my_project-in-a-folder" {
  for_each        = { for project in local.projects : project.name => project }
  name            = each.value.name
  project_id      = each.value.name
  folder_id       = var.folder
  billing_account = var.billing_account
}


resource "google_project_service" "project" {
  for_each                   = { for service in local.google_services : "${service.project_name}.${service.service_name}" => service }
  project                    = each.value.project_name
  service                    = each.value.service_name
  disable_dependent_services = true
  depends_on                 = [google_project.my_project-in-a-folder]
}

resource "google_project_iam_member" "cloudbuildiam" {
  for_each   = { for project in local.projects : project.name => project }
  project    = each.value.name
  role       = "roles/composer.environmentAndStorageObjectAdmin"
  member     = format("serviceAccount:%s@cloudbuild.gserviceaccount.com", var.project_number)
  depends_on = [google_project.my_project-in-a-folder, google_project_service.project]
}

# This Role is for the Ingerity Testing during the the pre-merge phase
resource "google_project_iam_member" "cloudbuildiamworker" {
  for_each   = { for project in local.projects : project.name => project }
  project    = each.value.name
  role       = "roles/composer.worker"
  member     = format("serviceAccount:%s@cloudbuild.gserviceaccount.com", var.project_number)
  depends_on = [google_project.my_project-in-a-folder, google_project_service.project]
}

resource "google_project_iam_member" "composersa" {
  for_each = { for project in local.projects : project.name => project }
  project  = each.value.name
  role     = "roles/composer.ServiceAgentV2Ext"
  member   = format("serviceAccount:service-%s@cloudcomposer-accounts.iam.gserviceaccount.com", google_project.my_project-in-a-folder[each.key].number)
  depends_on = [
    google_project.my_project-in-a-folder, google_project_service.project, google_project_iam_member.cloudbuildiam
  ]
}
