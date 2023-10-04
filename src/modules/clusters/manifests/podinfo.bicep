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
    name: 'apps-podinfo'
    labels: {
      'istio.io/rev': 'asm-1-17'
    }
  }
}

// Ingress Gateway
#disable-next-line BCP081
resource gateway 'networking.istio.io/Gateway@v1beta1' = {
  metadata: {
    name: 'podinfo-gateway'
    namespace: 'apps-podinfo'
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
    namespace: 'apps-podinfo'
  }
  spec: {
    hosts: [ '*' ]
    gateways: [ 'podinfo-gateway' ]
    http: [
      {
        match: [
          {
            uri: {
              exact: '/'
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
    namespace: 'apps-podinfo'
  }
}

// Role
resource role 'rbac.authorization.k8s.io/Role@v1' = {
  metadata: {
    name: 'podinfo-reconciler'
    namespace: 'apps-podinfo'
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
    namespace: 'apps-podinfo'
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
      namespace: 'apps-podinfo'
    }
  ]
}

// Repository
#disable-next-line BCP081
resource repository 'source.toolkit.fluxcd.io/HelmRepository@v1beta2' = {
  metadata: {
    name: 'podinfo'
    namespace: 'apps-podinfo'
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
    namespace: 'apps-podinfo'
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

// ----------
// Parameters
// ----------

@secure()
param kubeConfig string
