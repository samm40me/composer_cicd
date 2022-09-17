### Pre-Requisites
- Docker Desktop or Rancher Desktop installed on your Laptop/Dev Workstation
- gcloud configured
- A GCP user with permissions to create projects under Organisation/Folder


####Step 1 --> Run `make bootstrap`
- This will create the Bootstrap Project (Deployment Project).. This project will be the main command centre for all our CICD build and deploy activities
- This project will also act as our Project Factory for Spawning new projects and contain the Terraform State Bucket for these projects

####Step 1 --> Run `make repo`
- This command create a Docker Repo in Artifact Registry in the Deployment Project
- This Repo will contain our Test Airflow container that will Validate our DAGs


























Added Pre Commit
References -->
https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/composer/cicd_sample
https://cloud.google.com/composer/docs/dag-cicd-integration-guide
https://cloud.google.com/composer/docs/how-to/using/testing-dags
https://cloud.google.com/architecture/cicd-pipeline-for-data-processing


AF1
===
gcloud composer environments run \
test-environment --location us-central1 \
list_dags -- -sd /home/airflow/gcs/data/test


AF2
====
gcloud composer environments run \
test-environment --location us-central1 \
dags list -- --subdir /home/airflow/gcs/data/test
