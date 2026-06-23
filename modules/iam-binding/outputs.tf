output "mode" {
  description = "The binding mode used (additive or authoritative)."
  value       = var.mode
}

output "resource_type" {
  description = "The resource type the role was bound to."
  value       = var.resource_type
}

output "resource_id" {
  description = "The resource identifier the role was bound to."
  value       = var.resource_id
}

output "role" {
  description = "The IAM role that was bound."
  value       = var.role
}

output "members" {
  description = "The IAM members that were bound."
  value       = var.members
}
