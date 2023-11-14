// -------
// Imports
// -------

import { Defaults } from './types/defaults.bicep'
import { Settings } from './types/settings.bicep'

// ------
// Scopes
// ------

targetScope = 'subscription'

// -------
// Modules
// -------

module azure './modules/azure/resources.bicep' = {
  name: 'Microsoft.Resources'
  scope: subscription()
  params: {
    defaults: defaults
    settings: settings
  }
}

module kubernetes './modules/kubernetes/resources.bicep' = {
  name: 'Kubernetes.Resources'
  scope: subscription()
  params: {
    defaults: defaults
    settings: settings
  }
  dependsOn: [
    azure
  ]
}

// ---------
// Variables
// ---------

var defaults = loadJsonContent('defaults.json')

// ----------
// Parameters
// ----------

param settings Settings
