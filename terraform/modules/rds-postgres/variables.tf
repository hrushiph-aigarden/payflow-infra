variable "identifier"         { type = string }
variable "engine_version"     { type = string; default = "16.3" }
variable "instance_class"     { type = string }
variable "allocated_storage"  { type = number }
variable "kms_key_arn"        { type = string }
variable "db_name"            { type = string }
variable "master_username"    { type = string }
variable "master_password"    { type = string; sensitive = true }
variable "multi_az"           { type = bool; default = true }
variable "backup_retention"   { type = number; default = 35 }
variable "deletion_protection" { type = bool; default = true }
variable "db_subnet_ids"      { type = list(string) }
variable "security_group_id" { type = string }
variable "monitoring_role_arn" { type = string }
variable "tags"               { type = map(string); default = {} }

# README
# Module: rds-postgres
# PostgreSQL 16 with PCI-DSS controls:
# - Multi-AZ, KMS encryption, 35-day backups, audit logging
# - Enhanced monitoring (60s), Performance Insights
# - lifecycle.prevent_destroy = true (safety guard)
# Jira: SCRUM-14
