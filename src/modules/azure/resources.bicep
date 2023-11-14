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

module groups './groups.bicep' = {
  name: 'Microsoft.Resources.Groups'
  scope: subscription()
  params: {
    defaults: defaults
    settings: settings
  }
}

module services './services.bicep' = {
  name: 'Microsoft.Resources.Services'
  scope: resourceGroup(settings.resourceGroups.services.name)
  params: {
    defaults: defaults
    settings: settings
  }
  dependsOn: [
    groups
  ]
}

module clusters './clusters.bicep' = {
  name: 'Microsoft.Resources.Clusters'
  scope: resourceGroup(settings.resourceGroups.clusters.name)
  params: {
    defaults: defaults
    settings: settings
  }
  dependsOn: [
    services
  ]
}

module assocations './assignments.bicep' = {
  name: 'Microsoft.Resources.Assocations'
  scope: resourceGroup(settings.resourceGroups.services.name)
  params: {
    defaults: defaults
    settings: settings
  }
}

// ----------
// Parameters
// ----------

param defaults Defaults
param settings Settings
