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
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
}

// Role Assignment
resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(identities.kubelet.resourceId)
  scope: registry
  properties: {
    principalId: identities.kubelet.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.AcrPull)
  }
}

// ----------
// Parameters
// ----------

param defaults object
param settings object
param identities object
