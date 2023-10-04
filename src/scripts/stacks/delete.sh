#!/bin/bash

while getopts n: option
do
    case "${option}" in
        n) stack_name=${OPTARG};;
    esac
done

if [ -z "$stack_name" ]; then
    stack_name="default"
fi

echo "=> Deleting deployment stack..."
az stack sub delete \
  --name $stack_name \
  --delete-all \
  --yes
