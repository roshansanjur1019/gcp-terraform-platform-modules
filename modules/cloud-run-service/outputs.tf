output "service_id" {
  description = "The ID of the Cloud Run service."
  value       = google_cloud_run_v2_service.service.id
}

output "service_name" {
  description = "The name of the Cloud Run service."
  value       = google_cloud_run_v2_service.service.name
}

output "service_url" {
  description = "URL to access the Cloud Run service."
  value       = google_cloud_run_v2_service.service.uri
}

output "service_location" {
  description = "The region where the Cloud Run service is deployed."
  value       = google_cloud_run_v2_service.service.location
}

output "service_status" {
  description = "The status conditions of the Cloud Run service."
  value       = google_cloud_run_v2_service.service.conditions
}

output "latest_revision_name" {
  description = "Name of the latest created revision."
  value       = google_cloud_run_v2_service.service.latest_created_revision
}
