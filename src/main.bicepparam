using './main.bicep'

param settings = {
  resourceGroups: {
    services: {
      name: ''
      location: 'uksouth'
      resources: {
        containerRegistry: {
          name: ''
          properties: {
            sku: 'Standard'
          }
          tags: {}
        }
      }
      tags: {}
    }
    clusters: {
      name: ''
      location: 'uksouth'
      resources: {
        containerService: {
          name: ''
          tags: {}
        }
      }
      tags: {}
    }
  }
}
