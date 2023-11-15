// -------
// Imports
// -------

import { Defaults } from '../../types/defaults.bicep'
import { Settings } from '../../types/settings.bicep'

// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Container Registry
resource registry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' = {
  name: settings.resourceGroups.services.resources.containerRegistry.name
  location: settings.resourceGroups.services.location
  sku: {
    name: 'Standard'
  }
}

// Key Vault
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: settings.resourceGroups.services.resources.keyVault.name
  location: settings.resourceGroups.services.location
  properties: {
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: false
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

// Prometheus Workspace
resource workspace 'Microsoft.Monitor/accounts@2023-04-03' = {
  name: settings.resourceGroups.services.resources.prometheusWorkspace.name
  location: settings.resourceGroups.services.location
}

// Rule Groups
resource ruleGroups 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = [for ruleGroup in defaults.ruleGroups: {
  name: '${settings.resourceGroups.services.resources.prometheusWorkspace.name} (${ruleGroup.name})'
  location: settings.resourceGroups.services.location
  properties: {
    description: ruleGroup.description
    scopes: [ workspace.id ]
    enabled: true
    interval: 'PT1M'
    rules: ruleGroup.rules
  }
}]

// Grafana Dashboard
resource grafana 'Microsoft.Dashboard/grafana@2022-10-01-preview' = {
  name: settings.resourceGroups.services.resources.grafanaDashboard.name
  location: settings.resourceGroups.services.location
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiKey: 'Enabled'
    grafanaIntegrations: {
      azureMonitorWorkspaceIntegrations: [
        {
          azureMonitorWorkspaceResourceId: workspace.id
        }
      ]
    }
  }
}

// ----------
// Parameters
// ----------

param defaults Defaults
param settings Settings
