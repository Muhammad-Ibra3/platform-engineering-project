# Platform Helm Charts

## Overview

This directory contains **Helm charts and environment values** for platform workloads and microservices.

- **`charts/`** — Reusable Helm chart sources (templates + default `values.yaml` per subchart).
- **`envs/`** — Environment-specific value files only (no duplicated `templates/` per env).

Argo CD ApplicationSets under `platform-gitops/env-appsets/` point at these paths.

---

## Layout

```
platform-helm
├── charts
│   └── microservices/           # Helm chart: Chart.yaml, templates/, <service>/values.yaml
│       ├── api-gateway/
│       ├── reader/
│       └── writer/
│
└── envs
    ├── dev
    │   ├── platform/            # Values for third-party platform charts (Cilium, Vault, …)
    │   └── applications
    │       ├── microservices/   # Flat overlays: api-gateway-values.yaml, reader-values.yaml, …
    │       └── app-dependencies/
    │           ├── databases/   # mongodb, postgresdb, redis — values.yaml each
    │           └── message-queue/kafka/
    ├── prod
    │   ├── platform/
    │   └── applications/        # Same shape as dev
    └── preview
        └── microservices/
            └── preview-<PR>/    # CI: per-PR copies + image tag bumps
```

---

## How values are merged

| Workload        | Chart path                         | Env values |
|----------------|-------------------------------------|------------|
| Microservices  | `charts/microservices`             | `envs/<env>/applications/microservices/<service>-values.yaml` |
| Dependencies   | Upstream Bitnami chart (no local chart) | `envs/<env>/applications/app-dependencies/.../values.yaml` |
| Platform stack | Upstream charts                     | `envs/<env>/platform/.../values.yaml` (+ Falco rules from `platform-security/`) |

---

## Deployment

Charts are deployed via **Argo CD** (GitOps), not manual `helm install` in production paths.

---

## Design goals

- One place for shared Helm logic (`charts/`).
- Clear env separation under `envs/` without copying templates.
- Independent lifecycle per workload via Application / ApplicationSet entries.
