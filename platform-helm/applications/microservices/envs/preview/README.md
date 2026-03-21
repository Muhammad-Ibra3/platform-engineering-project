# Preview environment overrides

Directories under here are created by the CI workflow (update-gitops) when a pull request is opened or updated.

- **Naming:** `preview-{PR_NUMBER}` (e.g. `preview-123`)
- **Content:** Values files are copied from `envs/dev/` and `image.tag` is set to the built image for that PR. One file per service: `api-gateway-values.yaml`, `reader-values.yaml`, `writer-values.yaml`.
- **Argo CD:** The ApplicationSet in `platform-gitops/env-appsets/preview-appset.yaml` discovers these directories and deploys each service into a namespace named `preview-{PR_NUMBER}`.
- **Cleanup:** When the PR is closed, the preview-destroy workflow removes the directory so Argo prunes the preview env.
