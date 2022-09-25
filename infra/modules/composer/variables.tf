variable "project_id" {
  type        = string
  description = "The name of the project to deploy into"
}

variable "region" {
  type        = string
  description = "The GCP region to deploy into"
}

locals {
  labels = {
    "terraform-module" = "ons-prices-composer"
  }
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Additional labels for project"
}

variable "environment_size" {
  type        = string
  description = "The environment size controls the performance parameters of the managed Cloud Composer infrastructure that includes the Airflow database. Values for environment size are: ENVIRONMENT_SIZE_SMALL, ENVIRONMENT_SIZE_MEDIUM, and ENVIRONMENT_SIZE_LARGE."
  default     = "ENVIRONMENT_SIZE_SMALL"
}

variable "image_version" {
  type        = string
  description = "The version of the aiflow running in the cloud composer environment."
  default     = "composer-2.0.23-airflow-2.2.5"
}

variable "network" {
  type        = string
  description = "The VPC network to host the composer cluster."
}

variable "subnetwork" {
  type        = string
  description = "The subnetwork to host the composer cluster."
}

variable "scheduler_cpu" {
  type        = string
  default     = 2
  description = "Configuration for resources used by Airflow schedulers."
}

variable "scheduler_memory_gb" {
  type        = number
  default     = 7.5
  description = "Configuration for resources used by Airflow schedulers."
}

variable "scheduler_storage_gb" {
  type        = number
  default     = 5
  description = "Configuration for resources used by Airflow schedulers."
}

variable "scheduler_count" {
  type        = number
  default     = 2
  description = "Configuration for resources used by Airflow schedulers."
}

variable "web_server_cpu" {
  type        = string
  default     = 2
  description = "Configuration for resources used by Airflow web server."
}

variable "web_server_memory_gb" {
  type        = number
  default     = 7.5
  description = "Configuration for resources used by Airflow web server."
}

variable "web_server_storage_gb" {
  type        = number
  default     = 5
  description = "Configuration for resources used by Airflow web server."
}

variable "worker_cpu" {
  type        = string
  default     = 2
  description = "Configuration for resources used by Airflow workers."
}

variable "worker_memory_gb" {
  type        = number
  default     = 7.5
  description = "Configuration for resources used by Airflow workers."
}

variable "worker_storage_gb" {
  type        = number
  default     = 5
  description = "Configuration for resources used by Airflow workers."
}

variable "worker_min_count" {
  type        = number
  default     = 2
  description = "Configuration for resources used by Airflow workers."
}

variable "worker_max_count" {
  type        = number
  default     = 6
  description = "Configuration for resources used by Airflow workers."
}

variable "versioning" {
  default = false
}

variable "project_number" {}

variable "is_production" {
  type        = bool
  default     = false
  description = "is this a prod or prod-like env?"
}

variable "cprices_archive_bucket_name" {
  description = "the bucket processed files will be archived to"
  type        = string
}

variable "cprices_archive_bucket_url" {
  description = "the url for the bucket processed files will be archived to"
  type        = string
}

variable "des_data_bucket_name" {
  description = "the bucket that files we need to process will be uploaded to"
  type        = string
}

variable "des_data_bucket_url" {
  description = "the url for the bucket that files we need to process will be uploaded to"
  type        = string
}
