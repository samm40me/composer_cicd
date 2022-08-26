DEPLOYMNENT_PROJECT=kev-pinto-deploy
LOCATION=europe-west2
DEV_PROJECT ?= kev-pinto-sandbox
COMPOSER_ENV ?= ${DEV_PROJECT}
SA_KEY=/Users/pintok/.config/gcloud/kev-pinto-deploy-b1bf3f5a3949.json
DAG_BUCKET ?= $$(gcloud composer environments describe ${COMPOSER_ENV} --location ${LOCATION}|grep dagGcsPrefix|cut -d ":" -f2-3)
PROJECT_NUMBER ?= $$(gcloud projects list --filter=${PROJECT} --format="value(PROJECT_NUMBER)")
TFSTATE_BUCKET ?= ${DEPLOYMNENT_PROJECT}-composercicd-tfstate
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

init: ## This will build the Airflow testing Container -- Run this once only
	$(suppress_output)docker build -t ${BUILD_CONTAINER}:${BUILD_CONTAINER_TAG} .

bootstrap:init ## Creates a Bucket to Store Terraform State -- Do this FIRST !! -- Also, Run this once only
	$(suppress_output)gcloud config set project ${DEPLOYMNENT_PROJECT}
	$(suppress_output)echo "Enabling Artifact Registry API...."
	$(call run, gcloud services enable artifactregistry.googleapis.com)
	$(suppress_output)echo "Enabling Cloud Resource Manager API...."
	$(call run, gcloud services enable cloudresourcemanager.googleapis.com)
	$(suppress_output)echo "Enabling Cloud Build API...."
	$(call run, gcloud services enable cloudbuild.googleapis.com)
	$(suppress_output)echo "Building Artifact Repo to Store Docker Image of Airflow Test Container...."
	$(call run, gcloud artifacts repositories create ${ARTIFACT_REGISTRY_NAME} --repository-format=docker --location=${LOCATION} --async)
	(suppress_output)echo "Creating Terraform State Bucket ${TFSTATE_BUCKET}...."
	$(call run, gsutil mb -c standard -l ${LOCATION} -p ${DEPLOYMNENT_PROJECT} gs://${TFSTATE_BUCKET})


deploy: tests ## Deploy Dags to Your Dev Project -- This Runs your Unit tests first
	$(suppress_output)gcloud config set project ${DEV_PROJECT}
	$(suppress_output)echo ${DAG_BUCKET}
	$(call run,gsutil -m rsync -r dags/  ${DAG_BUCKET})

tests: ## Run your Airflow Unit Tests -- Make sure you run `make init` at least once before running this
	$(call run, pytest /workspace/tests)

shell:
	$(call run, /bin/bash)

triggers: ## Build CICD triggers against your GitHub Repo
	$(call run, bash /workspace_stg/tf_utils.sh apply infra ${DEPLOYMNENT_PROJECT} ${LOCATION} ${COMPOSER_ENV})

del-triggers: ## Destroy your Build Triggers
	$(call run, bash /workspace_stg/tf_utils.sh destroy infra ${DEPLOYMNENT_PROJECT} ${LOCATION} ${COMPOSER_ENV})

set-iam:
	for file in ${project_to_branch_map};do \
  		proj=$$(echo $$file|cut -d ":" -f1) ; \
  		echo $${proj} ; \
  		$(suppress_output)gcloud config set project $${proj}; \
  		gcloud config list ; \
  		db=$$(gcloud composer environments describe $${proj} --location ${LOCATION}|grep dagGcsPrefix|cut -d ":" -f2-3); \
  		echo $${db}; \
  	done


# Mount Users gcloud creds on the Container
define run
	$(continue_on_error)docker run \
		--rm \
		${run_options} \
		-v $(PWD):${WORKDIR}:ro \
		-v $(SA_KEY):/credentials/access.json:ro \
		--env GOOGLE_APPLICATION_CREDENTIALS=/credentials/access.json \
		${GCLOUD_MOUNT} \
		-w ${WORKDIR} \
		${BUILD_CONTAINER}:${BUILD_CONTAINER_TAG} \
		${1}
endef
