# Production Environment — PayFlow Pro
# Workspace: terraform workspace select prod
# REQUIRES: CAB approval before apply (ServiceNow CHG required)
# Jira: SCRUM-13, SCRUM-14, SCRUM-15

terraform { required_version = ">= 1.9.0" }

locals {
  environment = "prod"
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
  cluster_name    = "fintech-prod-eks"
  node_group_name = "payflow-pro"
  instance_types  = ["m6i.2xlarge"]  # Production: compute-optimized
  min_size        = 3
  max_size        = 12
  desired_size    = 3
  kms_key_arn     = module.kms.key_arns["ebs"]
  node_role_arn   = var.node_role_arn
  private_subnet_ids = var.private_subnet_ids
  labels = { app = "payflow-pro", env = "prod", pci-scope = "true" }
  taints = [{
    key    = "dedicated"
    value  = "payflow"
    effect = "NO_SCHEDULE"
  }]
  tags = local.common_tags
}

module "rds" {
  source             = "../../modules/rds-postgres"
  identifier         = "payflow-ledger-prod"
  engine_version     = "16.3"
  instance_class     = "db.r7g.xlarge"  # Production: memory-optimized
  allocated_storage  = 500
  kms_key_arn        = module.kms.key_arns["rds"]
  multi_az           = true             # Production: Multi-AZ
  backup_retention   = 35               # PCI-DSS: 35-day retention
  deletion_protection = true            # Production: prevent accidental destroy
  db_name            = "payflow_ledger"
  master_username    = "payflow_admin"
  master_password    = var.db_password
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
