# =============================================================================
# PayFlow Pro — GCP GKE Autopilot Cluster Module (PCI-DSS Pay-Per-Need)
# Pay-per-pod resource usage | Shields enabled | Workload Identity configured
# =============================================================================

resource "google_container_cluster" "autopilot" {
  name     = "${var.environment}-payflow-gke"
  location = var.region

  # Enable Autopilot mode (pay-per-need pod billing)
  enable_autopilot = true

  network    = var.network_id
  subnetwork = var.subnet_id

  # Private cluster settings for security (local access via proxy/port-forward)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # Allow access to the master API public IP for localhost dev
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  # Shielded GKE Nodes (PCI Requirement)
  enable_shielded_nodes = true

  release_channel {
    channel = "REGULAR"
  }

  # Allow public access to the GKE endpoint (secured via IAM and Authorized Networks)
  master_authorized_networks_config {
    # If empty, GKE endpoint is restricted or only accessible publicly via authenticated CLI
  }

  lifecycle {
    ignore_changes = [
      ip_allocation_policy,
    ]
  }
}

output "cluster_name" {
  value = google_container_cluster.autopilot.name
}

output "cluster_endpoint" {
  value = google_container_cluster.autopilot.endpoint
}

output "ca_certificate" {
  value = google_container_cluster.autopilot.master_auth[0].cluster_ca_certificate
}
