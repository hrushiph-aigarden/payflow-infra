# =============================================================================
# PayFlow Pro — KMS + Secrets Manager Module (PCI-DSS Req 3.7)
# Auto-rotation enabled | Multi-region | CloudTrail logging
# =============================================================================

resource "aws_kms_key" "rds" {
  description             = "PayFlow Pro: RDS storage encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = true
  tags = merge(var.tags, { Name = "payflow-rds-key", Purpose = "rds-encryption" })
}
resource "aws_kms_alias" "rds" {
  name          = "alias/payflow-rds-key"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_kms_key" "ebs" {
  description             = "PayFlow Pro: EKS node EBS volume encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = true
  tags = merge(var.tags, { Name = "payflow-ebs-key", Purpose = "ebs-encryption" })
}
resource "aws_kms_alias" "ebs" {
  name          = "alias/payflow-ebs-key"
  target_key_id = aws_kms_key.ebs.key_id
}

resource "aws_kms_key" "s3" {
  description             = "PayFlow Pro: S3 Terraform state + logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = merge(var.tags, { Name = "payflow-s3-key", Purpose = "s3-encryption" })
}
resource "aws_kms_alias" "s3" {
  name          = "alias/payflow-s3-key"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_kms_key" "secrets" {
  description             = "PayFlow Pro: Secrets Manager encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = merge(var.tags, { Name = "payflow-secrets-key", Purpose = "secrets-encryption" })
}
resource "aws_kms_alias" "secrets" {
  name          = "alias/payflow-secrets-key"
  target_key_id = aws_kms_key.secrets.key_id
}

# Secrets Manager
resource "aws_secretsmanager_secret" "db" {
  name                    = "payflow/${var.environment}/db-credentials"
  recovery_window_in_days = 30
  kms_key_id              = aws_kms_key.secrets.arn
  tags = merge(var.tags, { Name = "payflow-db-credentials" })
}

resource "aws_secretsmanager_secret" "gateway" {
  name                    = "payflow/${var.environment}/payment-gateway-api-keys"
  recovery_window_in_days = 30
  kms_key_id              = aws_kms_key.secrets.arn
  tags = merge(var.tags, { Name = "payflow-gateway-keys" })
}

output "key_arns" {
  value = {
    rds     = aws_kms_key.rds.arn
    ebs     = aws_kms_key.ebs.arn
    s3      = aws_kms_key.s3.arn
    secrets = aws_kms_key.secrets.arn
  }
}
output "db_secret_arn"      { value = aws_secretsmanager_secret.db.arn }
output "gateway_secret_arn" { value = aws_secretsmanager_secret.gateway.arn }
