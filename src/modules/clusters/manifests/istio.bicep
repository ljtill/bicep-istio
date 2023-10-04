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
    name: 'aks-istio-config'
  }
}

// Peer Authentication
#disable-next-line BCP081
resource mtls 'security.istio.io/PeerAuthentication@v1beta1' = {
  metadata: {
    name: 'default'
    namespace: 'aks-istio-config'
  }
  spec: {
    mtls: {
      mode: 'STRICT'
    }
  }
}

// Virtual Service
// apiVersion: networking.istio.io/v1alpha3
// kind: VirtualService
// metadata:
//   name: bookinfo-vs-external
// spec:
//   hosts:
//   - "*"
//   gateways:
//   - bookinfo-gateway-external
//   http:
//   - match:
//     - uri:
//         exact: /productpage
//     route:
//     - destination:
//         host: productpage
//         port:
//           number: 9080

// ----------
// Parameters
// ----------

@secure()
param kubeConfig string
