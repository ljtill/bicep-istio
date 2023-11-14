using './main.bicep'

param settings = {
  resourceGroups: {
    clusters: {
      location: ''
      name: ''
      resources: {
        managedCluster: {
          name: ''
        }
      }
      tags: {}
    }
    services: {
      location: ''
      name: ''
      resources: {
        containerRegistry: {
          name: ''
        }
        grafanaDashboard: {
          name: ''
          assignments: []
        }
        keyVault: {
          name: ''
        }
        prometheusWorkspace: {
          name: ''
        }
      }
      tags: {}
    }
  }
}
