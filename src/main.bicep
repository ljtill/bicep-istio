// ------
// Scopes
// ------

targetScope = 'subscription'

// -------
// Modules
// -------

// Resource Groups
module groups './modules/groups.bicep' = {
  name: 'Microsoft.ResourceGroups'
  params: {
    defaults: defaults
    settings: settings
  }
}

// Resources
module clusters './modules/clusters/resources.bicep' = {
  name: 'Microsoft.Resources'
  scope: resourceGroup(settings.resourceGroups.clusters.name)
  params: {
    defaults: defaults
    settings: settings
  }
  dependsOn: [
    groups
  ]
}

module services './modules/services/resources.bicep' = {
  name: 'Microsoft.Resources'
  scope: resourceGroup(settings.resourceGroups.services.name)
  params: {
    defaults: defaults
    settings: settings
    clusters: clusters.outputs.clusters
  }
  dependsOn: [
    groups
  ]
}

// ---------
// Variables
// ---------

var defaults = loadJsonContent('defaults.json')

// ----------
// Parameters
// ----------

param settings object
