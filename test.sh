#!/usr/bin/env bash

ENVIRONMENTS=$(cat env_mapper.txt)

for mapper in ${ENVIRONMENTS[@]} ; do
  branch=$(echo ${mapper}|cut -d ":" -f1)
  project_id=$(echo ${mapper}|cut -d ":" -f2)
  echo "Branch = ${branch} -- Project = ${project_id}"
done