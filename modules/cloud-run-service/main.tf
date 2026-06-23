# Cloud Run (2nd gen) service with environment variables, Secret Manager
# integration, IAM invoker bindings, and optional VPC connector access.

resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  ingress = var.ingress
  labels  = var.labels

  template {
    service_account = var.service_account

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    dynamic "vpc_access" {
      for_each = var.vpc_connector != null ? [1] : []
      content {
        connector = var.vpc_connector
        egress    = var.egress
      }
    }

    containers {
      image = var.image_uri

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      # Plain environment variables
      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      # Secrets injected as environment variables
      dynamic "env" {
        for_each = var.secret_environment_variables
        content {
          name = env.value.name
          value_source {
            secret_key_ref {
              secret  = env.value.secret
              version = env.value.version
            }
          }
        }
      }

      # Secret volumes mounted into the container
      dynamic "volume_mounts" {
        for_each = var.secret_volumes
        content {
          name       = volume_mounts.value.name
          mount_path = volume_mounts.value.mount_path
        }
      }
    }

    # Secret volumes definition
    dynamic "volumes" {
      for_each = var.secret_volumes
      content {
        name = volumes.value.name
        secret {
          secret = volumes.value.secret
          items {
            path    = volumes.value.path
            version = volumes.value.version
          }
        }
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version,
    ]
  }
}

# IAM binding for invoker permissions (optional unauthenticated access)
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  for_each = var.allow_unauthenticated ? toset(["allUsers"]) : toset([])

  project  = var.project_id
  location = google_cloud_run_v2_service.service.location
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = each.value
}

# Optional additional IAM invoker bindings (authenticated principals)
resource "google_cloud_run_v2_service_iam_member" "additional_invokers" {
  for_each = toset(var.invoker_members)

  project  = var.project_id
  location = google_cloud_run_v2_service.service.location
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = each.value
}
