# Platform Helm Charts

## Overview

This directory contains **Helm charts used to deploy platform workloads and microservices**.

Each service is packaged as an independent chart to support **independent lifecycle management** and GitOps deployment.

Umbrella charts are intentionally avoided to maintain clear service boundaries.

---

## Responsibilities

Helm charts define Kubernetes resources for:

* application microservices
* infrastructure services
* supporting components

Each chart includes templates for:

* deployments
* services
* configuration
* autoscaling

---

## Chart Structure

Each service chart follows the standard Helm structure:

```
service-name
├── Chart.yaml
├── values.yaml
└── templates
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── configmap.yaml
    └── hpa.yaml
```

---

## Directory Structure

```
platform-helm
├── charts
│   ├── auth-service
│   ├── order-service
│   ├── user-service
│   ├── kafka
│   ├── postgres
│   ├── redis
│   └── mongodb
│
└── environments
    ├── dev
    └── prod
```

---

## Deployment Strategy

Helm charts are not deployed manually.

Instead they are deployed through:

ArgoCD GitOps configuration.

Environment-specific values are stored separately.

---

## Design Goals

* independent service lifecycle
* reusable Helm templates
* clear separation between platform and applications
