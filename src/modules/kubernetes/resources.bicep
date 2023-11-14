// -------
// Imports
// -------

import { Defaults } from '../../types/defaults.bicep'
import { Settings } from '../../types/settings.bicep'

// ------
// Scopes
// ------

targetScope = 'subscription'

// -------
// Modules
// -------

module observability './observability.bicep' = {
  name: 'Kubernetes.Resources.Observability'
  scope: resourceGroup(settings.resourceGroups.clusters.name)
  params: {
    kubeConfig: cluster.listClusterAdminCredential().kubeconfigs[0].value
  }
}

module application './application.bicep' = {
  name: 'Kubernetes.Resources.Application'
  scope: resourceGroup(settings.resourceGroups.clusters.name)
  params: {
    kubeConfig: cluster.listClusterAdminCredential().kubeconfigs[0].value
  }
  dependsOn: [ observability ]
}

module network './network.bicep' = {
  name: 'Kubernetes.Resources.Network'
  scope: resourceGroup(settings.resourceGroups.clusters.name)
  params: {
    kubeConfig: cluster.listClusterAdminCredential().kubeconfigs[0].value
  }
  dependsOn: [ application ]
}

// ---------
// Resources
// ---------

resource cluster 'Microsoft.ContainerService/managedClusters@2023-09-02-preview' existing = {
  name: settings.resourceGroups.clusters.resources.managedCluster.name
  scope: resourceGroup(settings.resourceGroups.clusters.name)
}

// ----------
// Parameters
// ----------

param defaults Defaults
param settings Settings
