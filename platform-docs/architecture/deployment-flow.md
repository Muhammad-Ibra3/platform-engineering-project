# Deployment Flow

## High-level sequence

1. Developer opens PR or merges to main.
2. CI builds/scans/signs images and updates GitOps values where required.
3. Git changes land in this repository.
4. Argo CD syncs the environment ApplicationSets.
5. ApplicationSets generate Applications per component/service.
6. Helm/manifests apply to cluster namespaces.
7. Argo CD self-heals drift and prunes removed resources (where configured).

## Preview flow (PR)

1. CI writes preview overlays to:
   - `platform-helm/envs/preview/microservices/preview-<PR_NUMBER>/`
2. Preview ApplicationSet discovers each preview folder.
3. For each service in generator list, Argo creates an Application:
   - Name: `preview-<folder>-<service>`
   - Namespace: `preview-<folder>`
4. On PR close/cleanup workflow, preview folder is removed and Argo prunes resources.

## Dev/prod flow

1. Bootstrap app (`argo-init-dev` or `argo-init-prod`) points Argo to the env appset folder.
2. Env appsets deploy:
   - Platform components
   - Policy apps
   - Dependencies
   - Microservices
3. Values are resolved from `platform-helm/envs/<env>/...`.

## Where to change what

- Change chart templates/defaults:
  - `platform-helm/general/microservices`
- Change environment behavior:
  - `platform-helm/envs/<env>/...`
- Change orchestration/order/components:
  - `platform-gitops/env-appsets/<env>/...`
- Change bootstrap target:
  - `platform-gitops/argo/argo-init-*.yaml`
