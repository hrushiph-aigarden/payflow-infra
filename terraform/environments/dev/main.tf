# Dev Environment — PayFlow Pro
# Workspace: terraform workspace select dev
# Jira: SCRUM-13, SCRUM-16, SCRUM-17

terraform { required_version = ">= 1.9.0" }

locals {
  environment = "dev"
  common_tags = {
    Environment = local.environment
    App         = "payflow-pro"
    Team        = "platform-engineering"
    PCIScope    = "true"
  }
}

module "kms" {
  source      = "../../modules/kms-secrets"
  environment = local.environment
  account_id  = var.account_id
  tags        = local.common_tags
}

module "eks_nodegroup" {
  source          = "../../modules/eks-nodegroup"
  cluster_name    = "fintech-dev-eks"
  node_group_name = "payflow-pro"
  instance_types  = ["m6i.xlarge"]   # Cost-optimized for dev
  min_size        = 1
  max_size        = 3
  desired_size    = 1
  kms_key_arn     = module.kms.key_arns["ebs"]
  node_role_arn   = var.node_role_arn
  private_subnet_ids = var.private_subnet_ids
  labels = { app = "payflow-pro", env = "dev", pci-scope = "true" }
  tags   = local.common_tags
}

module "rds" {
  source             = "../../modules/rds-postgres"
  identifier         = "payflow-ledger-dev"
  engine_version     = "16.3"
  instance_class     = "db.t4g.medium"  # Cost-optimized for dev
  allocated_storage  = 50
  kms_key_arn        = module.kms.key_arns["rds"]
  multi_az           = false            # Dev: single-AZ
  backup_retention   = 7
  deletion_protection = false           # Dev: allow destroy
  db_name            = "payflow_ledger"
  master_username    = "payflow_admin"
  master_password    = var.db_password  # From Secrets Manager
  db_subnet_ids      = var.db_subnet_ids
  security_group_id  = var.rds_security_group_id
  monitoring_role_arn = var.monitoring_role_arn
  tags               = local.common_tags
}

variable "account_id"           { type = string }
variable "node_role_arn"         { type = string }
variable "private_subnet_ids"    { type = list(string) }
variable "db_subnet_ids"         { type = list(string) }
variable "rds_security_group_id" { type = string }
variable "monitoring_role_arn"   { type = string }
variable "db_password"           { type = string; sensitive = true }
