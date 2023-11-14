// ---------
// Providers
// ---------

provider 'kubernetes@1.0.0' with {
  kubeConfig: kubeConfig
  namespace: 'default'
}

// ---------
// Resources
// ---------

// Namespace
resource namespace 'core/Namespace@v1' = {
  metadata: {
    name: settings.namespace
    labels: {
      'istio.io/rev': 'asm-1-17'
    }
  }
}

// Service
resource service 'core/Service@v1' = {
  metadata: {
    name: settings.name
    namespace: settings.namespace
  }
  spec: {
    selector: {
      app: settings.name
    }
    ports: [
      {
        port: 9898
      }
    ]
  }
}

// Deployment
resource deployment 'apps/Deployment@v1' = {
  metadata: {
    name: settings.name
    namespace: settings.namespace
  }
  spec: {
    replicas: 3
    selector: {
      matchLabels: {
        app: settings.name
      }
    }
    template: {
      metadata: {
        labels: {
          app: settings.name
        }
      }
      spec: {
        containers: [
          {
            name: settings.name
            image: 'ghcr.io/stefanprodan/podinfo:latest'
            ports: [
              {
                containerPort: 9898
              }
            ]
          }
        ]
      }
    }

  }
}

// ---------
// Variables
// ---------

var settings = {
  name: 'podinfo'
  namespace: 'apps-podinfo'
}

// ----------
// Parameters
// ----------

@secure()
param kubeConfig string
