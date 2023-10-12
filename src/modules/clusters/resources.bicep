// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Kubernetes
resource clusters 'Microsoft.ContainerService/managedClusters@2023-08-02-preview' = [for managedCluster in managedClusters: {
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
        enableAutoScaling: true
        minCount: 1
        maxCount: 5
        osType: 'Linux'
        mode: 'System'
        availabilityZones: [ '1', '2', '3' ]
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
        availabilityZones: [ '1', '2', '3' ]
      }
    ]
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
    }
    azureMonitorProfile: {
      metrics: {
        enabled: true
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
          egressGateways: [
            {
              enabled: true
            }
          ]
        }
      }
    }
  }
}]

// Flux
resource extensionsFlux 'Microsoft.KubernetesConfiguration/extensions@2023-05-01' = [for (managedCluster, i) in managedClusters: {
  name: 'flux'
  scope: clusters[i]
  properties: {
    extensionType: 'microsoft.flux'
    autoUpgradeMinorVersion: true
    releaseTrain: 'Stable'
    configurationSettings: {
      'source-controller.enabled': 'true'
      'helm-controller.enabled': 'true'
      'kustomize-controller.enabled': 'false'
      'notification-controller.enabled': 'true'
      'image-automation-controller.enabled': 'false'
      'image-reflector-controller.enabled': 'false'
    }
  }
}]

// -------
// Modules
// -------

// Podinfo
// module podinfo '../applications/podinfo.bicep' = [for (managedCluster, i) in managedClusters: {
//   name: 'Kubernetes.Applications.Podinfo.${i}'
//   params: {
//     kubeConfig: clusters[i].listClusterAdminCredential().kubeconfigs[0].value
//   }
//   dependsOn: [ extensionsFlux ]
// }]

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
