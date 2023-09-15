// ------
// Scopes
// ------

targetScope = 'subscription'

// ---------
// Resources
// ---------

resource services 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: settings.resourceGroups.services.name
  location: settings.resourceGroups.services.location
  properties: {}
  tags: settings.resourceGroups.services.tags
}

resource clusters 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: settings.resourceGroups.clusters.name
  location: settings.resourceGroups.clusters.location
  properties: {}
  tags: settings.resourceGroups.clusters.tags
}

// ----------
// Parameters
// ----------

param defaults object
param settings object
