// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Kubernetes Service
resource cluster 'Microsoft.ContainerService/managedClusters@2023-07-02-preview' = {
  name: resources.containerService.name
  location: resourceGroup().location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: resources.containerService.name
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
    }
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
    serviceMeshProfile: {
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
    servicePrincipalProfile: {
      clientId: 'msi'
    }
  }
}

// -------
// Modules
// -------

module assignment './assignment.bicep' = {
  name: 'Microsoft.Authorization'
  scope: resourceGroup(settings.resourceGroups.services.name)
  params: {
    defaults: defaults
    settings: settings
    resourceId: cluster.id
    objectId: cluster.properties.identityProfile.kubeletidentity.objectId
  }
}

// ---------
// Variables
// ---------

var resources = settings.resourceGroups.clusters.resources

// ----------
// Parameters
// ----------

param defaults object
param settings object
