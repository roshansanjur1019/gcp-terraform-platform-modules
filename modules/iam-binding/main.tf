# Reusable IAM binding module supporting additive and authoritative modes
# across project-level and common resource-level targets.

locals {
  is_additive      = var.mode == "additive"
  is_authoritative = var.mode == "authoritative"
  members_set      = toset(var.members)
}

# -----------------------------------------------------------------------------
# Project-level IAM
# -----------------------------------------------------------------------------

resource "google_project_iam_member" "additive" {
  for_each = local.is_additive && var.resource_type == "project" ? local.members_set : toset([])

  project = var.project_id
  role    = var.role
  member  = each.value

  dynamic "condition" {
    for_each = var.condition != null ? [var.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_project_iam_binding" "authoritative" {
  count = local.is_authoritative && var.resource_type == "project" ? 1 : 0

  project = var.project_id
  role    = var.role
  members = var.members

  dynamic "condition" {
    for_each = var.condition != null ? [var.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# -----------------------------------------------------------------------------
# Pub/Sub topic IAM
# -----------------------------------------------------------------------------

resource "google_pubsub_topic_iam_member" "additive" {
  for_each = local.is_additive && var.resource_type == "pubsub_topic" ? local.members_set : toset([])

  project = var.project_id
  topic   = var.resource_id
  role    = var.role
  member  = each.value

  dynamic "condition" {
    for_each = var.condition != null ? [var.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_pubsub_topic_iam_binding" "authoritative" {
  count = local.is_authoritative && var.resource_type == "pubsub_topic" ? 1 : 0

  project = var.project_id
  topic   = var.resource_id
  role    = var.role
  members = var.members

  dynamic "condition" {
    for_each = var.condition != null ? [var.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# -----------------------------------------------------------------------------
# Pub/Sub subscription IAM
# -----------------------------------------------------------------------------

resource "google_pubsub_subscription_iam_member" "additive" {
  for_each = local.is_additive && var.resource_type == "pubsub_subscription" ? local.members_set : toset([])

  project      = var.project_id
  subscription = var.resource_id
  role         = var.role
  member       = each.value

  dynamic "condition" {
    for_each = var.condition != null ? [var.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_pubsub_subscription_iam_binding" "authoritative" {
  count = local.is_authoritative && var.resource_type == "pubsub_subscription" ? 1 : 0

  project      = var.project_id
  subscription = var.resource_id
  role         = var.role
  members      = var.members

  dynamic "condition" {
    for_each = var.condition != null ? [var.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# -----------------------------------------------------------------------------
# Cloud Run service IAM
# -----------------------------------------------------------------------------

resource "google_cloud_run_v2_service_iam_member" "additive" {
  for_each = local.is_additive && var.resource_type == "cloud_run_service" ? local.members_set : toset([])

  project  = var.project_id
  location = var.resource_location
  name     = var.resource_id
  role     = var.role
  member   = each.value

  dynamic "condition" {
    for_each = var.condition != null ? [var.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_cloud_run_v2_service_iam_binding" "authoritative" {
  count = local.is_authoritative && var.resource_type == "cloud_run_service" ? 1 : 0

  project  = var.project_id
  location = var.resource_location
  name     = var.resource_id
  role     = var.role
  members  = var.members

  dynamic "condition" {
    for_each = var.condition != null ? [var.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# -----------------------------------------------------------------------------
# Cloud Storage bucket IAM
# -----------------------------------------------------------------------------

resource "google_storage_bucket_iam_member" "additive" {
  for_each = local.is_additive && var.resource_type == "storage_bucket" ? local.members_set : toset([])

  bucket = var.resource_id
  role   = var.role
  member = each.value

  dynamic "condition" {
    for_each = var.condition != null ? [var.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

resource "google_storage_bucket_iam_binding" "authoritative" {
  count = local.is_authoritative && var.resource_type == "storage_bucket" ? 1 : 0

  bucket  = var.resource_id
  role    = var.role
  members = var.members

  dynamic "condition" {
    for_each = var.condition != null ? [var.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
