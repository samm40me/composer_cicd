#!/usr/bin/env bash
set -ux

WORKDIR=/tmp/workspace

set_tf_vars(){
  file_array=(projects.yaml)
  for file_name in ${file_array[@]}; do
    echo $file_name
    sed -i "s/DEV_PROJECT/${dev_project}/g" ${WORKDIR}/${file_name}
    sed -i "s/TEST_PROJECT/${test_project}/g" ${WORKDIR}/${file_name}
    sed -i "s/PROD_PROJECT/${prod_project}/g" ${WORKDIR}/${file_name}
  done
}

# Start of Bash Script
dev_project=$1
test_project=$2
prod_project=$3


set_tf_vars
cat ${WORKDIR}/projects.yaml