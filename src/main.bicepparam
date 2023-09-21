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
    identities: {
      name: ''
      location: 'uksouth'
      resources: {
        managedIdentity: {
          kubernetes: {
            name: ''
          }
          kubelet: {
            name: ''
          }
          script: {
            name: ''
          }
        }
      }
    }
    clusters: {
      name: ''
      location: 'uksouth'
      resources: {
        containerService: {
          name: ''
          tags: {}
          properties: {
            serviceMesh: 'Istio' // Istio || ASM || None
          }
        }
      }
      tags: {}
    }
  }
}
