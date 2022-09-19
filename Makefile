FOLDER:=411092246126
BILLING_ACCOUNT_ID?=017B39-5B5F1B-912B8C
LOCATION=europe-west2
DEPLOYMNENT_PROJECT=cicd-nazca-deploy
DEV_PROJECT ?= cicd-nazca-dev
TEST_PROJECT ?= cicd-nazca-test
PROD_PROJECT ?= cicd-nazca-prod
COMPOSER_ENV ?= ${DEV_PROJECT}
SA_KEY=~/.config/gcloud/application_default_credentials.json
DAG_BUCKET ?= $$(gcloud composer environments describe ${COMPOSER_ENV} --location ${LOCATION}|grep dagGcsPrefix|cut -d ":" -f2-3)
PROJECT_NUMBER ?= $$(gcloud projects list --filter=name=${PROJECT} --format="value(PROJECT_NUMBER)")
DEPLOYMENT_PROJECT_NUMBER ?= $$(gcloud projects list --filter=name=${DEPLOYMNENT_PROJECT} --format="value(PROJECT_NUMBER)")
TFSTATE_BUCKET ?= ${DEPLOYMNENT_PROJECT}-${DEPLOYMENT_PROJECT_NUMBER}-tfstate
BUILD_CONTAINER ?= cicd
BUILD_CONTAINER_TAG ?= latest
GCLOUD_DIR ?= $$(gcloud info --format='value(config.paths.global_config_dir)')
GCLOUD_MOUNT ?= -v $(GCLOUD_DIR):/root/.config/gcloud
ARTIFACT_REGISTRY_NAME=airflow-test-container
project_to_branch_map=$$(cat env_mapper.txt)
WORKDIR?=/workspace_stg

# Makefile command prefixes
continue_on_error = -
suppress_output = @

# Docker run options to prevent interactive mode running within pipelines.
run_options = -it

.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help

help: ## This is help
	$(suppress_output)awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## This will build the Local Dev Container
	$(suppress_output)docker build -t ${BUILD_CONTAINER}:${BUILD_CONTAINER_TAG} .

bootstrap:init ## Creates a Bucket to Store Terraform State -- Do this FIRST !! -- Also, Run this once only
	$(suppress_output)gcloud projects create ${DEPLOYMNENT_PROJECT} --folder=${FOLDER}
	$(suppress_output)gcloud alpha billing accounts projects link ${DEPLOYMNENT_PROJECT} --account-id=${BILLING_ACCOUNT_ID}
	$(suppress_output)gcloud config set project ${DEPLOYMNENT_PROJECT}
	$(suppress_output)echo "Enabling Cloud Resource Manager API...."
	$(call run, gcloud services enable cloudresourcemanager.googleapis.com)
	$(suppress_output)echo "Enabling Artifact Registry API...."
	$(call run, gcloud services enable artifactregistry.googleapis.com)
	$(suppress_output)echo "Enabling Cloud Build API...."
	$(call run, gcloud services enable cloudbuild.googleapis.com)
	$(suppress_output)echo "Creating Terraform State Bucket ${TFSTATE_BUCKET}...."
	$(call run, gsutil mb -c standard -l ${LOCATION} -p ${DEPLOYMNENT_PROJECT} gs://${TFSTATE_BUCKET})

repo:init ## Setup Artifact Registry Docker Repo in the Deployment Project
	$(suppress_output)gcloud config set project ${DEPLOYMNENT_PROJECT}
	$(suppress_output)echo "Building Artifact Repo to Store Docker Image of Airflow Test Container...."
	$(suppress_output) gcloud artifacts repositories create ${ARTIFACT_REGISTRY_NAME} --repository-format=docker --location=${LOCATION}

projects: ## Builds the Dev, Test and Prod Projects and Enable APIs
	#gcloud auth application-default login
	$(call run, bash /workspace_stg/tf_utils.sh plan infra/projects ${DEPLOYMNENT_PROJECT} ${LOCATION} ${COMPOSER_ENV} ${DEPLOYMENT_PROJECT_NUMBER} ${DEV_PROJECT} ${TEST_PROJECT} ${PROD_PROJECT})

deploy:tests ## Deploy Dags to Your Dev Project -- This Runs your Unit tests first
	$(suppress_output)gcloud config set project ${DEV_PROJECT}
	$(suppress_output)echo ${DAG_BUCKET}
	$(call run,gsutil -m rsync -r dags/  ${DAG_BUCKET})

tests: ## Run your Airflow Unit Tests -- Make sure you run `make init` at least once before running this
	$(call run, pytest /workspace/tests)

shell:
	$(call run, /bin/bash)

triggers: ## Build CICD triggers against your GitHub Repo
	gcloud auth application-default login --no-browser
	$(call run, bash /workspace_stg/tf_utils.sh apply infra/triggers ${DEPLOYMNENT_PROJECT} ${LOCATION} ${COMPOSER_ENV} ${DEPLOYMENT_PROJECT_NUMBER} ${DEV_PROJECT} ${TEST_PROJECT} ${PROD_PROJECT}))

del-triggers: ## Destroy your Build Triggers
	$(call run, bash /workspace_stg/tf_utils.sh destroy infra/triggers ${DEPLOYMNENT_PROJECT} ${LOCATION} ${COMPOSER_ENV} ${DEPLOYMENT_PROJECT_NUMBER} ${DEV_PROJECT} ${TEST_PROJECT} ${PROD_PROJECT}))

checks:
	$(call run, pre-commit run --all-files)

# Mount Users gcloud creds on the Container
define run
	$(continue_on_error)docker run \
		--rm \
		${run_options} \
		--env TF_VAR_folder=${FOLDER} \
		--env TF_VAR_billing_account=${BILLING_ACCOUNT_ID} \
		-v $(PWD):${WORKDIR} \
		-v $(SA_KEY):/credentials/access.json:ro \
		--env GOOGLE_APPLICATION_CREDENTIALS=/credentials/access.json \
		${GCLOUD_MOUNT} \
		-w ${WORKDIR} \
		${BUILD_CONTAINER}:${BUILD_CONTAINER_TAG} \
		${1}
endef
