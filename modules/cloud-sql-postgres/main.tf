# Cloud SQL Postgres instance with optional private IP / VPC peering,
# automated backups, maintenance windows, and optional read replicas.

locals {
  private_network = var.ip_configuration.private_network
  allocate_private_ip = (
    var.ip_configuration.allocate_private_ip &&
    local.private_network != null
  )
}

resource "google_compute_global_address" "private_ip_alloc" {
  count = local.allocate_private_ip ? 1 : 0

  name          = "${var.name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = local.private_network
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count = local.allocate_private_ip ? 1 : 0

  network                 = local.private_network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc[0].name]
}

resource "google_sql_database_instance" "primary" {
  project          = var.project_id
  name             = var.name
  database_version = var.database_version
  region           = var.region

  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    edition           = var.edition
    availability_type = var.availability_type

    disk_size             = var.disk_size
    disk_autoresize       = var.disk_autoresize
    disk_autoresize_limit = var.disk_autoresize_limit

    backup_configuration {
      enabled                        = var.backup_configuration.enabled
      start_time                     = var.backup_configuration.start_time
      location                       = var.backup_configuration.location
      point_in_time_recovery_enabled = var.backup_configuration.point_in_time_recovery_enabled
      transaction_log_retention_days = var.backup_configuration.transaction_log_retention_days

      backup_retention_settings {
        retained_backups = var.backup_configuration.retained_backups
        retention_unit   = var.backup_configuration.retention_unit
      }
    }

    maintenance_window {
      day          = var.maintenance_window.day
      hour         = var.maintenance_window.hour
      update_track = var.maintenance_window.update_track
    }

    ip_configuration {
      ipv4_enabled    = var.ip_configuration.ipv4_enabled
      private_network = local.private_network
      ssl_mode        = var.ip_configuration.ssl_mode

      enable_private_path_for_google_cloud_services = var.ip_configuration.enable_private_path_for_google_cloud_services

      dynamic "authorized_networks" {
        for_each = toset(var.ip_configuration.authorized_networks)
        content {
          name  = authorized_networks.value
          value = authorized_networks.value
        }
      }
    }

    insights_config {
      query_insights_enabled  = var.insights_config.query_insights_enabled
      query_string_length     = var.insights_config.query_string_length
      record_application_tags = var.insights_config.record_application_tags
      record_client_address   = var.insights_config.record_client_address
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    user_labels = var.labels
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

resource "google_sql_database_instance" "replica" {
  for_each = {
    for replica in var.replicas :
    replica.name => replica
  }

  project          = var.project_id
  name             = each.value.name
  database_version = var.database_version
  region           = each.value.region

  instance_type        = "READ_REPLICA_INSTANCE"
  master_instance_name = google_sql_database_instance.primary.name
  deletion_protection  = each.value.deletion_protection

  settings {
    tier              = coalesce(each.value.tier, var.tier)
    availability_type = each.value.availability_type
    disk_size         = each.value.disk_size

    dynamic "maintenance_window" {
      for_each = each.value.maintenance_window != null ? [each.value.maintenance_window] : []
      content {
        day          = maintenance_window.value.day
        hour         = maintenance_window.value.hour
        update_track = maintenance_window.value.update_track
      }
    }

    dynamic "database_flags" {
      for_each = each.value.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    user_labels = var.labels
  }
}
