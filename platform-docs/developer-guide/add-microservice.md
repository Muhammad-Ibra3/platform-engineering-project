# Add a New Microservice

This guide walks through adding a new service (example: `billing`) to dev/prod/preview flows.

## 1) Add base chart values

Create:

- `platform-helm/charts/microservices/billing/values.yaml`

Start by copying one of the existing service value files (for example `reader/values.yaml`) and changing names, image repository, ports, and probes.

## 2) Add environment overlays

Create:

- `platform-helm/envs/dev/applications/microservices/billing-values.yaml`
- `platform-helm/envs/prod/applications/microservices/billing-values.yaml`

Keep only env-specific differences in these files (replicas, resources, ingress host, feature flags, etc.).

## 3) Register service in dev/prod appsets

Update:

- `platform-gitops/env-appsets/dev/microservices.yaml`
- `platform-gitops/env-appsets/prod/microservices.yaml`

Add a new element in each list generator:

```yaml
- service: billing
  syncWave: "10"
```

The appset template already resolves:

- chart base: `{{.service}}/values.yaml`
- env overlay: `platform-helm/envs/<env>/applications/microservices/{{.service}}-values.yaml`

## 4) Ensure preview workflow can map your service name

If your CI changed-service name may differ from the Helm service name, update mapper logic in:

- `.github/workflows/ci-tasks/update-gitops.yaml`

Function:

- `map_to_helm()`

Add a case for `billing` if needed so preview overlays are generated to:

- `platform-helm/envs/preview/microservices/preview-<PR_NUMBER>/billing-values.yaml`

## 5) Optional: seed preview defaults

You normally do not commit preview folders permanently, but for local tests you can create:

- `platform-helm/envs/preview/microservices/preview-local/billing-values.yaml`

Preview appset discovery is directory-driven.

## 6) Validate before merge

- Confirm all new files exist and paths are exact.
- Confirm YAML lint passes.
- Confirm appset renders in Argo CD without missing value file errors.
- Open PR and verify preview environment sync.
