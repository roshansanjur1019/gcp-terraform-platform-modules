variable "project_id" {
  description = "GCP project ID where the IAM binding will be applied."
  type        = string
}

variable "mode" {
  description = "Binding mode: additive (google_*_iam_member) or authoritative (google_*_iam_binding)."
  type        = string
  default     = "additive"

  validation {
    condition     = contains(["additive", "authoritative"], var.mode)
    error_message = "mode must be 'additive' or 'authoritative'."
  }
}

variable "resource_type" {
  description = "Type of resource to bind the role to: project, pubsub_topic, pubsub_subscription, cloud_run_service, or storage_bucket."
  type        = string
  default     = "project"

  validation {
    condition     = contains(["project", "pubsub_topic", "pubsub_subscription", "cloud_run_service", "storage_bucket"], var.resource_type)
    error_message = "resource_type must be one of: project, pubsub_topic, pubsub_subscription, cloud_run_service, storage_bucket."
  }
}

variable "resource_id" {
  description = "Resource identifier: topic name, subscription name, service name, or bucket name. Not used when resource_type is project."
  type        = string
  default     = null
}

variable "resource_location" {
  description = "GCP region for the resource. Required when resource_type is cloud_run_service."
  type        = string
  default     = null
}

variable "role" {
  description = "IAM role to bind (e.g., roles/run.invoker)."
  type        = string
}

variable "members" {
  description = "List of IAM members to bind to the role (e.g., ['serviceAccount:...', 'group:...'])."
  type        = list(string)

  validation {
    condition = alltrue([
      for m in var.members :
      can(regex("^(user|serviceAccount|group|domain|allUsers|allAuthenticatedUsers):", m))
    ])
    error_message = "Each member must start with a valid IAM principal type prefix (user:, serviceAccount:, group:, domain:, allUsers:, allAuthenticatedUsers:)."
  }
}

variable "condition" {
  description = "Optional IAM condition for the binding."
  type = object({
    title       = string
    description = optional(string, "")
    expression  = string
  })
  default = null
}
