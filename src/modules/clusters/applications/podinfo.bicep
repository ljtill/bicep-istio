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

// Namespace
resource namespace 'core/Namespace@v1' = {
  metadata: {
    name: settings.namespace
    labels: {
      'istio.io/rev': 'asm-1-17'
    }
  }
}

// Peer Authentication
#disable-next-line BCP081
resource mtls 'security.istio.io/PeerAuthentication@v1beta1' = {
  metadata: {
    name: 'default'
    namespace: settings.namespace
  }
  spec: {
    mtls: {
      mode: 'STRICT'
    }
  }
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
}

// Virtual Service
#disable-next-line BCP081
resource service 'networking.istio.io/VirtualService@v1alpha3' = {
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
              host: 'podinfo'
              port: {
                number: 9898
              }
            }
          }
        ]
      }
    ]
  }
}

// Service Account
resource account 'core/ServiceAccount@v1' = {
  metadata: {
    name: 'podinfo-reconciler'
    namespace: settings.namespace
  }
}

// Role
resource role 'rbac.authorization.k8s.io/Role@v1' = {
  metadata: {
    name: 'podinfo-reconciler'
    namespace: settings.namespace
  }
  rules: [
    {
      apiGroups: [ '*' ]
      resources: [ '*' ]
      verbs: [ '*' ]
    }
  ]
}

// Role Binding
resource binding 'rbac.authorization.k8s.io/RoleBinding@v1' = {
  metadata: {
    name: 'podinfo-reconciler'
    namespace: settings.namespace
  }
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io'
    kind: 'Role'
    name: 'podinfo-reconciler'
  }
  subjects: [
    {
      kind: 'ServiceAccount'
      name: 'podinfo-reconciler'
      namespace: settings.namespace
    }
  ]
}

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
}

// Release
#disable-next-line BCP081
resource release 'helm.toolkit.fluxcd.io/HelmRelease@v2beta1' = {
  metadata: {
    name: 'podinfo'
    namespace: settings.namespace
  }
  spec: {
    serviceAccountName: 'podinfo-reconciler'
    releaseName: 'podinfo'
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
    install: {
      remediation: {
        retries: 3
      }
    }
  }
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
