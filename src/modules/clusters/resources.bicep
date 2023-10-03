// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Kubernetes Service
resource clusters 'Microsoft.ContainerService/managedClusters@2023-07-02-preview' = [for managedCluster in managedClusters: {
  name: managedCluster.name
  location: resourceGroup().location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    nodeResourceGroup: managedCluster.properties.resourceGroup
    dnsPrefix: managedCluster.name
    agentPoolProfiles: [
      {
        name: 'system'
        count: 3
        vmSize: 'Standard_D4ds_v5'
        enableAutoScaling: false
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
        enableAutoScaling: true
        minCount: 1
        maxCount: 20
        osType: 'Linux'
        mode: 'User'
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
    azureMonitorProfile: {
      metrics: {
        enabled: true
        kubeStateMetrics: {
          metricLabelsAllowlist: ''
          metricAnnotationsAllowList: ''
        }
      }
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
          rotationPollInterval: '2m'
        }
      }
    }
    serviceMeshProfile: {
      mode: 'Istio'
      istio: {
        components: {
          ingressGateways: [
            {
              enabled: true
              mode: 'External'
            }
          ]
        }
      }
    }
  }
}]

// ---------
// Variables
// ---------

var managedClusters = settings.resourceGroups.clusters.resources.managedClusters

// ----------
// Parameters
// ----------

param defaults object
param settings object

// -------
// Outputs
// -------

output clusters array = [for (managedCluster, i) in managedClusters: clusters[i]]
