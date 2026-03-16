# Enterprise Platform Engineering: GitOps & Go Microservices

## 📖 Overview
This project demonstrates the end-to-end platform enablement of a modern, event-driven microservices architecture. Instead of just deploying code, this repository showcases a production-grade **Internal Developer Platform (IDP)** utilizing Infrastructure as Code (IaC), GitOps, Zero-Trust Security, and a comprehensive FinOps testing strategy.

The target application is a Go-based CQRS and gRPC architecture utilizing Kafka, PostgreSQL, MongoDB, and Redis.

## 🏗️ Architecture Design

```mermaid
graph TD
    %% Developer Flow
    Dev[Developer] -->|Commits Code| Git[GitHub Repo]
    Git -->|Triggers| CI[Tekton / GitHub Actions]
    CI -->|Build/Scan/Push| ECR[(AWS ECR)]
    CI -->|Updates Manifests| GitOpsRepo[GitOps Repository]

    %% GitOps Flow
    GitOpsRepo -->|Syncs| Argo[ArgoCD]
    Argo -->|Deploys| Cluster[Kubernetes Cluster]

    %% Cluster Infrastructure
    subgraph Kubernetes Cluster [AWS EKS / EC2 k3s]
        direction TB
        Ingress[Traefik Ingress]
        
        subgraph Platform Services
            Sec[Vault & Keycloak]
            Obs[Prometheus, Grafana, Tempo]
            DevPortal[Backstage]
        end

        subgraph Go Microservices
            API[API Gateway]
            Read[Reader Service]
            Write[Writer Service]
        end

        subgraph Stateful Backing Services
            Kafka[Kafka Event Bus]
            DBs[(Postgres / MongoDB / Redis)]
        end

        Ingress --> API
        API --> Kafka
        Kafka <--> Write
        Kafka <--> Read
        Write --> DBs
        Read --> DBs
    end