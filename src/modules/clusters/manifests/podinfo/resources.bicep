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
    name: 'flux-reconciler'
    namespace: settings.namespace
  }
  dependsOn: [ namespace ]
}

// Role
resource role 'rbac.authorization.k8s.io/Role@v1' = {
  metadata: {
    name: 'flux-reconciler'
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
    name: 'flux-reconciler'
    namespace: settings.namespace
  }
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io'
    kind: 'Role'
    name: 'flux-reconciler'
  }
  subjects: [
    {
      kind: 'ServiceAccount'
      name: 'flux-reconciler'
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
    serviceAccountName: 'flux-reconciler'
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
    serviceAccountName: 'flux-reconciler'
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
