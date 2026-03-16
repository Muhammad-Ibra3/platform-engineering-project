# 🗺️ Project Roadmap & Progress Tracker

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

## Phase 1: "Platform in a Box" (FinOps Sandbox)

**Milestone 1: The Ephemeral Core**

- Write Terraform for VPC, Security Groups, and EC2 Spot Instance.
- Configure k3d auto-installation via EC2 `user_data` (Jumpbox configuration).
- Convert Go-CQRS `docker-compose.yml` into a Helm Umbrella Chart.
- Define Bitnami/Confluent charts for Kafka, Postgres, MongoDB, Redis, and Cilium as dependencies.
- Install ArgoCD on k3d and configure the "App of Apps" pattern to sync the Helm repository.

**Milestone 2: Security & The Developer Portal**

- Deploy HashiCorp Vault via ArgoCD and configure auto-unseal.
- Deploy Keycloak and integrate it with the API Gateway.
- Deploy Backstage Developer Portal and connect it to GitHub and ArgoCD.

**Milestone 3: Traffic, CI/CD, & Observability**

- Configure Traefik Ingress to handle HTTP and gRPC traffic.
- Build GitHub Actions workflows to lint, build, scan (Trivy), and push Go images to AWS ECR.
- Configure pipeline to auto-update image tags in the GitOps repository.
- Deploy `kube-prometheus-stack`, Tempo (gRPC tracing), and Loki (logs).

---

## Phase 2: Production Enterprise Scale

**Milestone 4: The EKS Migration**

- Write Terraform to provision an AWS EKS Cluster and Node Groups.
- Install ArgoCD on the new EKS cluster.
- Apply the exact same root ArgoCD application used in Phase 1 to migrate the entire IDP state to EKS.
- Configure AWS Route53 and ALB Ingress Controller for production DNS routing.

