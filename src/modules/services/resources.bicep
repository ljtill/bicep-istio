// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Container Registry
resource registry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' = {
  name: resources.containerRegistry.name
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
}

// ---------
// Variables
// ---------

var resources = settings.resourceGroups.services.resources

// ----------
// Parameters
// ----------

param defaults object
param settings object
