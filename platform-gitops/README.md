# Platform GitOps Repository

This repository contains the **GitOps configuration for the platform**, managing all Kubernetes workloads across environments using Argo CD.

It defines how infrastructure, platform services, dependencies, microservices, and policies are deployed in a **fully declarative and automated manner**.

---

# 🧠 Overview

This repo follows a **layered platform architecture**:

```
Platform Infrastructure
↓
Platform Services
↓
Policies & Governance
↓
Application Dependencies
↓
Microservices
↓
Preview Environments
```

All deployments are managed via:

* **Argo CD**
* **ApplicationSets**
* **Helm charts**
* **Environment-specific values**

---

# 📁 Repository Structure

```
platform-gitops/
├── env-appsets/
│   ├── dev/
│   ├── prod/
│   └── preview/
```

Each environment directory contains **ApplicationSets** responsible for deploying:

* Platform components (networking, ingress, observability)
* Security tools (Kyverno, Falco)
* Dependencies (databases, Kafka)
* Microservices
* Policies

---

# 🚀 Bootstrap Process

The platform is bootstrapped using a single Argo CD Application:

```yaml
cluster-workloads-bootstrap-prod
```

This Application:

* Points to: `platform-gitops/env-appsets/prod`
* Recursively applies all ApplicationSets
* Enables full environment deployment from Git

---

# 🔄 How It Works

1. Argo CD syncs the bootstrap Application
2. ApplicationSets are created per environment
3. Each ApplicationSet generates multiple Applications
4. Applications deploy Helm charts or manifests
5. Clusters converge to the desired state

---

# 🧩 Application Layers

## 1. Platform Infrastructure

Includes:

* CNI (Cilium)
* Ingress (Traefik)
* Cert Manager

## 2. Platform Services

Includes:

* Vault (secrets)
* Keycloak (identity)

## 3. Policies

Includes:

* Kyverno policies

## 4. Dependencies

Includes:

* MongoDB
* PostgreSQL
* Redis
* Kafka

## 5. Microservices

Application workloads deployed via a shared Helm chart with:

* Base config
* Environment-specific overrides

## 6. Preview Environments

Dynamic environments created per PR:

* Isolated namespaces
* Per-service deployments
* Automatically reconciled by Argo CD

---

# ⚙️ GitOps Principles

This repository follows strict GitOps practices:

* **Declarative**: All state defined in Git
* **Versioned**: Changes tracked via commits
* **Automated**: Argo CD handles sync
* **Self-healing**: Drift is corrected automatically
* **Deterministic**: No use of `HEAD` in production

---

# 🔐 Environments

| Environment | Purpose                   |
| ----------- | ------------------------- |
| dev         | Development & testing     |
| prod        | Production workloads      |
| preview     | Ephemeral PR environments |

---

# 🔄 Sync Behavior

All Applications use:

* Automated sync
* Self-healing enabled
* Pruning enabled
* Retry with backoff

---

# 🧱 Deployment Ordering

Applications are deployed using sync waves:

| Layer               | Wave |
| ------------------- | ---- |
| Networking          | 0    |
| Core Infrastructure | 1–3  |
| Observability       | 4–5  |
| Policies            | 6    |
| Dependencies        | 0–1  |
| Microservices       | 10   |

---

# 🛠️ Adding a New Service

1. Add service to ApplicationSet list
2. Create base Helm values:

   ```
   platform-helm/charts/microservices/<service>/values.yaml
   ```
3. Add environment-specific values:

   ```
   platform-helm/envs/<env>/applications/microservices/<service>-values.yaml
   ```
4. Commit and push

Argo CD will automatically deploy the service.

---

# 🧪 Preview Environments

Preview environments are created by:

1. Adding a directory:

   ```
   platform-helm/envs/preview/microservices/<pr-name>/
   ```
2. Adding per-service values files
3. Argo CD automatically provisions:

   * Namespace
   * Services
   * Infrastructure bindings

---

# ⚠️ Important Notes

* All values files must exist (no silent fallbacks)
* Production uses pinned revisions (no `HEAD`)
* Pruning is enabled to prevent drift
* Sync waves ensure correct deployment order

---

# 🚀 Future Improvements

* Argo CD Projects for RBAC isolation
* Dev → Staging → Prod promotion pipelines
* Progressive delivery (canary / blue-green)
* Automated preview environment teardown
* Policy validation in CI

---

# 📌 Summary

This repository defines a **complete internal platform using GitOps**, enabling:

* Fully automated deployments
* Consistent environments
* Scalable microservice management
* Strong separation of concerns

---
