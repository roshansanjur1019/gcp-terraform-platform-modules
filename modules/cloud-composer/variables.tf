variable "project_id" {
  description = "GCP project ID where the Cloud Composer environment will be created."
  type        = string
}

variable "name" {
  description = "Name of the Cloud Composer 2 environment."
  type        = string
}

variable "region" {
  description = "GCP region for the Cloud Composer environment."
  type        = string
  default     = "us-central1"
}

variable "environment_size" {
  description = "Environment size: ENVIRONMENT_SIZE_SMALL, ENVIRONMENT_SIZE_MEDIUM, or ENVIRONMENT_SIZE_LARGE."
  type        = string
  default     = "ENVIRONMENT_SIZE_MEDIUM"

  validation {
    condition     = contains(["ENVIRONMENT_SIZE_SMALL", "ENVIRONMENT_SIZE_MEDIUM", "ENVIRONMENT_SIZE_LARGE"], var.environment_size)
    error_message = "environment_size must be ENVIRONMENT_SIZE_SMALL, ENVIRONMENT_SIZE_MEDIUM, or ENVIRONMENT_SIZE_LARGE."
  }
}

variable "node_count" {
  description = "Number of worker nodes in the Composer GKE cluster."
  type        = number
  default     = 3
}

variable "image_version" {
  description = "Composer image version (e.g., composer-2.9.3-airflow-2.7.3)."
  type        = string
  default     = "composer-2.9.3-airflow-2.7.3"
}

variable "airflow_version" {
  description = "Airflow version. Must be compatible with the Composer image version."
  type        = string
  default     = "2.7.3"
}

variable "env_variables" {
  description = "Environment variables to set in the Airflow environment."
  type        = map(string)
  default     = {}
}

variable "pypi_packages" {
  description = "PyPI packages to install in the Airflow environment."
  type        = map(string)
  default     = {}
}

variable "scheduler" {
  description = "Airflow scheduler workload configuration."
  type = object({
    cpu        = optional(number, 2)
    memory_gb  = optional(number, 7.5)
    storage_gb = optional(number, 5)
    count      = optional(number, 1)
  })
  default = {
    cpu        = 2
    memory_gb  = 7.5
    storage_gb = 5
    count      = 1
  }
}

variable "triggerer" {
  description = "Airflow triggerer workload configuration."
  type = object({
    enabled   = optional(bool, false)
    cpu       = optional(number, 2)
    memory_gb = optional(number, 7.5)
    count     = optional(number, 1)
  })
  default = {
    enabled   = false
    cpu       = 2
    memory_gb = 7.5
    count     = 1
  }
}

variable "web_server" {
  description = "Airflow web server workload configuration."
  type = object({
    cpu        = optional(number, 2)
    memory_gb  = optional(number, 7.5)
    storage_gb = optional(number, 5)
  })
  default = {
    cpu        = 2
    memory_gb  = 7.5
    storage_gb = 5
  }
}

variable "worker" {
  description = "Airflow worker workload configuration."
  type = object({
    cpu        = optional(number, 2)
    memory_gb  = optional(number, 7.5)
    storage_gb = optional(number, 5)
    min_count  = optional(number, 2)
    max_count  = optional(number, 6)
  })
  default = {
    cpu        = 2
    memory_gb  = 7.5
    storage_gb = 5
    min_count  = 2
    max_count  = 6
  }
}

variable "network" {
  description = "VPC network self_link or name for the Composer GKE cluster."
  type        = string
  default     = null
}

variable "subnetwork" {
  description = "Subnetwork self_link or name for the Composer GKE cluster."
  type        = string
  default     = null
}

variable "service_account" {
  description = "Service account email for the Composer GKE nodes."
  type        = string
  default     = null
}

variable "ip_allocation_policy" {
  description = "IP allocation policy for the Composer GKE cluster."
  type = object({
    cluster_secondary_range_name  = optional(string, null)
    services_secondary_range_name = optional(string, null)
    cluster_ipv4_cidr_block       = optional(string, null)
    services_ipv4_cidr_block      = optional(string, null)
  })
  default = {
    cluster_secondary_range_name  = null
    services_secondary_range_name = null
    cluster_ipv4_cidr_block       = null
    services_ipv4_cidr_block      = null
  }
}

variable "enable_private_environment" {
  description = "Enable private IP for the Composer environment."
  type        = bool
  default     = false
}

variable "enable_ip_masq_agent" {
  description = "Enable IP masquerade agent on the Composer GKE cluster."
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "Maintenance window for the Composer environment."
  type = object({
    start_time = optional(string, "2024-01-01T03:00:00Z")
    end_time   = optional(string, "2024-01-01T06:00:00Z")
    recurrence = optional(string, "FREQ=WEEKLY;BYDAY=SU")
  })
  default = {
    start_time = "2024-01-01T03:00:00Z"
    end_time   = "2024-01-01T06:00:00Z"
    recurrence = "FREQ=WEEKLY;BYDAY=SU"
  }
}

variable "labels" {
  description = "Labels to apply to the Cloud Composer environment."
  type        = map(string)
  default     = {}
}
