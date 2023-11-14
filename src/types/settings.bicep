// -----
// Types
// -----

@export()
type Settings = {
  resourceGroups: {
    clusters: {
      name: string
      location: string
      resources: {
        managedCluster: {
          name: string
          properties: {}?
        }
      }
      tags: object
    }
    services: {
      name: string
      location: string
      resources: {
        containerRegistry: {
          name: string
          properties: {}?
        }
        keyVault: {
          name: string
          properties: {}?
        }
        prometheusWorkspace: {
          name: string
          properties: {}?
        }
        grafanaDashboard: {
          name: string
          properties: {}?
          assignments: {
            name: string
            principalId: string
          }[]?
        }
      }
      tags: object
    }
  }
}
