// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Managed Identity
resource kubernetesIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: settings.resourceGroups.identities.resources.managedIdentity.kubernetes.name
  location: resourceGroup().location
}
resource kubeletIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: settings.resourceGroups.identities.resources.managedIdentity.kubelet.name
  location: resourceGroup().location
}
resource scriptIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (serviceMeshType == 'Istio') {
  name: settings.resourceGroups.identities.resources.managedIdentity.script.name
  location: resourceGroup().location
}

// Role Assignment
resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kubernetesIdentity.id)
  scope: kubeletIdentity
  properties: {
    principalId: kubernetesIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.ManagedIdentityOperator)
  }
}

// ---------
// Variables
// ---------

var serviceMeshType = settings.resourceGroups.clusters.resources.containerService.properties.serviceMesh

// ----------
// Parameters
// ----------

param defaults object
param settings object

// -------
// Outputs
// -------

output identities object = {
  kubernetes: kubernetesIdentity
  kubelet: kubeletIdentity
  script: scriptIdentity
}
