output "topic_id" {
  description = "The ID of the Pub/Sub topic."
  value       = google_pubsub_topic.topic.id
}

output "topic_name" {
  description = "The name of the Pub/Sub topic."
  value       = google_pubsub_topic.topic.name
}

output "subscription_ids" {
  description = "Map of subscription names to subscription IDs."
  value       = { for name, sub in google_pubsub_subscription.subscriptions : name => sub.id }
}

output "subscription_names" {
  description = "Map of subscription names to their resource names."
  value       = { for name, sub in google_pubsub_subscription.subscriptions : name => sub.name }
}

output "subscription_paths" {
  description = "Map of subscription names to their fully-qualified paths."
  value       = { for name, sub in google_pubsub_subscription.subscriptions : name => sub.path }
}
