# Shared VPC network, subnets, Cloud NAT, and firewall rules.
# Designed to be consumed by downstream workload modules (Cloud Run, Cloud SQL,
# Cloud Composer, etc.) as part of a repeatable Golden Path data-product stack.

resource "google_compute_network" "shared_vpc" {
  name                    = var.network_name
  description             = var.description
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
}

resource "google_compute_subnetwork" "subnets" {
  for_each = {
    for subnet in var.subnets :
    subnet.name => subnet
  }

  name                     = each.value.name
  ip_cidr_range            = each.value.cidr
  region                   = each.value.region
  network                  = google_compute_network.shared_vpc.id
  private_ip_google_access = each.value.private_ip_google_access

  dynamic "log_config" {
    for_each = each.value.flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_router" "router" {
  count = var.cloud_nat.create ? 1 : 0

  name    = "${var.network_name}-router"
  network = google_compute_network.shared_vpc.id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  count = var.cloud_nat.create ? 1 : 0

  name   = "${var.network_name}-nat"
  router = google_compute_router.router[0].name
  region = google_compute_router.router[0].region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  min_ports_per_vm = var.cloud_nat.min_ports_per_vm
  max_ports_per_vm = var.cloud_nat.max_ports_per_vm

  log_config {
    enable = var.cloud_nat.log_type != ""
    filter = var.cloud_nat.log_type != "" ? var.cloud_nat.log_type : "ALL"
  }
}

resource "google_compute_firewall" "rules" {
  for_each = {
    for rule in var.firewall_rules :
    rule.name => rule
  }

  name        = each.value.name
  description = each.value.description
  network     = google_compute_network.shared_vpc.id
  direction   = each.value.direction
  priority    = each.value.priority

  source_ranges      = each.value.source_ranges
  destination_ranges = each.value.destination_ranges
  source_tags        = each.value.source_tags
  target_tags        = each.value.target_tags

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
