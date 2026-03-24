# Preview environment values

PR-specific **microservice** overlays are written here by CI:

```
envs/preview/microservices/preview-<PR_NUMBER>/
├── api-gateway-values.yaml
├── reader-values.yaml
└── writer-values.yaml
```

The Argo CD **preview** ApplicationSet discovers each `preview-*` directory under `envs/preview/microservices/` and deploys using:

- Chart: `charts/microservices` (shared templates)
- Values: `charts/microservices/<service>/values.yaml` + this preview overlay
