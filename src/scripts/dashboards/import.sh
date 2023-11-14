#!/bin/bash

# Address of Azure Grafana
GRAFANA_ENDPOINT=""

# Token credentials
GRAFANA_TOKEN=""

# Name of the Prometheus data source
GRAFANA_DATASOURCE=""

# Version of Istio to deploy
VERSION="1.17.5"

# Get all folders
FOLDER="$(curl -s \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $GRAFANA_TOKEN" \
    $GRAFANA_ENDPOINT/api/folders | jq -r '.[] | select(.title == "Istio").uid')"

if [[ -z "$FOLDER" ]]; then
    # Create Istio folder
    FOLDER="$(curl -s \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $GRAFANA_TOKEN" \
        -d "{\"title\": \"Istio\"}" \
        $GRAFANA_ENDPOINT/api/folders | jq -r '.uid')"
fi

# Import all Istio dashboards
for DASHBOARD in 7639 7636 7630 11829 7645 13277; do
    REVISION="$(curl -s https://grafana.com/api/dashboards/${DASHBOARD}/revisions -s | jq ".items[] | select(.description | contains(\"${VERSION}\")) | .revision")"
    curl -s https://grafana.com/api/dashboards/${DASHBOARD}/revisions/${REVISION}/download > /tmp/dashboard.json
    echo "Importing $(cat /tmp/dashboard.json | jq -r '.title') (revision ${REVISION}, id ${DASHBOARD})..."
    curl -s \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $GRAFANA_TOKEN" \
        -d "{\"dashboard\":$(cat /tmp/dashboard.json),\"folderUid\":\"$FOLDER\",\"overwrite\":true, \
            \"inputs\":[{\"name\":\"DS_PROMETHEUS\",\"type\":\"datasource\", \
            \"pluginId\":\"prometheus\",\"value\":\"$GRAFANA_DATASOURCE\"}]}" \
        $GRAFANA_ENDPOINT/api/dashboards/import
    echo -e "\nDone\n"
done
