# Update Platform Components and Dependencies

Use this when upgrading chart versions, changing chart settings, or adding/removing a platform/dependency component.

## Platform Components (Cilium, Traefik, Vault, etc.)

Primary files:

- `platform-gitops/env-appsets/dev/platform-apps.yaml`
- `platform-gitops/env-appsets/prod/platform-apps.yaml`
- `platform-helm/envs/dev/platform/.../values.yaml`
- `platform-helm/envs/prod/platform/.../values.yaml`

### Upgrade an existing platform component

1. Update chart version in both dev and prod appsets (`chartVersion`).
2. Update env values files if required by chart breaking changes.
3. Keep sync wave ordering intact unless you intentionally change orchestration.

### Add a new platform component

1. Create values files:
   - `platform-helm/envs/dev/platform/<domain>/<component>/values.yaml`
   - `platform-helm/envs/prod/platform/<domain>/<component>/values.yaml`
2. Add an element in dev/prod platform appsets with:
   - `name`, `chartRepo`, `chartName`, `chartVersion`, `targetNamespace`, `valuesPath`, `syncWave`
3. If the component needs extra values from another repo path (like Falco rules), model it similarly with an optional key and template condition.

### Remove a platform component

1. Remove the element from dev/prod platform appsets.
2. Remove associated values files.
3. If `prune` is false in target env, manually delete stale Argo Application/resource once.

## App Dependencies (MongoDB, PostgreSQL, Redis, Kafka)

Primary files:

- `platform-gitops/env-appsets/dev/dependency-apps.yaml`
- `platform-gitops/env-appsets/prod/dependency-apps.yaml`
- `platform-helm/envs/dev/applications/app-dependencies/.../values.yaml`
- `platform-helm/envs/prod/applications/app-dependencies/.../values.yaml`

### Upgrade dependency chart version

1. Bump `chartVersion` in dev/prod dependency appsets.
2. Adjust values in env files as needed.
3. Validate generated Applications and watch rollout state in Argo.

### Add dependency

1. Create values files for dev/prod under proper folder.
2. Add list generator entries in both dependency appsets.
3. Set a sync wave:
   - same-layer DB dependencies usually `"0"`
   - message-broker often `"1"` (or as needed for ordering)

### Remove dependency

1. Remove list entries in both appsets.
2. Remove values files.
3. Plan data migration/decommission before deleting stateful workloads.
