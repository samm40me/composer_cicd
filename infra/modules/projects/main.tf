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
    "compute.googleapis.com",
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

resource "google_composer_environment" "composer2" {
  for_each = { for project in local.projects : project.name => project }
  name     = each.value.name
  project  = each.value.name
  region   = var.location

  config {
    node_config {
      service_account = format("%s-compute@developer.gserviceaccount.com", google_project.my_project-in-a-folder[each.key].number)
    }
    software_config {
      image_version = "composer-2.0.28-airflow-2.3.3"
      airflow_config_overrides = {
        core-dags_are_paused_at_creation = "True"
      }
    }
  }
}

resource "null_resource" "del_env_mappers" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "rm -f /config/env_mapper.txt"
  }
}

resource "null_resource" "create_env_mappers" {
  for_each = { for project in local.projects : project.name => project }
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "echo ${each.value.name}~${google_composer_environment.composer2[each.key].config.0.dag_gcs_prefix} >> /config/env_mapper.txt"
  }
  depends_on = [null_resource.del_env_mappers]
}
