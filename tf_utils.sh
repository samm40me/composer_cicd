#!/usr/bin/env bash
set -ux

WORKDIR=/tmp/workspace

# Start of Bash Script
command=$1
folder=$2
project_id=$3
location_id=$4
composer_env=$5
project_number=$6
dev_project=$7
test_project=$8
prod_project=$9

cp -R /workspace_stg ${WORKDIR}/
tf_folder=$(basename ${folder})

echo ${tf_folder}

if [ ${tf_folder} == "projects" ]
then
  source ${WORKDIR}/proj_subst.sh ${dev_project} ${test_project} ${prod_project}
fi

source ${WORKDIR}/env_subst.sh $command ${WORKDIR}/${folder} $project_id $location_id $composer_env $project_number

cd ${WORKDIR}/${folder}

gcloud config set project ${project_id}
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
