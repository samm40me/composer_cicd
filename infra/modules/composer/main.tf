locals {
  projects = [
  for project in var.projects.projects : {
    name = project.name
  }
  ]
}

resource "google_composer_environment" "composer2" {
  for_each = { for project in local.projects : project.name => project }
  name     = each.value.name
  project  = each.value.name
  region   = var.location

  config {
    software_config {
      image_version = "composer-2.0.28-airflow-2.3.3"
      airflow_config_overrides = {
        core-dags_are_paused_at_creation = "True"
      }
    }
  }
  timeouts {
    create = "90m"
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
