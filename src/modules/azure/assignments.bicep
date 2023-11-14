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

// Role Assignment
resource registryAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('registries', cluster.id)
  scope: registry
  properties: {
    principalType: 'ServicePrincipal'
    principalId: cluster.properties.identityProfile.kubeletIdentity.objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.AcrPull)
  }
}

// Role Assignment
resource vaultAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('vaults', cluster.id)
  scope: vault
  properties: {
    principalType: 'ServicePrincipal'
    principalId: cluster.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.KeyVaultAdministrator)
  }
}

// Role Assignments
resource userAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for assignment in settings.resourceGroups.services.resources.grafanaDashboard.assignments!: {
  name: guid('user', assignment.name)
  scope: grafana
  properties: {
    principalType: 'User'
    principalId: assignment.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.GrafanaAdmin)
  }
}]

resource dashboardAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(grafana.id)
  scope: account
  properties: {
    principalType: 'ServicePrincipal'
    principalId: grafana.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.MonitoringDataReader)
  }
}

// ---------
// Resources
// ---------

resource cluster 'Microsoft.ContainerService/managedClusters@2023-09-02-preview' existing = {
  name: settings.resourceGroups.clusters.resources.managedCluster.name
  scope: resourceGroup(settings.resourceGroups.clusters.name)
}

resource registry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' existing = {
  name: settings.resourceGroups.services.resources.containerRegistry.name
}

resource vault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: settings.resourceGroups.services.resources.keyVault.name
}

resource grafana 'Microsoft.Dashboard/grafana@2022-10-01-preview' existing = {
  name: settings.resourceGroups.services.resources.grafanaDashboard.name
}

resource account 'Microsoft.Monitor/accounts@2023-04-03' existing = {
  name: settings.resourceGroups.services.resources.prometheusWorkspace.name
}

// ----------
// Parameters
// ----------

param defaults Defaults
param settings Settings
