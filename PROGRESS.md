# 🗺️ Project Roadmap & Progress Tracker

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

