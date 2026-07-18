# Dev Environment (GCP Autopilot + db-f1-micro Cloud SQL) — PayFlow Pro
# Workspace: terraform workspace select gcp-dev || terraform workspace new gcp-dev
# Accessed via localhost: port-forwarding to bypass ingress load balancers

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.30"
    }
  }
  required_version = ">= 1.9.0"
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

locals {
  environment = "dev"
}

module "vpc" {
  source      = "../../modules/gcp-vpc-baseline"
  environment = local.environment
  region      = var.gcp_region
  subnet_cidr = "10.10.0.0/20"
  pod_cidr    = "10.100.0.0/16"
  service_cidr = "10.101.0.0/20"
}

module "gke" {
  source      = "../../modules/gcp-gke-cluster"
  environment = local.environment
  region      = var.gcp_region
  network_id  = module.vpc.network_id
  subnet_id   = module.vpc.subnet_id
}

module "database" {
  source          = "../../modules/gcp-cloud-sql"
  environment     = local.environment
  region          = var.gcp_region
  network_id      = module.vpc.network_id
  db_name         = "payflow_ledger"
  master_username = "payflow_admin"
  master_password = var.db_password
}

variable "gcp_project" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "Google Cloud region"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database master password"
}

output "gke_cluster_name" {
  value = module.gke.cluster_name
}

output "database_ip" {
  value = module.database.db_private_ip
}
