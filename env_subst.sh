#!/usr/bin/env bash
set -ux

set_tf_vars(){
  file_array=(backend.tf terraform.tfvars provider.tf)
  for file_name in ${file_array[@]}; do
    echo $file_name
    sed -i "s/PROJECT_ID/${project_id}/g" ${folder}/${file_name}
    sed -i "s/LOCATION_ID/${location_id}/g" ${folder}/${file_name}
    sed -i "s/COMPOSER_ENV/${composer_env}/g" ${folder}/${file_name}
  done
}

# Start of Bash Script
command=$1
folder=$2
project_id=$3
location_id=$4
composer_env=$5

set_tf_vars
