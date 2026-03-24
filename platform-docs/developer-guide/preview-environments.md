# Preview Environments

Preview environments are created from PR context and reconciled by Argo CD ApplicationSet.

## Files involved

- AppSet: `platform-gitops/env-appsets/preview/preview-appset.yaml`
- CI create/update: `.github/workflows/ci-tasks/update-gitops.yaml`
- CI cleanup: `.github/workflows/preview-envs/preview-destroy.yaml`
- Generated values root: `platform-helm/envs/preview/microservices/`

## How it works

1. CI writes a folder:
   - `platform-helm/envs/preview/microservices/preview-<PR_NUMBER>/`
2. CI copies dev service overlays and updates image tags.
3. Preview appset discovers each folder under:
   - `platform-helm/envs/preview/microservices/*`
4. For each discovered folder and each service, Argo creates an Application.
5. Destination namespace:
   - `preview-<folder-name>`

## Expected files in a preview folder

- `api-gateway-values.yaml`
- `reader-values.yaml`
- `writer-values.yaml`
- plus any additional service overlays you introduce later

## Adding a new service to preview

1. Add the service to list generators in:
   - `platform-gitops/env-appsets/dev/microservices.yaml`
   - `platform-gitops/env-appsets/prod/microservices.yaml`
   - `platform-gitops/env-appsets/preview/preview-appset.yaml`
2. Ensure CI mapping in `update-gitops.yaml` resolves the service name correctly.
3. Ensure dev overlay exists so CI can copy it as preview base.

## Common failure modes

- Missing overlay file for service.
- Service exists in appset but not in chart base (`charts/microservices/<service>/values.yaml`).
- Incorrect preview folder path (must be directly under `envs/preview/microservices/`).
