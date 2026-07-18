# =============================================================================
# PayFlow Pro — RDS PostgreSQL 16 Module (PCI-DSS Compliant)
# Multi-AZ | KMS Encrypted | 35-day backups | Audit parameters
# =============================================================================

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = merge(var.tags, { Name = "${var.identifier}-subnet-group" })
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.identifier}-pg16"
  family = "postgres16"
  # PCI-DSS Req 10.2: Audit log all DB connections and DDL
  parameter { name = "log_connections";    value = "1" }
  parameter { name = "log_disconnections"; value = "1" }
  parameter { name = "log_duration";       value = "1" }
  parameter { name = "log_statement";      value = "ddl" }
  parameter { name = "log_min_duration_statement"; value = "1000" }
  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier        = var.identifier
  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn
  db_name           = var.db_name
  username          = var.master_username
  password          = var.master_password
  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]
  parameter_group_name   = aws_db_parameter_group.this.name
  backup_retention_period    = var.backup_retention
  backup_window              = "03:00-04:00"
  maintenance_window         = "sun:04:00-sun:05:00"
  monitoring_interval        = 60                   # Enhanced monitoring
  monitoring_role_arn        = var.monitoring_role_arn
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled   = true
  performance_insights_retention_period = 7
  deletion_protection   = var.deletion_protection
  skip_final_snapshot   = false
  final_snapshot_identifier = "${var.identifier}-final-snapshot"
  tags = merge(var.tags, { Name = var.identifier })
  lifecycle { prevent_destroy = true }
}

output "db_endpoint" { value = aws_db_instance.this.endpoint }
output "db_port"     { value = aws_db_instance.this.port }
output "db_arn"      { value = aws_db_instance.this.arn }
