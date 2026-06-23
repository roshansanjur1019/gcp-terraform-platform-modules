output "instance_name" {
  description = "The name of the primary Cloud SQL instance."
  value       = google_sql_database_instance.primary.name
}

output "instance_connection_name" {
  description = "The connection name of the primary Cloud SQL instance."
  value       = google_sql_database_instance.primary.connection_name
}

output "instance_self_link" {
  description = "The self_link of the primary Cloud SQL instance."
  value       = google_sql_database_instance.primary.self_link
}

output "private_ip_address" {
  description = "The private IP address of the primary instance, if private IP is enabled."
  value       = local.allocate_private_ip ? google_sql_database_instance.primary.private_ip_address : null
}

output "public_ip_address" {
  description = "The public IP address of the primary instance, if public IP is enabled."
  value       = var.ip_configuration.ipv4_enabled ? google_sql_database_instance.primary.public_ip_address : null
}

output "replica_names" {
  description = "Map of replica names to replica instance names."
  value       = { for name, replica in google_sql_database_instance.replica : name => replica.name }
}

output "replica_connection_names" {
  description = "Map of replica names to replica connection names."
  value       = { for name, replica in google_sql_database_instance.replica : name => replica.connection_name }
}
