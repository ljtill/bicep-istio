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

// Config Maps
resource metrics 'core/ConfigMap@v1' = {
  metadata: {
    name: 'ama-metrics-settings-configmap'
    namespace: 'kube-system'
  }
  data: loadYamlContent('../../configs/metrics.yaml')
}

// ----------
// Parameters
// ----------

@secure()
param kubeConfig string
