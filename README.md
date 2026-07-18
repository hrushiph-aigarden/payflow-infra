# PayFlow Pro — Infrastructure as Code

> **PCI-DSS Level 1 Compliant Infrastructure** | Managed by Platform Engineering

[![Terraform](https://img.shields.io/badge/Terraform-1.9+-purple)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-us--east--1-orange)](https://aws.amazon.com)
[![PCI-DSS](https://img.shields.io/badge/PCI--DSS-Level%201-red)]()
[![MCP-Powered](https://img.shields.io/badge/MCP-Self--Service-blue)]()

## Overview

This repository contains all Infrastructure as Code (IaC) for the **PayFlow Pro** payment processing microservice. All infrastructure is provisioned via Terraform, reviewed through pull requests, and applied by CI/CD — no manual AWS console changes.

## Repository Structure

```
payflow-infra/
├── terraform/
│   ├── modules/                    # Reusable Terraform modules
│   │   ├── eks-nodegroup/          # EKS managed node group
│   │   ├── rds-postgres/           # RDS PostgreSQL 16
│   │   ├── kms-secrets/            # KMS CMKs + Secrets Manager
│   │   └── vpc-baseline/           # VPC, subnets, NAT gateways
│   ├── environments/
│   │   ├── dev/                    # Development workspace
│   │   ├── staging/                # Staging workspace
│   │   └── prod/                   # Production workspace
│   └── backend.tf                  # S3 + DynamoDB remote state
├── .github/workflows/
│   ├── terraform-plan.yml          # PR: terraform plan
│   └── terraform-apply.yml         # Merge: terraform apply
├── agents/
│   └── platform-agent.md           # MCP Platform Agent
└── README.md
```

## 🤖 MCP Self-Service — Platform Agent

Don't read docs. Just ask:

```
"Provision a dev environment for PayFlow using the PCI-compliant template"
```

The **Platform Agent** (`/agents/platform-agent.md`) connects to GitHub, Jira, ServiceNow, and Confluence via MCP to handle the entire workflow in under 15 minutes.

## Quick Start

```bash
git clone https://github.com/hrushiph-aigarden/payflow-infra.git
cd payflow-infra/terraform/environments/dev
terraform init
terraform workspace select dev
terraform plan
```

## Module Usage

### EKS Node Group
```hcl
module "payflow_nodegroup" {
  source          = "../../modules/eks-nodegroup"
  cluster_name    = "fintech-prod-eks"
  node_group_name = "payflow-pro"
  instance_types  = ["m6i.2xlarge"]
  min_size        = 3
  max_size        = 12
  desired_size    = 3
  kms_key_arn     = module.kms.key_arns["ebs"]
  labels = {
    "app"       = "payflow-pro"
    "pci-scope" = "true"
  }
}
```

### RDS PostgreSQL
```hcl
module "payflow_db" {
  source            = "../../modules/rds-postgres"
  identifier        = "payflow-ledger-prod"
  engine_version    = "16.3"
  instance_class    = "db.r7g.xlarge"
  allocated_storage = 500
  storage_encrypted = true
  multi_az          = true
  backup_retention  = 35
}
```

## PCI-DSS Compliance

| Requirement | Implementation |
|---|---|
| Req 1.3 | VPC private subnets, security groups, WAF v2 |
| Req 3.4.1 | Vault FPE tokenization (PAN never stored plaintext) |
| Req 6.3.3 | Automated patching via SSM + EKS managed nodes |
| Req 8.3 | MFA enforced on AWS account, RBAC via IAM roles |
| Req 10.2 | CloudTrail + VPC Flow Logs → Splunk |
| Req 12.3 | Terraform drift detection (daily) |

## Related Jira Epics
- [SCRUM-5](https://ainursery.atlassian.net/browse/SCRUM-5) — PayFlow Pro Core Service
- [SCRUM-6](https://ainursery.atlassian.net/browse/SCRUM-6) — Infrastructure as Code
- [SCRUM-7](https://ainursery.atlassian.net/browse/SCRUM-7) — Helm & Kubernetes Delivery
- [SCRUM-8](https://ainursery.atlassian.net/browse/SCRUM-8) — MCP Self-Service Platform

---
*Part of the "The End of Documentation: MCP-Based Living Platform for Developer Self-Service" POC*
