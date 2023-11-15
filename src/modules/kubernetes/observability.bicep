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
resource prometheus 'core/ConfigMap@v1' = {
  metadata: {
    name: 'ama-metrics-prometheus-config'
    namespace: 'kube-system'
  }
  data: {
    'prometheus-config': loadTextContent('../../configs/prometheus.yaml')
  }
}

resource settings 'core/ConfigMap@v1' = {
  metadata: {
    name: 'ama-metrics-settings-configmap'
    namespace: 'kube-system'
  }
  data: loadYamlContent('../../configs/settings.yaml')
}

// ----------
// Parameters
// ----------

@secure()
param kubeConfig string
