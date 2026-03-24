# Architectural Decision Log

This file tracks currently accepted architecture decisions.

## 1) Platform in a box for FinOps efficiency

- **Context:** Running full-size managed infrastructure continuously for development created high spend and low utilization.
- **Decision:** Use an ephemeral single-node sandbox (`k3d` on spot compute) while keeping the same GitOps model.
- **Impact:** Large cost reduction with fast rebuild capability from Git state.

## 2) eBPF networking and observability through Cilium

- **Context:** gRPC and event-driven traffic are difficult to observe with basic proxy-centric tooling.
- **Decision:** Use Cilium as CNI and rely on eBPF-native telemetry.
- **Impact:** Better network visibility without introducing heavier observability components that exceed sandbox budgets.

## 3) Native mTLS and identity without SPIFFE/SPIRE

- **Context:** The platform required workload-level trust while remaining lightweight.
- **Decision:** Use Cilium-native policy and identity controls rather than adding SPIFFE/SPIRE.
- **Impact:** Lower operational complexity and memory usage while preserving zero-trust posture.

## 4) Strict GitOps deployment portability

- **Context:** Environment migration often introduces drift and manual steps.
- **Decision:** Treat Git as the only desired-state source and deploy via Argo CD/ApplicationSets.
- **Impact:** Reproducible rollouts from dev to prod with minimal environment-specific logic.

## 5) Split Helm chart logic from environment values

- **Context:** Duplicating Helm templates per environment caused maintenance overhead and path drift.
- **Decision:** Keep reusable chart source in `platform-helm/charts/microservices` and all environment differences under `platform-helm/envs/<env>/...`.
- **Impact:** Cleaner ownership boundaries, easier path reasoning, and faster onboarding.

## 6) Directory-driven preview environments

- **Context:** Preview environments need to be ephemeral and PR-scoped without bespoke manifests.
- **Decision:** Generate PR overlays under `platform-helm/envs/preview/microservices/preview-<PR>/` and let preview ApplicationSet discover directories.
- **Impact:** Consistent preview lifecycle (create/update/destroy) via CI + Argo reconciliation.

## 7) Trivy kept in CI, not deployed in-cluster

- **Context:** Runtime footprint had to stay lean for the current cluster profile.
- **Decision:** Remove Trivy Operator from platform appsets; continue image scanning in CI workflows.
- **Impact:** Reduced cluster overhead while preserving security scanning in the pipeline.