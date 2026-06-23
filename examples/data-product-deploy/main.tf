# Example root module composing the platform modules to deploy one repeatable
# "data product" instance: VPC, Cloud SQL, Pub/Sub, Cloud Run, and IAM bindings.

locals {
  name = "${var.name_prefix}-${var.environment}"
  labels = {
    environment  = var.environment
    managed_by   = "terraform"
    data_product = var.name_prefix
  }
}

# -----------------------------------------------------------------------------
# Shared VPC
# -----------------------------------------------------------------------------

module "vpc_shared" {
  source = "../../modules/vpc-shared"

  project_id   = var.project_id
  network_name = "${local.name}-vpc"
  region       = var.region

  subnets = [
    {
      name                     = "app-subnet"
      region                   = var.region
      cidr                     = var.network_cidr
      private_ip_google_access = true
      flow_logs                = false
    }
  ]

  firewall_rules = [
    {
      name          = "allow-internal"
      description   = "Allow all internal VPC traffic"
      direction     = "INGRESS"
      source_ranges = [var.network_cidr]
      allow = [
        {
          protocol = "tcp"
          ports    = []
        }
      ]
    }
  ]

  labels = local.labels
}

# -----------------------------------------------------------------------------
# Service account for the Cloud Run workload
# -----------------------------------------------------------------------------

resource "google_service_account" "workload" {
  project      = var.project_id
  account_id   = "${local.name}-svc"
  display_name = "Service account for ${local.name} workload"
}

# -----------------------------------------------------------------------------
# Cloud SQL Postgres
# -----------------------------------------------------------------------------

module "cloud_sql" {
  source = "../../modules/cloud-sql-postgres"

  project_id = var.project_id
  name       = "${local.name}-db"
  region     = var.region

  database_version  = "POSTGRES_15"
  tier              = var.database_tier
  availability_type = "ZONAL"

  ip_configuration = {
    ipv4_enabled        = false
    private_network     = module.vpc_shared.network_self_link
    allocate_private_ip = true
    authorized_networks = []
    ssl_mode            = "ENCRYPTED_ONLY"
  }

  deletion_protection = var.environment == "production"
  labels              = local.labels
}

# -----------------------------------------------------------------------------
# Pub/Sub topic and subscription
# -----------------------------------------------------------------------------

module "pubsub" {
  source = "../../modules/pubsub-topic-sub"

  project_id = var.project_id
  topic_name = "${local.name}-events"

  topic_labels = local.labels

  subscriptions = [
    {
      name                 = "${local.name}-events-worker"
      ack_deadline_seconds = 60
      retry_policy = {
        minimum_backoff = "10s"
        maximum_backoff = "600s"
      }
    }
  ]

  subscription_labels = local.labels
}

# -----------------------------------------------------------------------------
# VPC connector for Cloud Run
# -----------------------------------------------------------------------------

resource "google_vpc_access_connector" "connector" {
  project        = var.project_id
  name           = "${local.name}-conn"
  region         = var.region
  network        = module.vpc_shared.network_id
  ip_cidr_range  = "10.8.0.0/28"
  min_throughput = 200
  max_throughput = 1000
}

# -----------------------------------------------------------------------------
# Cloud Run service
# -----------------------------------------------------------------------------

module "cloud_run" {
  source = "../../modules/cloud-run-service"

  project_id   = var.project_id
  region       = var.region
  service_name = "${local.name}-api"
  image_uri    = var.cloud_run_image

  min_instances = var.environment == "production" ? 1 : 0
  max_instances = 10

  environment_variables = {
    ENVIRONMENT         = var.environment
    DB_HOST             = module.cloud_sql.private_ip_address
    DB_NAME             = "app"
    PUBSUB_TOPIC        = module.pubsub.topic_name
    PUBSUB_SUBSCRIPTION = "${local.name}-events-worker"
  }

  vpc_connector = google_vpc_access_connector.connector.id
  egress        = "PRIVATE_RANGES_ONLY"
  ingress       = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  service_account = google_service_account.workload.email

  invoker_members = var.cloud_run_invoker_members

  labels = local.labels
}

# -----------------------------------------------------------------------------
# IAM bindings
# -----------------------------------------------------------------------------

module "iam_cloudsql_client" {
  source = "../../modules/iam-binding"

  project_id = var.project_id
  mode       = "additive"
  role       = "roles/cloudsql.client"
  members = [
    "serviceAccount:${google_service_account.workload.email}"
  ]
}

module "iam_pubsub_publisher" {
  source = "../../modules/iam-binding"

  project_id = var.project_id
  mode       = "additive"
  role       = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${google_service_account.workload.email}"
  ]
}

module "iam_pubsub_subscriber" {
  source = "../../modules/iam-binding"

  project_id    = var.project_id
  mode          = "additive"
  resource_type = "pubsub_subscription"
  resource_id   = "${local.name}-events-worker"
  role          = "roles/pubsub.subscriber"
  members = [
    "serviceAccount:${google_service_account.workload.email}"
  ]
}
