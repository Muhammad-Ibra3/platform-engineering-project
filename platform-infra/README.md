# Platform Infrastructure

## Overview

This directory contains all **Infrastructure as Code (IaC)** required to provision the platform's cloud resources.

Infrastructure is defined using **Terraform modules** and supports multiple environments including:

* sandbox (development cluster running on EC2)
* dev
* prod

The infrastructure layer provisions the foundational cloud components that the Kubernetes platform runs on.

---

## Responsibilities

This layer provisions:

* AWS networking (VPC, subnets, routing)
* Kubernetes clusters
* container registry
* IAM roles and policies
* backup storage

Infrastructure is designed to be **environment-agnostic** through reusable Terraform modules.

---

## Architecture

Infrastructure is separated into:

### Modules

Reusable building blocks for infrastructure components.

Examples:

* VPC
* EKS cluster
* EC2 sandbox cluster
* IAM policies
* container registry
* S3 backup storage

### Environments

Each environment composes modules into a deployable stack.

Environments include:

* sandbox
* dev
* prod

---

## Directory Structure

```
platform-infrastructure
├── environments
│   ├── sandbox
│   ├── dev
│   └── prod
│
├── modules
│   ├── vpc
│   ├── eks
│   ├── ec2-sandbox
│   ├── iam
│   ├── ecr
│   └── s3-backups
│
└── scripts
```

---

## Deployment Workflow

Infrastructure is deployed using the following workflow:

1. Terraform initialization
2. Terraform plan review
3. Terraform apply
4. Outputs exported to GitOps layer

Infrastructure state is stored remotely to ensure safe team collaboration.

---

## Design Goals

* reproducible infrastructure
* reusable modules
* environment isolation
* minimal manual configuration

Infrastructure provisioning is intentionally kept separate from application deployment.
