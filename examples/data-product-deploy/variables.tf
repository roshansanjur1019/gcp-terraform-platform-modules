variable "project_id" {
  description = "GCP project ID where the data product will be deployed."
  type        = string
}

variable "region" {
  description = "Primary GCP region for the data product."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, production)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be dev, staging, or production."
  }
}

variable "name_prefix" {
  description = "Prefix used for naming all resources in this data product."
  type        = string
  default     = "data-product"
}

variable "network_cidr" {
  description = "CIDR block for the application subnet."
  type        = string
  default     = "10.0.0.0/24"
}

variable "database_tier" {
  description = "Cloud SQL machine tier."
  type        = string
  default     = "db-f1-micro"
}

variable "cloud_run_image" {
  description = "Container image URI for the Cloud Run service."
  type        = string
  default     = "gcr.io/google-samples/hello-app:1.0"
}

variable "cloud_run_invoker_members" {
  description = "IAM members allowed to invoke the Cloud Run service."
  type        = list(string)
  default     = []
}
