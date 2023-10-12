#!/bin/bash

# Address of Azure Grafana
GRAFANA_ENDPOINT=""

# Token credentials
GRAFANA_TOKEN=""

# Name of the Prometheus data source
GRAFANA_DATASOURCE=""

# Get all folders
FOLDER="$(curl -s \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $GRAFANA_TOKEN" \
    $GRAFANA_ENDPOINT/api/folders | jq -r '.[] | select(.title == "Flux").uid')"

if [[ -z "$FOLDER" ]]; then
    # Create Flux folder
    FOLDER="$(curl -s \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $GRAFANA_TOKEN" \
        -d "{\"title\": \"Flux\"}" \
        $GRAFANA_ENDPOINT/api/folders | jq -r '.uid')"
fi

# Import all Flux dashboards
for DASHBOARD in cluster control-plane; do
    curl -s https://raw.githubusercontent.com/fluxcd/flux2-monitoring-example/main/monitoring/configs/dashboards/${DASHBOARD}.json > /tmp/dashboard.json
    echo "Importing $(cat /tmp/dashboard.json | jq -r '.title')..."
    curl -s \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $GRAFANA_TOKEN" \
        -d "{\"dashboard\":$(cat /tmp/dashboard.json | jq 'del(.id)'),\"folderUid\":\"$FOLDER\",\"overwrite\":true, \
            \"inputs\":[{\"name\":\"DS_PROMETHEUS\",\"type\":\"datasource\", \
            \"pluginId\":\"prometheus\",\"value\":\"$GRAFANA_DATASOURCE\"}]}" \
        $GRAFANA_ENDPOINT/api/dashboards/import
    echo -e "\nDone\n"
done
