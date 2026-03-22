# Developer Guide

Operational runbooks for developers and platform engineers.

## Quick Links

- `path-reference.md` - Current authoritative path map.
- `add-microservice.md` - How to onboard a new microservice end-to-end.
- `update-platform-and-dependencies.md` - How to update platform components and data/messaging dependencies.
- `preview-environments.md` - How preview environments are generated and cleaned up.
- `policies-and-security.md` - How to manage Kyverno policies and Falco rules.
- `change-checklist.md` - Pre-merge checklist for safe GitOps changes.

## Core Conventions

- Keep the reusable microservice Helm chart under `platform-helm/general/microservices`.
- Keep environment values under `platform-helm/envs/<env>/...`.
- Keep deployment orchestration under `platform-gitops/env-appsets/...`.
- Prefer explicit values files (`ignoreMissingValueFiles: false` in most appsets), so missing files fail fast.
