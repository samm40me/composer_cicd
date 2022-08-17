References --> 
https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/composer/cicd_sample
https://cloud.google.com/composer/docs/dag-cicd-integration-guide
https://cloud.google.com/composer/docs/how-to/using/testing-dags
https://cloud.google.com/composer/docs/how-to/using/testing-dags


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

