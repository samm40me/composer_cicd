# Include config File Vars
include env.config

COMPOSER_ENV?=${TF_VAR_dev_project}
SA_KEY=~/.config/gcloud/application_default_credentials.json
DAG_BUCKET?=$$(gcloud composer environments describe ${COMPOSER_ENV} --location ${TF_VAR_location}|grep dagGcsPrefix|cut -d ":" -f2-3)
PROJECT_NUMBER?=$$(gcloud projects list --filter=name=${TF_VAR_dev_project} --format="value(PROJECT_NUMBER)")
DEPLOYMENT_PROJECT_NUMBER?=$$(gcloud projects list --filter=name=${TF_VAR_deployment_project} --format="value(PROJECT_NUMBER)")
#DEPLOYMENT_PROJECT_NUMBER=123456
TF_VAR_tfstate_bucket ?= ${TF_VAR_deployment_project}-${DEPLOYMENT_PROJECT_NUMBER}-tfstate
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

test:
	@echo ${COMPOSER_ENV}

init: ## This will build the Local Dev Container
	$(suppress_output)docker build -t ${BUILD_CONTAINER}:${BUILD_CONTAINER_TAG} .

bootstrap:init ## Creates a Bucket to Store Terraform State -- Do this FIRST !! -- Also, Run this once only
	$(suppress_output)echo "Creating Deployment Project ${TF_VAR_deployment_project}"
	#$(suppress_output)gcloud projects create ${TF_VAR_deployment_project} --folder=${TF_VAR_folder}
	$(suppress_output)gcloud beta billing projects link ${TF_VAR_deployment_project} --billing-account=${TF_VAR_billing_account}
	$(suppress_output)gcloud config set project ${TF_VAR_deployment_project}
	$(suppress_output)echo "Enabling Cloud Resource Manager API...."
	$(call run, gcloud services enable cloudresourcemanager.googleapis.com)
	$(suppress_output)echo "Enabling Artifact Registry API...."
	$(call run, gcloud services enable artifactregistry.googleapis.com)
	$(suppress_output)echo "Enabling Cloud Build API...."
	$(call run, gcloud services enable cloudbuild.googleapis.com)
	$(suppress_output)echo "Creating Terraform State Bucket ${TF_VAR_tfstate_bucket}...."
	$(call run, gsutil mb -c standard -l ${TF_VAR_location} -p ${TF_VAR_deployment_project} gs://${TF_VAR_tfstate_bucket})

repo:init ## Setup Artifact Registry Docker Repo in the Deployment Project
	$(suppress_output)gcloud config set project ${TF_VAR_deployment_project}
	$(suppress_output)echo "Building Artifact Repo to Store Docker Image of Airflow Test Container...."
	$(suppress_output)gcloud artifacts repositories create ${ARTIFACT_REGISTRY_NAME} --repository-format=docker --location=${TF_VAR_location}

projects:auth ## Builds the Dev, Test and Prod Projects and Enable APIs

	$(call run, bash /workspace_stg/tf_utils.sh \
	plan \
	infra/projects \
 	${DEPLOYMENT_PROJECT_NUMBER})

deploy:tests ## Deploy Dags to Your Dev Project -- This Runs your Unit tests first
	$(suppress_output)gcloud config set project ${TF_VAR_dev_project}
	$(suppress_output)echo ${DAG_BUCKET}
	$(call run,gsutil -m rsync -r dags/  ${DAG_BUCKET})

tests: ## Run your Airflow Unit Tests -- Make sure you run `make init` at least once before running this
	$(call run, pytest /workspace/tests)

shell:
	$(call run, /bin/bash)

triggers: ## Build CICD triggers against your GitHub Repo
	gcloud auth application-default login --no-browser
	$(call run, bash /workspace_stg/tf_utils.sh \
	apply \
	infra/triggers \
	${DEPLOYMENT_PROJECT_NUMBER})

del-triggers: ## Destroy your Build Triggers
	$(call run, bash /workspace_stg/tf_utils.sh \
	destroy \
	infra/triggers \
	${DEPLOYMENT_PROJECT_NUMBER})

auth:
	gcloud auth application-default login

checks:
	$(call run, pre-commit run --all-files)

# Mount Users gcloud creds on the Container
define run
	$(continue_on_error)docker run \
		--rm \
		${run_options} \
		-v $(PWD):${WORKDIR} \
		-v $(SA_KEY):/credentials/access.json:ro \
		--env GOOGLE_APPLICATION_CREDENTIALS=/credentials/access.json \
		-e TF_VAR_tfstate_bucket=${TF_VAR_tfstate_bucket} \
		-e TF_VAR_deployment_project_number=${DEPLOYMENT_PROJECT_NUMBER} \
		--env-file env.config \
		${GCLOUD_MOUNT} \
		-w ${WORKDIR} \
		${BUILD_CONTAINER}:${BUILD_CONTAINER_TAG} \
		${1}
endef
