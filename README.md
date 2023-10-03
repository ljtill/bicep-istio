# Istio

This repository contains the infra-as-code components to quickly scaffold a new
Azure Kubernetes Service cluster with Istio service mesh.

_Please note these artifacts are under development and subject to change._

---

## Architecture

### Azure

```mermaid
flowchart LR
  groups((Resource Groups)) -->
    clustersResourceGroup[Clusters] -->
      clustersResources((Resources)) -->
        kubernetes[Kubernetes Service]

  groups((Resource Groups)) -->
    servicesResourceGroup[Services] -->
      servicesResources((Resources))

      servicesResources((Resources)) -->
        registry[Container Registry]
      servicesResources((Resources)) -->
        vault[Key Vault]
      servicesResources((Resources)) -->
        grafana[Managed Grafana]
      servicesResources((Resources)) -->
        prometheus[Managed Prometheus]


```

### Kubernetes

```mermaid
flowchart LR
  kube((Kubernetes)) -->
    ns((Namespace)) --> aks-istio-system

      aks-istio-system -->
        pods((Pods)) --> istiod-asm-1-17-abc
        pods((Pods)) --> istiod-asm-1-17-xyz

      aks-istio-system -->
        svcs((Services)) --> service[istiod-asm-1-17]

      aks-istio-system -->
        deploy((Deployments)) --> deployment[istiod-asm-1-17]

      aks-istio-system -->
        rs((ReplicaSets)) --> replicaset[istiod-asm-1-17-xxx]

      aks-istio-system -->
        as((PodAutoscaler)) --> autoscaler[istiod-asm-1-17]

    ns((Namespace)) --> aks-istio-ingress
    ns((Namespace)) --> aks-istio-egress

  kube((Kubernetes)) -->
    node((Nodes)) --> aks-system-xxx
    node((Nodes)) --> aks-user-xxx
```

---

## Getting Started

```bash
az stack sub list
```

```bash
az stack sub create \
  --name 'default' \
  --location 'uksouth' \
  --template-file ./src/main.bicep \
  --parameters ./src/main.bicepparam \
  --delete-all \
  --deny-settings-mode none \
  --yes
```

```bash
az stack sub delete \
  --name 'default' \
  --delete-all \
  --yes
```
