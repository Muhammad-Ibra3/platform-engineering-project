# Update Platform Components and Dependencies

Use this when upgrading chart versions, changing chart settings, or adding/removing a platform/dependency component.

## Chart source and pinning rules

- If using **remote charts** (`source.chart` + `repoURL`), pin with chart `targetRevision` (for example `1.2.3`).
- If using **local vendored charts** (`source.path` under `platform-helm/charts/...`), pin with Git `targetRevision` (commit SHA or tag), not a moving branch name.
- Recommended production practice: avoid floating revisions like `main`.
- See `local-charts.md` for vendoring workflow and examples.

## Platform Components (Cilium, Traefik, Vault, etc.)

Primary files:

- `platform-gitops/env-appsets/dev/platform-apps.yaml`
- `platform-gitops/env-appsets/prod/platform-apps.yaml`
- `platform-helm/envs/dev/platform/.../values.yaml`
- `platform-helm/envs/prod/platform/.../values.yaml`

### Upgrade an existing platform component

1. If remote chart: update chart version in both dev and prod appsets (`targetRevision` chart semver).
2. If local chart: vendor updated chart files under `platform-helm/charts/...` and update/pin Git `targetRevision` as needed.
3. Update env values files if required by chart breaking changes.
4. Keep sync wave ordering intact unless you intentionally change orchestration.

### Add a new platform component

1. Create values files:
   - `platform-helm/envs/dev/platform/<domain>/<component>/values.yaml`
   - `platform-helm/envs/prod/platform/<domain>/<component>/values.yaml`
2. If chart is local, vendor it first (see `local-charts.md`).
3. Add an element in dev/prod platform appsets with:
   - local chart mode: `chartPath`, `targetNamespace`, `valuesPath`, `syncWave`
   - remote chart mode: `chartRepo`, `chartName`, `targetRevision`, `targetNamespace`, `valuesPath`, `syncWave`
4. Pin `targetRevision` appropriately (chart semver for remote, git SHA/tag for local source path).
5. If the component needs extra values from another repo path (like Falco rules), model it similarly with an optional key and template condition.

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
