output "vpc_network_id" {
  description = "The ID of the shared VPC network."
  value       = module.vpc_shared.network_id
}

output "cloud_run_service_url" {
  description = "The URL of the deployed Cloud Run service."
  value       = module.cloud_run.service_url
}

output "cloud_sql_connection_name" {
  description = "The connection name of the Cloud SQL instance."
  value       = module.cloud_sql.instance_connection_name
}

output "cloud_sql_private_ip" {
  description = "The private IP address of the Cloud SQL instance."
  value       = module.cloud_sql.private_ip_address
}

output "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic."
  value       = module.pubsub.topic_name
}

output "pubsub_subscription_name" {
  description = "The name of the Pub/Sub subscription."
  value       = module.pubsub.subscription_names["${local.name}-events-worker"]
}

output "workload_service_account_email" {
  description = "The email of the workload service account."
  value       = google_service_account.workload.email
}
