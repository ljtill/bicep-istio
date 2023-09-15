// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Role Assignment
resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceId)
  scope: registry
  properties: {
    principalId: objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', definitionIds.AcrPull)
  }
}

// ---------
// Resources
// ---------

// Container Registry
resource registry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' existing = {
  name: settings.resourceGroups.services.resources.containerRegistry.name
}

// ---------
// Variables
// ---------

var definitionIds = {
  AcrPull: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

// ----------
// Parameters
// ----------

param defaults object
param settings object

param resourceId string
param objectId string
