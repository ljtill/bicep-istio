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
module identities './modules/identities/resources.bicep' = {
  name: 'Microsoft.Resources.Identities'
  scope: resourceGroup(settings.resourceGroups.identities.name)
  params: {
    defaults: defaults
    settings: settings
  }
  dependsOn: [
    groups
  ]
}

module clusters './modules/clusters/resources.bicep' = {
  name: 'Microsoft.Resources.Clusters'
  scope: resourceGroup(settings.resourceGroups.clusters.name)
  params: {
    defaults: defaults
    settings: settings
    identities: identities.outputs.identities
  }
  dependsOn: [
    groups
  ]
}

module services './modules/services/resources.bicep' = {
  name: 'Microsoft.Resources.Services'
  scope: resourceGroup(settings.resourceGroups.services.name)
  params: {
    defaults: defaults
    settings: settings
    identities: identities.outputs.identities
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
