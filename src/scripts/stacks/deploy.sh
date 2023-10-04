#!/bin/bash

while getopts n:p: option
do
    case "${option}" in
        n) stack_name=${OPTARG};;
        p) parameter_file=${OPTARG};;
    esac
done

if [ -z "$stack_name" ]; then
    stack_name="default"
fi

if [ -z "$parameter_file" ]; then
    parameter_file="./src/main.bicepparam"
fi

echo "=> Creating deployment stack..."
az stack sub create \
  --name $stack_name \
  --location 'uksouth' \
  --template-file ./src/main.bicep \
  --parameters $parameter_file \
  --delete-all \
  --deny-settings-mode none \
  --yes
