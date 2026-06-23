# Cloud Composer 2 environment with configurable node count, environment size,
# workload shapes, networking, and IAM-ready configuration.

resource "google_composer_environment" "environment" {
  project = var.project_id
  name    = var.name
  region  = var.region
  labels  = var.labels

  config {
    node_count       = var.node_count
    environment_size = var.environment_size

    software_config {
      image_version = var.image_version
      airflow_config_overrides = {
        core-dags_are_paused_at_creation = "True"
      }

      env_variables = var.env_variables
      pypi_packages = var.pypi_packages
    }

    workloads_config {
      scheduler {
        cpu        = var.scheduler.cpu
        memory_gb  = var.scheduler.memory_gb
        storage_gb = var.scheduler.storage_gb
        count      = var.scheduler.count
      }

      dynamic "triggerer" {
        for_each = var.triggerer.enabled ? [var.triggerer] : []
        content {
          cpu       = triggerer.value.cpu
          memory_gb = triggerer.value.memory_gb
          count     = triggerer.value.count
        }
      }

      web_server {
        cpu        = var.web_server.cpu
        memory_gb  = var.web_server.memory_gb
        storage_gb = var.web_server.storage_gb
      }

      worker {
        cpu        = var.worker.cpu
        memory_gb  = var.worker.memory_gb
        storage_gb = var.worker.storage_gb
        min_count  = var.worker.min_count
        max_count  = var.worker.max_count
      }
    }

    node_config {
      network    = var.network
      subnetwork = var.subnetwork

      service_account = var.service_account

      ip_allocation_policy {
        cluster_secondary_range_name  = var.ip_allocation_policy.cluster_secondary_range_name
        services_secondary_range_name = var.ip_allocation_policy.services_secondary_range_name
        cluster_ipv4_cidr_block       = var.ip_allocation_policy.cluster_ipv4_cidr_block
        services_ipv4_cidr_block      = var.ip_allocation_policy.services_ipv4_cidr_block
      }

      enable_ip_masq_agent = var.enable_ip_masq_agent
    }

    dynamic "private_environment_config" {
      for_each = var.enable_private_environment ? [1] : []
      content {
        enable_private_endpoint = true
      }
    }

    maintenance_window {
      start_time = var.maintenance_window.start_time
      end_time   = var.maintenance_window.end_time
      recurrence = var.maintenance_window.recurrence
    }


  }
}
