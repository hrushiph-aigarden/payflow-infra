variable "environment"     { type = string }
variable "account_id"     { type = string }
variable "admin_role_arns" { type = list(string); default = [] }
variable "tags"            { type = map(string); default = {} }

# README
# Module: kms-secrets
# KMS CMKs for: rds, ebs, s3, secrets
# All keys have enable_key_rotation = true (PCI-DSS Req 3.7.4)
# Multi-region enabled on rds + ebs keys for DR (us-west-2)
# Secrets Manager secrets created for db-credentials and gateway-api-keys
# Jira: SCRUM-15
