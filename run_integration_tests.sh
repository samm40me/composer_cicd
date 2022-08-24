#!/usr/bin/env bash

BRANCH=$1
SHORT_SHA=$2

echo "BRANCH=${BRANCH} COMMIT_SHA=${COMMIT_SHA}"

project_to_branch_map=($(cat env_mapper.txt))
for mapping in ${project_to_branch_map[@]}; do
  project_id=$(echo ${mapping}|cut -d":" -f1)
  dag_bucket=$(echo ${mapping}|cut -d":" -f2)
  branch=$(echo ${mapping}|cut -d":" -f3)
#  echo "Project_id=${project_id}, Branch=${branch}"

  if [ ${BRANCH} == ${branch} ]; then
    echo "Deploying to ${project_id}"
    gsutil rsync -r -d dags/ gs://{dag_bucket}/data/${SHORT_SHA}/
  fi

  echo "Status=${status}"
done