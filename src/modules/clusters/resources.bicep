// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Kubernetes Service
resource cluster 'Microsoft.ContainerService/managedClusters@2023-07-02-preview' = {
  name: settings.resourceGroups.clusters.resources.containerService.name
  location: resourceGroup().location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId(identities.kubernetes.resourceGroupName, 'Microsoft.ManagedIdentity/userAssignedIdentities', split(identities.kubernetes.resourceId, '/')[2])}': {} // Split
    }
  }
  properties: {
    nodeResourceGroup: settings.resourceGroups.clusters.resources.containerService.properties.infrastructure
    dnsPrefix: settings.resourceGroups.clusters.resources.containerService.name
    identityProfile: {
      kubeletIdentity: {
        resourceId: resourceId(identities.kubelet.resourceGroupName, 'Microsoft.ManagedIdentity/userAssignedIdentities', split(identities.kubelet.resourceId, '/')[2]) // Split
        clientId: identities.kubelet.properties.clientId
        objectId: identities.kubelet.properties.principalId
      }
    }
    serviceMeshProfile: serviceMeshType == 'ASM' ? serviceMeshConfig : null
    agentPoolProfiles: [
      {
        name: 'system'
        count: 3
        vmSize: 'Standard_D4ds_v5'
        osType: 'Linux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        tags: {}
      }
      {
        name: 'user'
        count: 3
        vmSize: 'Standard_D8ds_v5'
        osType: 'Linux'
        mode: ''
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        tags: {}
      }
    ]
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
    }
  }
}

// Role Assignment
resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (serviceMeshType == 'Istio') {
  name: guid(identities.script.resourceId)
  scope: cluster
  properties: {
    principalId: identities.script.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', defaults.definitionIds.Contributor)
  }
}

// Deployment Script
resource deployment 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (serviceMeshType == 'Istio') {
  name: 'helm'
  location: resourceGroup().location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId(identities.script.resourceGroupName, 'Microsoft.ManagedIdentity/userAssignedIdentities', split(identities.script.resourceId, '/')[2])}': {}
    }
  }
  properties: {
    azCliVersion: '2.51.0'
    retentionInterval: 'PT1H' // 1 Hour
    cleanupPreference: 'Always'
    environmentVariables: [
      {
        name: 'RESOURCE_NAME'
        value: settings.resourceGroups.clusters.resources.containerService.name
      }
      {
        name: 'RESOURCE_GROUP'
        value: settings.resourceGroups.clusters.name
      }
      {
        name: 'COMMAND'
        value: loadTextContent('../../scripts/helm.sh')
      }
    ]
    scriptContent: loadTextContent('../../scripts/azure.sh')
    timeout: 'P1D'
  }
  dependsOn: [
    assignment
  ]
}

// ---------
// Variables
// ---------

var serviceMeshType = settings.resourceGroups.clusters.resources.containerService.properties.serviceMesh

var serviceMeshConfig = {
  mode: 'Istio'
  istio: {
    certificateAuthority: {}
    components: {
      ingressGateways: []
    }
    revisions: [
      'asm-1-17'
    ]
  }
}

// ----------
// Parameters
// ----------

param defaults object
param settings object

param identities object
