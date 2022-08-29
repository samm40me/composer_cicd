#!/usr/bin/env bash
set -ux

WORKDIR=/tmp/workspace
# Start of Bash Script
command=$1
folder=$2
project_id=$3
location_id=$4
composer_env=$5

cp -R /workspace_stg ${WORKDIR}/
source ${WORKDIR}/env_subst.sh $command ${WORKDIR}/infra $project_id $location_id $composer_env

cd ${WORKDIR}/infra

terraform init || exit 1
terraform workspace select ${project_id} || terraform workspace new ${project_id}

if [ $command == "apply" ]
then
 terraform apply --auto-approve
elif [ $command == "destroy" ]
then
  terraform destroy --auto-approve
elif [ $command == "plan" ]
then
  terraform plan
fi
