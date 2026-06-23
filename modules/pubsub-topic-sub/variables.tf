variable "project_id" {
  description = "GCP project ID where the Pub/Sub resources will be created."
  type        = string
}

variable "topic_name" {
  description = "Name of the Pub/Sub topic. Must be unique within the project."
  type        = string
}

variable "topic_labels" {
  description = "Labels to apply to the Pub/Sub topic."
  type        = map(string)
  default     = {}
}

variable "message_retention_duration" {
  description = "Minimum duration to retain a message in the topic (e.g., '86600s')."
  type        = string
  default     = null
}

variable "kms_key_name" {
  description = "Optional Cloud KMS key name for topic message encryption (CMEK)."
  type        = string
  default     = null
}

variable "allowed_persistence_regions" {
  description = "List of GCP regions where messages may be persisted. Empty means all regions."
  type        = list(string)
  default     = []
}

variable "subscriptions" {
  description = "List of subscriptions to attach to the topic."
  type = list(object({
    name                         = string
    ack_deadline_seconds         = optional(number, 10)
    message_retention_duration   = optional(string, "86600s")
    retain_acked_messages        = optional(bool, false)
    expiration_policy_ttl        = optional(string, "")
    filter                       = optional(string, "")
    enable_message_ordering      = optional(bool, false)
    enable_exactly_once_delivery = optional(bool, false)
    retry_policy = optional(object({
      minimum_backoff = optional(string, "10s")
      maximum_backoff = optional(string, "600s")
    }), null)
    dead_letter_policy = optional(object({
      dead_letter_topic     = string
      max_delivery_attempts = number
    }), null)
    push_config = optional(object({
      push_endpoint = string
      attributes    = optional(map(string), {})
      oidc_token = optional(object({
        service_account_email = string
        audience              = optional(string, "")
      }), null)
    }), null)
  }))
  default = []

  validation {
    condition     = length(distinct([for s in var.subscriptions : s.name])) == length(var.subscriptions)
    error_message = "Subscription names must be unique."
  }

  validation {
    condition = alltrue([
      for s in var.subscriptions :
      s.ack_deadline_seconds >= 10 && s.ack_deadline_seconds <= 600
    ])
    error_message = "ack_deadline_seconds must be between 10 and 600."
  }
}

variable "subscription_labels" {
  description = "Labels to apply to all subscriptions."
  type        = map(string)
  default     = {}
}
