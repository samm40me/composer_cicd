locals {
  project_config = yamldecode(file("../../projects.yaml"))
#  default_apis   = [
#                    "cloudresourcemanager.googleapis.com",
#                    "dataproc.googleapis.com",
#                    "composer.googleapis.com",
#                    "cloudfunctions.googleapis.com",
#                    "bigquery.googleapis.com",
#                    "storage.googleapis.com"
#                  ]
#  projects       = [
#  for project in local.project_config.projects : {
#    name = project.name
#    apis = distinct(concat(local.default_apis, try(project.apis, [])))
#  }
#  ]
}

module