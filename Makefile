PROJECT ?= kev-pinto-sandbox
LOCATION=europe-west2
COMPOSER_ENV ?= ${PROJECT}
SERVICE_ACCOUNT=terraform@kev-pinto-sandbox.iam.gserviceaccount.com
SA_KEY=/Users/pintok/.config/gcloud/terraform-kev-pinto-sandbox.json
DAG_BUCKET ?= $$(gcloud composer environments describe ${COMPOSER_ENV} --location ${LOCATION}|grep dagGcsPrefix|cut -d ":" -f2-3)
PROJECT_NUMBER ?= $$(gcloud projects list --filter=${PROJECT} --format="value(PROJECT_NUMBER)")
TFSTATE_BUCKET ?= ${PROJECT}-composercicd-tfstate
BUILD_CONTAINER ?= cicd
BUILD_CONTAINER_TAG ?= latest
GCLOUD_DIR ?= $$(gcloud info --format='value(config.paths.global_config_dir)')
GCLOUD_MOUNT ?= -v $(GCLOUD_DIR):/root/.config/gcloud


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
	$(suppress_output)gcloud config set project ${PROJECT}
	$(call run, gsutil mb -c standard -l ${LOCATION} -p ${PROJECT} gs://${TFSTATE_BUCKET})

deploy: tests ## Deploy Dags to Your Project -- This Runs your Unit tests first
	$(suppress_output)echo ${DAG_BUCKET}
	$(call run,gsutil -m rsync -r dags/  ${DAG_BUCKET})

tests: ## Run your Airflow Unit Tests -- Make sure you run `make init` at least once before running this
	$(call run, pytest /workspace/tests)

shell:
	$(call run, /bin/bash)

triggers: ## Build CICD triggers against your GitHub Repo
	$(call run, bash /workspace_stg/tf_utils.sh apply infra ${PROJECT} ${LOCATION} ${COMPOSER_ENV})

test: ## test
	@echo ${CURDIR}

# Mount Users gcloud creds on the Container
define run
	$(continue_on_error)docker run \
		--rm \
		${run_options} \
		-v $(PWD):/workspace_stg:ro \
		-v $(SA_KEY):/credentials/access.json:ro \
		--env GOOGLE_APPLICATION_CREDENTIALS=/credentials/access.json \
		${GCLOUD_MOUNT} \
		${BUILD_CONTAINER}:${BUILD_CONTAINER_TAG} \
		${1}
endef
