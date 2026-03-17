
## 🏗️ Architectural Decision Log

**1. The "Platform in a Box" FinOps Strategy**

- **Context:** Running a highly available AWS EKS cluster with heavy CNCF tools (Kafka, Vault, Backstage) 24/7 generates significant cloud waste during development.
- **Decision:** Engineered a single-node testing sandbox using `k3d` on an ephemeral AWS `m7i-flex.2xlarge` Spot Instance (32 GiB RAM).
- **Impact:** Achieved 100% GitOps pipeline parity while reducing compute costs by ~95%. The cluster can be destroyed and recreated from Git state in under 5 minutes.

**2. eBPF Observability (Cilium over Pixie)**

- **Context:** The CQRS architecture relies on gRPC and Kafka events, which are difficult to monitor using standard proxies.
- **Decision:** Replaced the default k3s Flannel CNI with **Cilium** to leverage eBPF kernel-level routing. 
- **Impact:** Enabled deep gRPC tracing via **Hubble**. Opted out of Pixie to preserve the RAM budget on the single-node Sandbox, preventing Out-Of-Memory (OOM) crashes.

**3. Workload Identity & mTLS (Cilium vs. SPIFFE/SPIRE)**

- **Context:** Need to secure workload-to-workload communication (e.g., Reader Service to PostgreSQL) with identity-based mutual TLS (mTLS) and Zero-Trust principles.
- **Decision:** Relied entirely on Cilium's native eBPF-based mTLS and Network Policies. Explicitly excluded SPIFFE/SPIRE from the architecture.
- **Impact:** Prevented architectural redundancy ("a hat on a hat"). Avoided the massive memory overhead of running a SPIRE Server and node agents on the single-node sandbox while still achieving rigorous, cryptographically verifiable workload security.

**4. GitOps Portability**

- **Context:** Moving from a local testing cluster to a production cloud cluster is traditionally fraught with configuration drift.
- **Decision:** Enforced a strict "GitOps Only" deployment model using ArgoCD.
- **Impact:** Migrating from Phase 1 (k3d) to Phase 2 (EKS) requires zero application rewrites, proving the absolute reliability of declarative infrastructure.

---