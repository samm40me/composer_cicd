#!/usr/bin/env bash
set -ux

WORKDIR=/tmp/workspace

set_tf_vars(){
  file_array=(projects.yaml)
  for file_name in ${file_array[@]}; do
    echo $file_name
    sed -i "s/DEV_PROJECT/${TF_VAR_dev_project}/g" ${WORKDIR}/${file_name}
    sed -i "s/TEST_PROJECT/${TF_VAR_test_project}/g" ${WORKDIR}/${file_name}
    sed -i "s/PROD_PROJECT/${TF_VAR_prod_project}/g" ${WORKDIR}/${file_name}
  done
}

# Start of Bash Script
set_tf_vars
cat ${WORKDIR}/projects.yaml