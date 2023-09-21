#!/usr/bin/env bash

set -e

sleep 15

az login --identity

az aks command invoke -n $RESOURCE_NAME -g $RESOURCE_GROUP -c "$COMMAND"
