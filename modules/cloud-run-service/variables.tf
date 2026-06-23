variable "project_id" {
  description = "GCP project ID where the Cloud Run service will be deployed."
  type        = string
}

variable "region" {
  description = "GCP region for the Cloud Run service."
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Name of the Cloud Run service. Must be unique within the project and region."
  type        = string
}

variable "image_uri" {
  description = "Container image URI for the Cloud Run service (e.g., gcr.io/project/image:tag)."
  type        = string
}

variable "cpu" {
  description = "CPU limit for the container (e.g., '1', '2', '4')."
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory limit for the container (e.g., '512Mi', '2Gi')."
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  description = "Minimum number of instances. Use 0 to scale to zero."
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances."
  type        = number
  default     = 100
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated invocations from the internet (allUsers)."
  type        = bool
  default     = false
}

variable "invoker_members" {
  description = "List of additional IAM members to grant roles/run.invoker (e.g., ['serviceAccount:...', 'group:...'])."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for m in var.invoker_members :
      can(regex("^(user|serviceAccount|group|domain):", m))
    ])
    error_message = "Each invoker member must start with a valid IAM principal type prefix (user:, serviceAccount:, group:, domain:)."
  }
}

variable "environment_variables" {
  description = "Plain environment variables to set on the container."
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Secrets from Secret Manager to inject as environment variables."
  type = list(object({
    name    = string
    secret  = string
    version = string
  }))
  default = []
}

variable "secret_volumes" {
  description = "Secret Manager secrets to mount as volumes in the container."
  type = list(object({
    name       = string
    secret     = string
    path       = string
    mount_path = string
    version    = string
  }))
  default = []
}

variable "vpc_connector" {
  description = "VPC connector ID or self_link for VPC access (optional)."
  type        = string
  default     = null
}

variable "egress" {
  description = "Egress settings when a VPC connector is configured: ALL_TRAFFIC or PRIVATE_RANGES_ONLY."
  type        = string
  default     = "PRIVATE_RANGES_ONLY"

  validation {
    condition     = contains(["ALL_TRAFFIC", "PRIVATE_RANGES_ONLY"], var.egress)
    error_message = "egress must be ALL_TRAFFIC or PRIVATE_RANGES_ONLY."
  }
}

variable "service_account" {
  description = "Service account email for the Cloud Run service (optional)."
  type        = string
  default     = null
}

variable "ingress" {
  description = "Ingress policy: INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER."
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"

  validation {
    condition     = contains(["INGRESS_TRAFFIC_ALL", "INGRESS_TRAFFIC_INTERNAL_ONLY", "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"], var.ingress)
    error_message = "ingress must be one of: INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER."
  }
}

variable "labels" {
  description = "Labels to apply to the Cloud Run service."
  type        = map(string)
  default     = {}
}
