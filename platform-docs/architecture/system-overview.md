# System Overview

## Purpose

This platform provides a GitOps-managed runtime for microservices, platform services, and shared dependencies across `dev`, `prod`, and `preview` environments.

## Core building blocks

- **Infrastructure bootstrap**: Terraform and bootstrap manifests install Argo CD and point it at environment appsets.
- **GitOps control plane**: Argo CD + ApplicationSets continuously reconcile desired state from Git.
- **Helm sources**:
  - Shared chart logic in `platform-helm/general/microservices`
  - Environment values in `platform-helm/envs/<env>/...`
- **Policy and runtime security**:
  - Kyverno policies from `platform-security/kyverno`
  - Falco custom rules from `platform-security/falco/rules.yaml`

## Environment model

- **dev**: fast iteration, full automation, prune enabled.
- **prod**: controlled production rollout with stricter change discipline.
- **preview**: per-PR ephemeral namespaces generated from CI overlays.

## Layering and ordering

Deployments are layered via sync waves:

1. Networking and ingress foundations.
2. Core platform services (secrets/identity/security).
3. Observability and cost tooling.
4. Stateful dependencies (databases, broker).
5. Microservices.

This ordering reduces startup race conditions and avoids failing workloads caused by missing dependencies.
