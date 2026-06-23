output "environment_id" {
  description = "The ID of the Cloud Composer environment."
  value       = google_composer_environment.environment.id
}

output "environment_name" {
  description = "The name of the Cloud Composer environment."
  value       = google_composer_environment.environment.name
}

output "environment_region" {
  description = "The region of the Cloud Composer environment."
  value       = google_composer_environment.environment.region
}

output "airflow_uri" {
  description = "The URI of the Airflow web server."
  value       = google_composer_environment.environment.config[0].airflow_uri
}

output "dag_gcs_prefix" {
  description = "The Cloud Storage prefix where DAGs are stored."
  value       = google_composer_environment.environment.config[0].dag_gcs_prefix
}

output "gke_cluster" {
  description = "The GKE cluster self_link backing the Composer environment."
  value       = google_composer_environment.environment.config[0].gke_cluster
}

output "composer_service_account" {
  description = "The default service account used by Composer."
  value       = google_composer_environment.environment.config[0].node_config[0].service_account
}
