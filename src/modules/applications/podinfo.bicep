// -------
// Imports
// -------

import 'kubernetes@1.0.0' with {
  kubeConfig: kubeConfig
  namespace: 'default'
}

// ---------
// Resources
// ---------

// Kubernetes

// Namespace
resource namespace 'core/Namespace@v1' = {
  metadata: {
    name: settings.namespace
    labels: {
      'istio.io/rev': 'asm-1-17'
    }
  }
}

// Service Account
resource account 'core/ServiceAccount@v1' = {
  metadata: {
    name: 'fluxcd-reconciler'
    namespace: settings.namespace
  }
  dependsOn: [ namespace ]
}

// Role
resource role 'rbac.authorization.k8s.io/Role@v1' = {
  metadata: {
    name: 'fluxcd-reconciler'
    namespace: settings.namespace
  }
  rules: [
    {
      apiGroups: [ '*' ]
      resources: [ '*' ]
      verbs: [ '*' ]
    }
  ]
  dependsOn: [ namespace ]
}

// Role Binding
resource binding 'rbac.authorization.k8s.io/RoleBinding@v1' = {
  metadata: {
    name: 'fluxcd-reconciler'
    namespace: settings.namespace
  }
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io'
    kind: 'Role'
    name: 'fluxcd-reconciler'
  }
  subjects: [
    {
      kind: 'ServiceAccount'
      name: 'fluxcd-reconciler'
      namespace: settings.namespace
    }
  ]
  dependsOn: [ namespace ]
}

// Flux

// Repository
#disable-next-line BCP081
resource repository 'source.toolkit.fluxcd.io/HelmRepository@v1beta2' = {
  metadata: {
    name: 'podinfo'
    namespace: settings.namespace
  }
  spec: {
    interval: '5m'
    url: 'https://stefanprodan.github.io/podinfo'
  }
  dependsOn: [ namespace ]
}

// Release
#disable-next-line BCP081
resource frontend 'helm.toolkit.fluxcd.io/HelmRelease@v2beta1' = {
  metadata: {
    name: 'podinfo-frontend'
    namespace: settings.namespace
  }
  spec: {
    serviceAccountName: 'fluxcd-reconciler'
    releaseName: 'podinfo-frontend'
    interval: '50m'
    chart: {
      spec: {
        chart: 'podinfo'
        sourceRef: {
          kind: 'HelmRepository'
          name: 'podinfo'
        }
      }
    }
    values: {
      logLevel: 'debug'
      backend: 'http://podinfo-backend.apps-podinfo:9898/echo'
    }
  }
  dependsOn: [ namespace ]
}

#disable-next-line BCP081
resource backend 'helm.toolkit.fluxcd.io/HelmRelease@v2beta1' = {
  metadata: {
    name: 'podinfo-backend'
    namespace: settings.namespace
  }
  spec: {
    serviceAccountName: 'fluxcd-reconciler'
    releaseName: 'podinfo-backend'
    interval: '50m'
    chart: {
      spec: {
        chart: 'podinfo'
        sourceRef: {
          kind: 'HelmRepository'
          name: 'podinfo'
        }
      }
    }
    values: {
      logLevel: 'debug'
    }
  }
  dependsOn: [ namespace ]
}

// Istio

// Peer Authentication
#disable-next-line BCP081
resource authentication 'security.istio.io/PeerAuthentication@v1beta1' = {
  metadata: {
    name: 'podinfo'
    namespace: settings.namespace
  }
  spec: {
    mtls: {
      mode: 'STRICT'
    }
  }
  dependsOn: [ namespace ]
}

// Ingress Gateway
#disable-next-line BCP081
resource gateway 'networking.istio.io/Gateway@v1beta1' = {
  metadata: {
    name: 'podinfo-gateway'
    namespace: settings.namespace
  }
  spec: {
    selector: {
      istio: 'aks-istio-ingressgateway-external'
    }
    servers: [
      {
        port: {
          name: 'http'
          protocol: 'HTTP'
          number: 80
        }
        hosts: [ '*' ]
      }
    ]
  }
  dependsOn: [ namespace ]
}

// Virtual Service
#disable-next-line BCP081
resource service 'networking.istio.io/VirtualService@v1beta1' = {
  metadata: {
    name: 'podinfo'
    namespace: settings.namespace
  }
  spec: {
    hosts: [ '*' ]
    gateways: [ gateway.metadata.name ]
    http: [
      {
        match: [
          {
            uri: {
              prefix: '/'
            }
          }
        ]
        route: [
          {
            destination: {
              host: 'podinfo-frontend'
              port: {
                number: 9898
              }
            }
          }
        ]
      }
    ]
  }
  dependsOn: [ namespace ]
}

// ---------
// Variables
// ---------

var settings = {
  namespace: 'apps-podinfo'
}

// ----------
// Parameters
// ----------

@secure()
param kubeConfig string
