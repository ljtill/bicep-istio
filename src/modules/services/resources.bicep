// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Container Registry
resource registry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' = {
  name: containerRegistry.name
  location: resourceGroup().location
  sku: {
    name: containerRegistry.properties.sku
  }
}

// Role Assignment
resource registryAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (managedCluster, i) in managedClusters: {
  name: guid('registries', managedCluster.name)
  scope: registry
  properties: {
    principalType: 'ServicePrincipal'
    principalId: clusters[i].properties.identityProfile.kubeletIdentity.clientId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.AcrPull)
  }
}]

// Key Vault
resource vault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVault.name
  location: resourceGroup().location
  properties: {
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: false
    sku: {
      family: keyVault.properties.sku.family
      name: keyVault.properties.sku.name
    }
  }
}

// Role Assignment
resource vaultAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (managedCluster, i) in managedClusters: {
  name: guid('vaults', managedCluster.name)
  scope: vault
  properties: {
    principalType: 'ServicePrincipal'
    principalId: clusters[i].properties.addonProfiles.azureKeyvaultSecretsProvider.identity.clientId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.KeyVaultAdministrator)
  }
}]

// Prometheus Workspace
resource workspace 'Microsoft.Monitor/accounts@2023-04-03' = {
  name: prometheusWorkspace.name
  location: resourceGroup().location
}

// Grafana Dashboard
resource grafana 'Microsoft.Dashboard/grafana@2022-08-01' = {
  name: grafanaDashboard.name
  location: resourceGroup().location
  sku: {
    name: grafanaDashboard.properties.sku
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

// Data Assocations
module associations '../clusters/assocations.bicep' = [for (managedCluster, i) in managedClusters: {
  name: 'Microsoft.Insights.${i}'
  scope: resourceGroup(settings.resourceGroups.clusters.name)
  params: {
    managedCluster: managedCluster
    ruleName: split(workspace.properties.defaultIngestionSettings.dataCollectionRuleResourceId, '/')[8]
    ruleId: workspace.properties.defaultIngestionSettings.dataCollectionRuleResourceId
  }
}]

// Rule Groups
resource kubernetesRuleGroup 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = [for (managedCluster, i) in managedClusters: {
  name: 'Kubernetes (${managedCluster.name})'
  location: resourceGroup().location
  properties: {
    description: 'Kubernetes Recording Rules RuleGroup - 0.1'
    scopes: [ workspace.id, resourceId(settings.resourceGroups.clusters.name, 'Microsoft.ContainerService/managedClusters', managedCluster.name) ]
    enabled: true
    clusterName: managedCluster.name
    interval: 'PT1M'
    rules: defaults.recordingRules.kubernetes
  }
}]
resource nodeRuleGroup 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = [for (managedCluster, i) in managedClusters: {
  name: 'Node (${managedCluster.name})'
  location: resourceGroup().location
  properties: {
    description: 'Node Recording Rules RuleGroup - 0.1'
    scopes: [ workspace.id, resourceId(settings.resourceGroups.clusters.name, 'Microsoft.ContainerService/managedClusters', managedCluster.name) ]
    enabled: true
    clusterName: managedCluster.name
    interval: 'PT1M'
    rules: defaults.recordingRules.node
  }
}]

// Role Assignments
resource userAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for assignment in grafanaDashboard.assignments: {
  name: guid('user', assignment.name)
  scope: grafana
  properties: {
    principalType: 'User'
    principalId: assignment.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.GrafanaAdmin)
  }
}]
resource dashboardAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('dashboard', grafanaDashboard.name)
  scope: workspace
  properties: {
    principalType: 'ServicePrincipal'
    principalId: grafana.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.MonitoringDataReader)
  }
}

// ---------
// Variables
// ---------

var containerRegistry = settings.resourceGroups.services.resources.containerRegistry
var keyVault = settings.resourceGroups.services.resources.keyVault
var prometheusWorkspace = settings.resourceGroups.services.resources.prometheusWorkspace
var grafanaDashboard = settings.resourceGroups.services.resources.grafanaDashboard

var managedClusters = settings.resourceGroups.clusters.resources.managedClusters

// ----------
// Parameters
// ----------

param defaults object
param settings object
param clusters array
