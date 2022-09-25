
#------------------------------------------------------------------------------
# Call to googles composer module
#------------------------------------------------------------------------------

module "this_composer" {
  source  = "terraform-google-modules/composer/google//modules/create_environment_v2"
  version = "3.3.0"

  composer_env_name                = var.project_id
  composer_service_account         = google_service_account.this_sa.name
  environment_size                 = var.environment_size
  image_version                    = var.image_version
  labels                           = merge(local.labels, var.labels)
  network                          = var.network
  pod_ip_allocation_range_name     = "${var.subnetwork}-composer-pods"
  project_id                       = var.project_id
  region                           = var.region
  service_ip_allocation_range_name = "${var.subnetwork}-composer-services"
  subnetwork                       = var.subnetwork

  airflow_config_overrides = {
    "core-dags_are_paused_at_creation" = "True"
    "secrets-backend"                  = "airflow.providers.google.cloud.secrets.secret_manager.CloudSecretManagerBackend"
    "secrets-backend_kwargs" = jsonencode(
      {
        sep              = "-"
        variables_prefix = "cprices"
      }
    )
  }

  env_variables = {
    AIRFLOW_VAR_CPRICES_ENV = jsonencode({
      cprices_archive_bucket : var.cprices_archive_bucket_url
      cprices_code_bucket : google_storage_bucket.this_code_bucket.name
      cprices_staging_bucket : google_storage_bucket.this_staging_bucket.name
      des_data_bucket : var.des_data_bucket_url
      project_id : var.project_id
      project_number : var.project_number
    })
  }

  scheduler = {
    cpu        = var.scheduler_cpu
    memory_gb  = var.scheduler_memory_gb
    storage_gb = var.scheduler_storage_gb
    count      = var.scheduler_count
  }

  web_server = {
    cpu        = var.web_server_cpu
    memory_gb  = var.web_server_memory_gb
    storage_gb = var.web_server_storage_gb
  }

  worker = {
    cpu        = var.worker_cpu
    memory_gb  = var.worker_memory_gb
    storage_gb = var.worker_storage_gb
    min_count  = var.worker_min_count
    max_count  = var.worker_max_count
  }
}

resource "google_storage_bucket" "this_code_bucket" {
  name                        = "pipeline-code-${var.project_number}"
  force_destroy               = var.is_production
  labels                      = merge(local.labels, var.labels)
  location                    = var.region
  project                     = var.project_id
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning
  }
}

resource "google_storage_bucket" "this_staging_bucket" {
  name                        = "pipeline-staging-${var.project_number}"
  force_destroy               = var.is_production
  labels                      = merge(local.labels, var.labels)
  location                    = var.region
  project                     = var.project_id
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning
  }
}

resource "google_storage_bucket_iam_member" "this_archive_bucket_iam_member" {
  for_each = toset([
    "roles/storage.objectAdmin",
  ])
  bucket = var.cprices_archive_bucket_name
  role   = each.key
  member = "serviceAccount:${google_service_account.this_sa.email}"
}

resource "google_storage_bucket_iam_member" "this_code_bucket_iam_member" {
  for_each = toset([
    "roles/storage.objectViewer",
  ])
  bucket = google_storage_bucket.this_code_bucket.name
  role   = each.key
  member = "serviceAccount:${google_service_account.this_sa.email}"
}

resource "google_storage_bucket_iam_member" "this_data_bucket_iam_member" {
  for_each = toset([
    "roles/storage.objectAdmin",
  ])
  bucket = var.des_data_bucket_name
  role   = each.key
  member = "serviceAccount:${google_service_account.this_sa.email}"
}

resource "google_storage_bucket_iam_member" "this_staging_bucket_iam_member" {
  for_each = toset([
    "roles/storage.objectAdmin",
  ])
  bucket = google_storage_bucket.this_staging_bucket.name
  role   = each.key
  member = "serviceAccount:${google_service_account.this_sa.email}"
}
