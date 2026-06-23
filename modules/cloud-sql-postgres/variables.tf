variable "project_id" {
  description = "GCP project ID where the Cloud SQL instance will be created."
  type        = string
}

variable "name" {
  description = "Name of the Cloud SQL Postgres instance. Must be unique across the project."
  type        = string
}

variable "region" {
  description = "GCP region for the primary Cloud SQL instance."
  type        = string
  default     = "us-central1"
}

variable "database_version" {
  description = "Postgres database version (e.g., POSTGRES_15)."
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "Machine type tier for the instance (e.g., db-f1-micro, db-custom-2-3840)."
  type        = string
  default     = "db-f1-micro"
}

variable "edition" {
  description = "Cloud SQL edition: ENTERPRISE or ENTERPRISE_PLUS."
  type        = string
  default     = "ENTERPRISE"

  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.edition)
    error_message = "edition must be ENTERPRISE or ENTERPRISE_PLUS."
  }
}

variable "availability_type" {
  description = "Availability type: ZONAL or REGIONAL."
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "availability_type must be ZONAL or REGIONAL."
  }
}

variable "disk_size" {
  description = "Initial disk size in GB."
  type        = number
  default     = 10
}

variable "disk_autoresize" {
  description = "Enable automatic disk resize."
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "Maximum disk size in GB when autoresize is enabled."
  type        = number
  default     = 100
}

variable "backup_configuration" {
  description = "Automated backup configuration."
  type = object({
    enabled                        = optional(bool, true)
    start_time                     = optional(string, "03:00")
    location                       = optional(string, null)
    point_in_time_recovery_enabled = optional(bool, true)
    transaction_log_retention_days = optional(number, 7)
    retained_backups               = optional(number, 7)
    retention_unit                 = optional(string, "COUNT")
  })
  default = {
    enabled                        = true
    start_time                     = "03:00"
    point_in_time_recovery_enabled = true
    transaction_log_retention_days = 7
    retained_backups               = 7
    retention_unit                 = "COUNT"
  }
}

variable "maintenance_window" {
  description = "Maintenance window configuration."
  type = object({
    day          = optional(number, 7)
    hour         = optional(number, 3)
    update_track = optional(string, "stable")
  })
  default = {
    day          = 7
    hour         = 3
    update_track = "stable"
  }
}

variable "ip_configuration" {
  description = "IP configuration for the instance, including private IP and authorized networks."
  type = object({
    ipv4_enabled                                  = optional(bool, false)
    private_network                               = optional(string, null)
    allocate_private_ip                           = optional(bool, true)
    private_network_name                          = optional(string, null)
    authorized_networks                           = optional(list(string), [])
    ssl_mode                                      = optional(string, "ALLOW_UNENCRYPTED_AND_ENCRYPTED")
    enable_private_path_for_google_cloud_services = optional(bool, true)
  })
  default = {
    ipv4_enabled                                  = false
    private_network                               = null
    allocate_private_ip                           = true
    authorized_networks                           = []
    ssl_mode                                      = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    enable_private_path_for_google_cloud_services = true
  }
}

variable "database_flags" {
  description = "List of database flags to set on the instance."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "insights_config" {
  description = "Query Insights configuration."
  type = object({
    query_insights_enabled  = optional(bool, true)
    query_string_length     = optional(number, 1024)
    record_application_tags = optional(bool, false)
    record_client_address   = optional(bool, false)
  })
  default = {
    query_insights_enabled  = true
    query_string_length     = 1024
    record_application_tags = false
    record_client_address   = false
  }
}

variable "replicas" {
  description = "List of read replica configurations."
  type = list(object({
    name                = string
    region              = string
    tier                = optional(string, null)
    availability_type   = optional(string, "ZONAL")
    disk_size           = optional(number, null)
    database_flags      = optional(list(object({ name = string, value = string })), [])
    maintenance_window  = optional(object({ day = optional(number, 7), hour = optional(number, 3), update_track = optional(string, "stable") }), null)
    deletion_protection = optional(bool, false)
  }))
  default = []

  validation {
    condition     = length(distinct([for r in var.replicas : r.name])) == length(var.replicas)
    error_message = "Replica names must be unique."
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection on the primary instance."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to the Cloud SQL instance."
  type        = map(string)
  default     = {}
}
