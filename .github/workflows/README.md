# Platform Engineering Project

This repository contains the **platform, GitOps configuration, and shared CI/CD workflow definitions** for the microservices platform.

It acts as the **central control plane** for:
- Kubernetes deployments (via Argo CD)
- Environment configuration (dev, prod, preview)
- Helm charts and values
- Platform services and dependencies
- Reusable CI/CD workflow tasks used by application repositories

---

# 🧠 Overview

This repository defines a **layered platform architecture**:


Platform Infrastructure (Cilium, Cert Manager, Traefik)
↓
Platform Services (Vault, Keycloak)
↓
Policies & Governance (Kyverno)
↓
Application Dependencies (DBs, Kafka, Redis)
↓
Microservices
↓
Preview Environments (per PR)


All resources are deployed using:
- Argo CD
- ApplicationSets
- Helm
- GitOps principles

---

# 📁 Repository Structure


platform-gitops/
├── env-appsets/
│ ├── dev/
│ ├── prod/
│ └── preview/

platform-helm/
├── charts/
│ └── microservices/
├── envs/
│ ├── dev/
│ ├── prod/
│ └── preview/

.github/
└── workflows/
├── ci-tasks/
└── preview-envs/


---

# 🚀 Bootstrap Process

The cluster is bootstrapped using a single Argo CD Application:

```yaml
cluster-workloads-bootstrap-prod
```

This Application:

Points to platform-gitops/env-appsets/prod
Recursively applies all ApplicationSets
Bootstraps the entire platform

# ⚙️ GitOps Model

This repository follows strict GitOps principles:

Declarative configuration
Version-controlled infrastructure
Automated reconciliation via Argo CD
Self-healing clusters
Deterministic deployments (no HEAD in production)

# 🔁 CI/CD — Reusable Workflow Tasks

This repository defines reusable GitHub Actions workflows used by application repositories.

They are located in:

```yaml
.github/workflows/ci-tasks/
```

# 🔧 Available CI Tasks

`detect-service.yaml`

Detects which services changed in a PR.

`build-service.yaml`

Builds Docker images for changed services.

`security-scan.yaml`

Runs container vulnerability scans before pushing.

`push-and-sign.yaml`

Pushes images to the registry and signs them using Cosign.

`push-image.yaml` and `sign-image.yaml` are deprecated compatibility stubs.

`update-gitops.yaml`

Updates preview environment values to trigger deployments via Argo CD.

# 🧹 Preview Cleanup Workflow
```yaml
.github/workflows/preview-envs/preview-destroy.yaml
```

Removes preview environment values when a PR is closed.

# 🔄 CI/CD Flow (Driven by Microservices Repo)

Although CI is triggered in the microservices repo, the logic lives here.

Detect changed services
↓
Build images
↓
Scan images
↓
Push and sign images
↓
Update GitOps preview values
↓
Argo CD deploys preview environment

# 🌍 Environments
## Environment	Purpose
dev	Development/testing
prod	Production
preview	Ephemeral PR environments

# 🔁 Sync Behavior

All applications use:

Automated sync
Self-healing
Pruning enabled
Retry with backoff

# 🧩 Deployment Ordering (Sync Waves)
Layer	Wave
Networking	0
Core Services	1–3
Observability	4–5
Policies	6
Dependencies	0–1
Microservices	10

# 🧪 Preview Environments

Preview environments are created per PR:

platform-helm/envs/preview/microservices/<pr-number>/

Each PR gets:

its own namespace
isolated services
auto deployment via Argo CD

On PR close:

GitOps values are removed
Argo CD prunes resources

# 🧱 Why CI Tasks Live Here

Reusable workflows are defined in this repo to:

Centralize CI/CD logic
Enforce consistent standards
Reduce duplication
Improve security and governance

# 🧠 Architecture Summary
Microservices Repo
  └─ Calls reusable CI workflows from this repo

Platform Repo (this repo)
  ├─ Defines CI tasks
  ├─ Defines GitOps manifests
  ├─ Defines Helm charts
  └─ Drives Argo CD deployments