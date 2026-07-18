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

variable "db_name" {
  type        = string
  default     = "payflow_ledger"
  description = "Database name"
}

variable "master_username" {
  type        = string
  default     = "payflow_admin"
  description = "Master username"
}

variable "master_password" {
  type        = string
  sensitive   = true
  description = "Master user password"
}
