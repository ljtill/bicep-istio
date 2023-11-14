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

// Peer Authentication
#disable-next-line BCP081
resource authentication 'security.istio.io/PeerAuthentication@v1beta1' = {
  metadata: {
    name: settings.name
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
    name: settings.name
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
resource service 'networking.istio.io/VirtualService@v1beta1' = {
  metadata: {
    name: settings.name
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
              host: settings.name
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
