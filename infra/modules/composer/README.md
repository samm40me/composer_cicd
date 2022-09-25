# ons-prices-composer

---

This opinionated module sets up a composer environment with:

-   secret manager setup as a backend
    -   secrets it looks for need to be prefixed `cprices-`
-   dedicated serviceaccount
-   the assumption the secondary ip ranges will be named:
    -   `${var.subnet}-composer-pods`
    -   `${var.subnet}-composer-services`
-   airflow config core value `dags_are_paused_at_creation` set to "True"

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| this\_composer | terraform-google-modules/composer/google//modules/create_environment_v2 | 3.3.0 |

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.this_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.this_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.gce-default-account-iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_storage_bucket.this_code_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.this_staging_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.this_archive_bucket_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.this_code_bucket_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.this_data_bucket_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.this_staging_bucket_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_compute_default_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_default_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cprices\_archive\_bucket\_name | the bucket processed files will be archived to | `string` | n/a | yes |
| cprices\_archive\_bucket\_url | the url for the bucket processed files will be archived to | `string` | n/a | yes |
| des\_data\_bucket\_name | the bucket that files we need to process will be uploaded to | `string` | n/a | yes |
| des\_data\_bucket\_url | the url for the bucket that files we need to process will be uploaded to | `string` | n/a | yes |
| environment\_size | The environment size controls the performance parameters of the managed Cloud Composer infrastructure that includes the Airflow database. Values for environment size are: ENVIRONMENT\_SIZE\_SMALL, ENVIRONMENT\_SIZE\_MEDIUM, and ENVIRONMENT\_SIZE\_LARGE. | `string` | `"ENVIRONMENT_SIZE_SMALL"` | no |
| image\_version | The version of the aiflow running in the cloud composer environment. | `string` | `"composer-2.0.23-airflow-2.2.5"` | no |
| is\_production | is this a prod or prod-like env? | `bool` | `false` | no |
| labels | Additional labels for project | `map(string)` | `{}` | no |
| network | The VPC network to host the composer cluster. | `string` | n/a | yes |
| project\_id | The name of the project to deploy into | `string` | n/a | yes |
| project\_number | n/a | `any` | n/a | yes |
| region | The GCP region to deploy into | `string` | n/a | yes |
| scheduler\_count | Configuration for resources used by Airflow schedulers. | `number` | `2` | no |
| scheduler\_cpu | Configuration for resources used by Airflow schedulers. | `string` | `2` | no |
| scheduler\_memory\_gb | Configuration for resources used by Airflow schedulers. | `number` | `7.5` | no |
| scheduler\_storage\_gb | Configuration for resources used by Airflow schedulers. | `number` | `5` | no |
| subnetwork | The subnetwork to host the composer cluster. | `string` | n/a | yes |
| versioning | n/a | `bool` | `false` | no |
| web\_server\_cpu | Configuration for resources used by Airflow web server. | `string` | `2` | no |
| web\_server\_memory\_gb | Configuration for resources used by Airflow web server. | `number` | `7.5` | no |
| web\_server\_storage\_gb | Configuration for resources used by Airflow web server. | `number` | `5` | no |
| worker\_cpu | Configuration for resources used by Airflow workers. | `string` | `2` | no |
| worker\_max\_count | Configuration for resources used by Airflow workers. | `number` | `6` | no |
| worker\_memory\_gb | Configuration for resources used by Airflow workers. | `number` | `7.5` | no |
| worker\_min\_count | Configuration for resources used by Airflow workers. | `number` | `2` | no |
| worker\_storage\_gb | Configuration for resources used by Airflow workers. | `number` | `5` | no |

## Outputs

| Name | Description |
|------|-------------|
| gcs\_bucket | Google Cloud Storage bucket which hosts DAGs for the Cloud Composer Environment. |
| pipeline\_code\_bucket | the name of the pipeline-code bucket |
| pipeline\_staging\_bucket | the name of the pipeline-staging bucket |
| serviceaccount\_name | n/a |
<!-- END_TF_DOCS -->
