# =============================================================================
# PayFlow Pro — GCP VPC Baseline Module (PCI-DSS Pay-Per-Need)
# Private-only subnets | Cloud NAT for egress
# =============================================================================

resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-payflow-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name                     = "${var.environment}-payflow-gke-subnet"
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true

  # IP Aliasing ranges for GKE pods and services
  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = var.pod_cidr
  }
  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = var.service_cidr
  }
}

# Cloud Router (required for NAT)
resource "google_compute_router" "router" {
  name    = "${var.environment}-payflow-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# Cloud NAT (allows private nodes to fetch updates/packages without public IPs)
resource "google_compute_router_nat" "nat" {
  name                               = "${var.environment}-payflow-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall rule: Deny all ingress, allow internal VPC communications
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.environment}-payflow-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.subnet_cidr]
}

output "network_id" {
  value = google_compute_network.vpc.id
}

output "network_name" {
  value = google_compute_network.vpc.name
}

output "subnet_id" {
  value = google_compute_subnetwork.gke_subnet.id
}

output "subnet_name" {
  value = google_compute_subnetwork.gke_subnet.name
}
