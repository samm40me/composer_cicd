#!/usr/bin/env bash
set -ux

WORKDIR=/tmp/workspace

# Start of Bash Script
command=$1
folder=$2
project_number=$3

project_id=${TF_VAR_deployment_project}
dev_project=${TF_VAR_dev_project}
test_project=${TF_VAR_test_project}
prod_project=${TF_VAR_prod_project}

cp -R /workspace_stg ${WORKDIR}/
tf_folder=$(basename ${folder})

echo ${tf_folder}

if [ ${tf_folder} == "projects" ]; then
  source ${WORKDIR}/proj_subst.sh
fi

source ${WORKDIR}/env_subst.sh $command ${WORKDIR}/${folder}

cd ${WORKDIR}/${folder}

gcloud config set project ${project_id}
terraform init || exit 1
terraform workspace select ${project_id} || terraform workspace new ${project_id}

if [ $command == "apply" ]; then
  terraform apply --auto-approve
elif [ $command == "destroy" ]; then
  terraform destroy --auto-approve
elif [ $command == "plan" ]; then
  terraform plan
fi
