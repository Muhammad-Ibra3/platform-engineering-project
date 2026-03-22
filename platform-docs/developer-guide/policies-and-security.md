# Policies and Security Integrations

This repository currently deploys policy and runtime security via Kyverno and Falco.

## Kyverno policies

Primary paths:

- Policies: `platform-security/kyverno/`
- AppSets:
  - `platform-gitops/env-appsets/dev/policy-apps.yaml`
  - `platform-gitops/env-appsets/prod/policy-apps.yaml`

### Add/update a Kyverno policy

1. Add or update manifests under `platform-security/kyverno/`.
2. Keep policy validation mode explicit (`Audit` vs `Enforce`).
3. Verify policy appset is synced in target environment.

## Falco rules

Primary paths:

- Base Falco chart values:
  - `platform-helm/envs/dev/platform/security/falco/values.yaml`
  - `platform-helm/envs/prod/platform/security/falco/values.yaml`
- Custom rules:
  - `platform-security/falco/rules.yaml`
- Platform appsets:
  - `platform-gitops/env-appsets/dev/platform-apps.yaml`
  - `platform-gitops/env-appsets/prod/platform-apps.yaml`

### Add/update Falco rules

1. Edit `platform-security/falco/rules.yaml`.
2. Keep rules scoped to meaningful detections to avoid alert noise.
3. Validate chart sync and rule loading in Falco pods.
