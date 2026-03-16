# Platform GitOps

## Overview

This directory contains the **GitOps configuration for the Kubernetes platform**.

All cluster workloads are deployed declaratively through Git using **ArgoCD**.

Git becomes the **single source of truth** for:

* platform services
* application services
* environment configuration

---

## GitOps Model

The platform follows a **PR → Preview → Dev → Prod deployment workflow**.

Deployment lifecycle:

1. Pull Request opened
2. Preview environment created
3. Application deployed to Dev after merge
4. Promotion pipeline deploys to Production

---

## Responsibilities

This layer manages deployment of:

Platform Services

* ingress controllers
* certificate management
* observability stack
* security tooling

Application Services

* Go CQRS microservices
* supporting databases and message brokers

---

## ArgoCD Structure

The repository uses the **App-of-Apps pattern**.

This allows ArgoCD to manage a hierarchy of applications:

Root Application
→ Platform Services
→ Application Services

---

## Directory Structure

```
platform-gitops
├── clusters
│   ├── dev
│   └── prod
│
├── platform
│   ├── ingress
│   ├── cert-manager
│   ├── observability
│   ├── security
│   └── argocd
│
├── apps
│   └── go-cqrs
│
└── previews
```

---

## Preview Environments

Preview environments are created for each Pull Request.

They run inside isolated namespaces such as:

```
preview-pr-42
preview-pr-73
```

These environments allow developers to test changes before merging.

---

## Design Principles

* Git is the single source of truth
* declarative deployments
* environment reproducibility
* independent service lifecycle
