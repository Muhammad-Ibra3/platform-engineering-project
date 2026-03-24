# Add or Update a Local Vendored Chart

Use this flow when you want chart sources stored in this repository under `platform-helm/charts/`.

## Why local charts

- Better reproducibility and reviewability.
- No deploy-time dependency on external chart repos.
- Full chart changes are visible in PR diffs.

## 1) Pull chart locally (vendor)

Example commands:

```bash
helm repo add <repo_name> <repo_url>
helm repo update
helm repo pull <repo_name>/<chart_name> --untar --untardir platform-helm/charts/external
```

This produces:

- `platform-helm/charts/external/<chart_name>/`

For in-house charts, place sources under:

- `platform-helm/charts/<chart_name>/`

## 2) Verify chart metadata

Open `Chart.yaml` in the vendored chart and confirm:

- `name`
- `version`
- `appVersion` (if present)

Keep these values as the authoritative chart version metadata for the vendored source.

## 3) Wire chart path in Argo ApplicationSet

For local chart sources, use `source.path` (not `source.chart`):

```yaml
source:
  repoURL: 'https://github.com/<org>/<repo>.git'
  targetRevision: '<PINNED_GIT_SHA_OR_TAG>'
  path: 'platform-helm/charts/external/<chart_name>'
```

## 4) Pinning strategy in Argo CD

### Remote charts

Use explicit chart version pinning:

```yaml
source:
  repoURL: https://charts.example.com
  chart: my-chart
  targetRevision: 1.2.3
```

### Local vendored charts

Pin by Git revision (commit SHA or release tag), because chart source is in-repo:

```yaml
source:
  repoURL: 'https://github.com/<org>/<repo>.git'
  targetRevision: '<COMMIT_SHA_OR_TAG>'
  path: 'platform-helm/charts/external/<chart_name>'
```

Do not use moving references like `main` for production if you want strict pinning.

## 5) Add environment values

Create or update values files, for example:

- `platform-helm/envs/dev/platform/<domain>/<component>/values.yaml`
- `platform-helm/envs/prod/platform/<domain>/<component>/values.yaml`

or for dependencies:

- `platform-helm/envs/<env>/applications/app-dependencies/.../values.yaml`

## 6) Update corresponding appset entries

Update appsets that deploy the chart:

- `platform-gitops/env-appsets/dev/platform-apps.yaml`
- `platform-gitops/env-appsets/prod/platform-apps.yaml`
- `platform-gitops/env-appsets/dev/dependency-apps.yaml`
- `platform-gitops/env-appsets/prod/dependency-apps.yaml`

Ensure `chartPath` and values path are correct.

## 7) Validate

- Argo renders with no missing file errors.
- Target namespaces and sync waves are still valid.
- Chart path points to the expected vendored chart directory.
