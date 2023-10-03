using './main.bicep'

param settings = {
  resourceGroups: {
    clusters: {
      name: ''
      location: ''
      resources: {
        managedClusters: [
          {
            name: ''
            tags: {}
            properties: {
              resourceGroup: ''
            }
          }
        ]
      }
      tags: {}
    }
    services: {
      name: ''
      location: ''
      resources: {
        containerRegistry: {
          name: ''
          properties: {
            sku: 'Standard'
          }
          tags: {}
        }
        keyVault: {
          name: ''
          properties: {
            sku: {
              family: 'A'
              name: 'standard'
            }
          }
        }
        prometheusWorkspace: {
          name: ''
          properties: {}
        }
        grafanaDashboard: {
          name: ''
          properties: {
            sku: 'Standard'
          }
        }
      }
      tags: {}
    }
  }
}
