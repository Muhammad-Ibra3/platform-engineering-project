# Platform Backstage

This directory contains Backstage-specific platform assets and scaffolding used by GitOps deployment.

## Scope
- Catalog descriptors and templates
- Plugin scaffolding and contracts
- Environment-specific app-config extensions (when needed)

## Deployment Source of Truth
Backstage runtime deployment is managed from:
- `platform-gitops/env-appsets/dev/platform-apps.yaml`
- `platform-helm/envs/dev/platform/developer-portal/backstage/values.yaml`

## Auth
Backstage access in dev is configured for Keycloak OIDC.
Ensure the Keycloak realm/client and Kubernetes secrets are created before first login.
