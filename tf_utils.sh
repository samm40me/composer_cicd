#!/usr/bin/env bash
set -ux

WORKDIR=/tmp/workspace

set_tf_vars(){
  file_array=(backend.tf terraform.tfvars provider.tf)
  for file_name in ${file_array[@]}; do
    echo $file_name
    sed -i "s/PROJECT_ID/${project_id}/g" ${WORKDIR}/${folder}/${file_name}
    sed -i "s/LOCATION_ID/${location_id}/g" ${WORKDIR}/${folder}/${file_name}
    sed -i "s/COMPOSER_ENV/${composer_env}/g" ${WORKDIR}/${folder}/${file_name}
  done
}


# Start of Bash Script
command=$1
folder=$2
project_id=$3
location_id=$4
composer_env=$5
cp -R /workspace /tmp
set_tf_vars
cd ${WORKDIR}/${folder}
terraform init
terraform workspace select ${project_id} || terraform workspace new ${project_id}
terraform "${command}"








