output "serviceaccount_name" {
  value = google_service_account.this_sa.name
}

output "gcs_bucket" {
  value       = module.this_composer.gcs_bucket
  description = "Google Cloud Storage bucket which hosts DAGs for the Cloud Composer Environment."
}

output "pipeline_code_bucket" {
  description = "the name of the pipeline-code bucket"
  value       = google_storage_bucket.this_code_bucket.name
}

output "pipeline_staging_bucket" {
  description = "the name of the pipeline-staging bucket"
  value       = google_storage_bucket.this_staging_bucket.name
}
