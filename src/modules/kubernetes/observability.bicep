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

// resource metricsSettings 'core/ConfigMap@v1' = {
//   metadata: {
//     name: 'ama-metrics-settings-configmap'
//     namespace: 'kube-system'
//   }
//   data: defaults.metricsSettings
// }

// resource metricsConfig 'core/ConfigMap@v1' = {
//   metadata: {
//     name: 'ama-metrics-prometheus-config'
//     namespace: 'kube-system'
//   }
//   data: defaults.metricsConfig
// }

// ----------
// Parameters
// ----------

@secure()
param kubeConfig string
