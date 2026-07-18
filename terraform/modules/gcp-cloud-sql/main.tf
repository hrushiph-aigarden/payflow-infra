# =============================================================================
# PayFlow Pro — GCP Cloud SQL PostgreSQL Module (PCI-DSS Pay-Per-Need)
# Cost-optimized db-f1-micro | Single-AZ (HA disabled) | Private IP only
# =============================================================================

resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.environment}-payflow-db-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_ip_range_names = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "postgres" {
  name             = "${var.environment}-payflow-ledger"
  database_version = "POSTGRES_16"
  region           = var.region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    # Smallest tier available (db-f1-micro / shared-core, ~$10/month)
    tier = "db-f1-micro"

    # Single-AZ (HA disabled to save 50% cost for dev/demo POC)
    availability_type = "ZONAL"

    # Minimal disk (starts at 10 GB, autogrow enabled)
    disk_size       = 10
    disk_type       = "PD_SSD"
    disk_autoresize = true

    ip_configuration {
      ipv4_enabled    = false # Disable public IP
      private_network = var.network_id
    }

    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }

    # Query Insights enabled for performance debugging
    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      client_in_record_client_address = true
    }

    # PCI-DSS Requirement 10.2: Postgres Audit Parameters
    database_flags {
      name  = "log_connections"
      value = "on"
    }
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }
  }

  deletion_protection = false # Disable deletion protection for easy cleanup in POC demo
}

resource "google_sql_database" "db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "admin" {
  name     = var.master_username
  instance = google_sql_database_instance.postgres.name
  password = var.master_password
}

output "db_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "db_private_ip" {
  value = google_sql_database_instance.postgres.private_ip_address
}
