# Pub/Sub topic and subscriptions with configurable ack deadlines,
# dead-letter topics, retry policies, and optional push delivery.

resource "google_pubsub_topic" "topic" {
  project = var.project_id
  name    = var.topic_name
  labels  = var.topic_labels

  message_retention_duration = var.message_retention_duration
  kms_key_name               = var.kms_key_name

  dynamic "message_storage_policy" {
    for_each = length(var.allowed_persistence_regions) > 0 ? [1] : []
    content {
      allowed_persistence_regions = var.allowed_persistence_regions
    }
  }
}

resource "google_pubsub_subscription" "subscriptions" {
  for_each = {
    for subscription in var.subscriptions :
    subscription.name => subscription
  }

  project = var.project_id
  name    = each.value.name
  topic   = google_pubsub_topic.topic.id
  labels  = var.subscription_labels
  filter  = each.value.filter

  ack_deadline_seconds       = each.value.ack_deadline_seconds
  message_retention_duration = each.value.message_retention_duration
  retain_acked_messages      = each.value.retain_acked_messages

  enable_message_ordering      = each.value.enable_message_ordering
  enable_exactly_once_delivery = each.value.enable_exactly_once_delivery

  dynamic "expiration_policy" {
    for_each = each.value.expiration_policy_ttl != "" ? [1] : []
    content {
      ttl = each.value.expiration_policy_ttl
    }
  }

  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? [1] : []
    content {
      minimum_backoff = each.value.retry_policy.minimum_backoff
      maximum_backoff = each.value.retry_policy.maximum_backoff
    }
  }

  dynamic "dead_letter_policy" {
    for_each = each.value.dead_letter_policy != null ? [1] : []
    content {
      dead_letter_topic     = each.value.dead_letter_policy.dead_letter_topic
      max_delivery_attempts = each.value.dead_letter_policy.max_delivery_attempts
    }
  }

  dynamic "push_config" {
    for_each = each.value.push_config != null ? [1] : []
    content {
      push_endpoint = each.value.push_config.push_endpoint
      attributes    = each.value.push_config.attributes

      dynamic "oidc_token" {
        for_each = each.value.push_config.oidc_token != null ? [1] : []
        content {
          service_account_email = each.value.push_config.oidc_token.service_account_email
          audience              = each.value.push_config.oidc_token.audience
        }
      }
    }
  }
}
