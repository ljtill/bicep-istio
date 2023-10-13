# Istio

This repository contains the infra-as-code components for rapidly provisioning an Azure Kubernetes Service cluster, leveraging Azure Service Mesh (Istio) for managing Ingress & Egress gateways, and mTLS encryption. Additionally, within this cluster, we have implemented the Flux extension for deploying the Podinfo application as a sample use case.

_Please note these artifacts are under development and subject to change._

---

## Getting Started

Before creating the Deployment Stack, the Bicep parameter file needs to be updated (`src/main.bicepparam`).

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
---

## Architecture

### Platform Resources

```mermaid
flowchart TD
  kubernetes(Kubernetes)

  kubernetes -->
  registry(Container Registry)

  kubernetes -->
  vault(Key Vault)

  kubernetes -->
  identity(Managed Identity)

  kubernetes -->
  prometheus(Prometheus)

  kubernetes -->
  grafana(Grafana)
```

---

### Traffic Flow

```mermaid
flowchart LR
  subgraph External
    user(User)
  end

  subgraph Azure
    direction LR
    user-->ipAddress(Public IP)-->loadBalancer(Load Balancer)
  end

  subgraph kubernetes[Kubernetes]
    direction LR
    loadBalancer-->ingress(Ingress Gateway)

    subgraph istio[Istio]
      ingress-->gateway(Gateway)-->service(Virtual Service)-->pod(Pod)
    end
  end

```
