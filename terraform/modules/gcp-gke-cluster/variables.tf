variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, staging, prod)"
}

variable "region" {
  type        = string
  description = "GCP region (e.g. us-east1)"
}

variable "network_id" {
  type        = string
  description = "VPC network ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for GKE nodes"
}
