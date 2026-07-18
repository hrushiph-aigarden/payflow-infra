variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, staging, prod)"
}

variable "region" {
  type        = string
  description = "GCP region (e.g. us-east1)"
}

variable "subnet_cidr" {
  type        = string
  description = "Primary subnet IP CIDR range"
}

variable "pod_cidr" {
  type        = string
  description = "Secondary CIDR range for GKE Pods"
}

variable "service_cidr" {
  type        = string
  description = "Secondary CIDR range for GKE Services"
}
