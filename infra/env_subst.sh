#!/usr/bin/env bash
set -ux

set_tf_vars(){
  file_array=(backend.tf terraform.tfvars provider.tf)
  for file_name in ${file_array[@]}; do
    sed -i "s/PROJECT_ID/${TF_VAR_deployment_project}/g" ${subst_folder}/${file_name}
    sed -i "s/LOCATION_ID/${TF_VAR_location}/g" ${subst_folder}/${file_name}
    sed -i "s/TFSTATE_BUCKET/${TF_VAR_tfstate_bucket}/g" ${subst_folder}/${file_name}
#    cat ${subst_folder}/${file_name}
  done
}

# Start of Bash Script
command=$1
subst_folder=$2

set_tf_vars
