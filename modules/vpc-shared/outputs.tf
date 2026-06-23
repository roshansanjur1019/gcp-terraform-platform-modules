output "network_id" {
  description = "The id of the shared VPC network."
  value       = google_compute_network.shared_vpc.id
}

output "network_name" {
  description = "The name of the shared VPC network."
  value       = google_compute_network.shared_vpc.name
}

output "network_self_link" {
  description = "The self_link of the shared VPC network."
  value       = google_compute_network.shared_vpc.self_link
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs."
  value       = { for name, subnet in google_compute_subnetwork.subnets : name => subnet.id }
}

output "subnet_self_links" {
  description = "Map of subnet names to subnet self_links."
  value       = { for name, subnet in google_compute_subnetwork.subnets : name => subnet.self_link }
}

output "subnet_regions" {
  description = "Map of subnet names to subnet regions."
  value       = { for name, subnet in google_compute_subnetwork.subnets : name => subnet.region }
}

output "router_name" {
  description = "Name of the Cloud Router created for NAT, if enabled."
  value       = var.cloud_nat.create ? google_compute_router.router[0].name : null
}

output "nat_name" {
  description = "Name of the Cloud NAT configuration, if enabled."
  value       = var.cloud_nat.create ? google_compute_router_nat.nat[0].name : null
}

output "firewall_rule_names" {
  description = "Map of firewall rule names to their resource names."
  value       = { for name, rule in google_compute_firewall.rules : name => rule.name }
}
