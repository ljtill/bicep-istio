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

// Kubernetes
resource cluster 'Microsoft.ContainerService/managedClusters@2023-09-02-preview' = {
  name: settings.resourceGroups.clusters.resources.managedCluster.name
  location: settings.resourceGroups.clusters.location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: settings.resourceGroups.clusters.resources.managedCluster.name
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
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
      {
        name: 'user'
        count: 5
        vmSize: 'Standard_D8ds_v5'
        enableAutoScaling: true
        minCount: 3
        maxCount: 20
        osType: 'Linux'
        mode: 'User'
        availabilityZones: [ '1', '2', '3' ]
      }
    ]
    autoUpgradeProfile: {
      upgradeChannel: 'stable'
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
}

resource associations 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: settings.resourceGroups.clusters.resources.managedCluster.name
  scope: cluster
  properties: {
    dataCollectionRuleId: workspace.properties.defaultIngestionSettings.dataCollectionRuleResourceId
    description: 'Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster.'
  }
}

// ---------
// Resources
// ---------

resource workspace 'Microsoft.Monitor/accounts@2023-04-03' existing = {
  name: settings.resourceGroups.services.resources.prometheusWorkspace.name
  scope: resourceGroup(settings.resourceGroups.services.name)
}

// ----------
// Parameters
// ----------

param defaults Defaults
param settings Settings
