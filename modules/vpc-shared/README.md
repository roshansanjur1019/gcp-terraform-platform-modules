# vpc-shared

A reusable, opinionated shared VPC module for GCP. It creates a custom VPC network,
one or more regional subnets, an optional Cloud NAT gateway for private outbound
internet access, and a set of firewall rules.

This module is designed to be consumed by other modules in this library — for
example, providing the network and subnets that Cloud SQL, Cloud Run, and
Cloud Composer share in a repeatable "data product" deployment.

## What it does

- Creates a custom VPC network with `auto_create_subnetworks = false`.
- Creates regional subnets with `private_ip_google_access` enabled by default.
- Optionally creates a Cloud Router + Cloud NAT for outbound internet access
  from private instances.
- Creates firewall rules using `for_each` keyed by rule name for stable state.

## Usage

```hcl
module "vpc_shared" {
  source = "github.com/your-org/gcp-terraform-platform-modules//modules/vpc-shared?ref=v1.0.0"

  project_id   = var.gcp_project_id
  network_name = "prod-shared-vpc"
  region       = "us-central1"

  subnets = [
    {
      name                     = "app-subnet"
      region                   = "us-central1"
      cidr                     = "10.0.0.0/24"
      private_ip_google_access = true
      flow_logs                = false
    },
    {
      name                     = "data-subnet"
      region                   = "us-central1"
      cidr                     = "10.0.1.0/24"
      private_ip_google_access = true
      flow_logs                = true
    }
  ]

  cloud_nat = {
    create           = true
    min_ports_per_vm = 64
    max_ports_per_vm = 65536
    log_type         = "ALL"
  }

  firewall_rules = [
    {
      name          = "allow-ssh-from-iap"
      description   = "Allow SSH from Identity-Aware Proxy"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["35.235.240.0/20"]
      target_tags   = ["ssh-access"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    },
    {
      name          = "allow-internal"
      description   = "Allow all internal traffic within the VPC"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["10.0.0.0/8"]
      allow = [
        {
          protocol = "tcp"
          ports    = []
        }
      ]
    }
  ]

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project ID where the shared VPC will be created. | `string` | n/a | yes |
| `network_name` | Name of the shared VPC network. | `string` | `"shared-vpc"` | no |
| `description` | Optional description for the VPC network. | `string` | `null` | no |
| `routing_mode` | Network routing mode: `GLOBAL` or `REGIONAL`. | `string` | `"GLOBAL"` | no |
| `region` | Default region for regional resources such as the Cloud NAT router. | `string` | `"us-central1"` | no |
| `subnets` | List of subnets to create within the shared VPC. | `list(object({ name = string, region = string, cidr = string, private_ip_google_access = optional(bool, true), flow_logs = optional(bool, false) }))` | `[]` | no |
| `cloud_nat` | Cloud NAT configuration for outbound internet access from private subnets. | `object({ create = optional(bool, true), min_ports_per_vm = optional(number, 64), max_ports_per_vm = optional(number, 65536), log_type = optional(string, "ALL") })` | see `variables.tf` | no |
| `firewall_rules` | List of firewall rules to apply to the shared VPC. | `list(object({ name = string, description = optional(string, ""), direction = optional(string, "INGRESS"), priority = optional(number, 1000), source_ranges = optional(list(string), []), destination_ranges = optional(list(string), []), source_tags = optional(list(string), []), target_tags = optional(list(string), []), allow = optional(list(object({ protocol = string, ports = optional(list(string), []) })), []), deny = optional(list(object({ protocol = string, ports = optional(list(string), []) })), []) }))` | `[]` | no |
| `labels` | Labels to apply to the VPC network and other resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `network_id` | The id of the shared VPC network. |
| `network_name` | The name of the shared VPC network. |
| `network_self_link` | The self_link of the shared VPC network. |
| `subnet_ids` | Map of subnet names to subnet IDs. |
| `subnet_self_links` | Map of subnet names to subnet self_links. |
| `subnet_regions` | Map of subnet names to subnet regions. |
| `router_name` | Name of the Cloud Router created for NAT, if enabled. |
| `nat_name` | Name of the Cloud NAT configuration, if enabled. |
| `firewall_rule_names` | Map of firewall rule names to their resource names. |

## Design Notes

- **No provider block**: This module does not declare a `provider` block, so it can
  be reused across projects and regions by the calling root module.
- **Stable state**: Subnets and firewall rules use `for_each` keyed by user-supplied
  names, so adding or removing items does not force recreation of unrelated
  resources.
- **Private Google Access**: Enabled by default on all subnets so that private
  workloads can reach Google APIs and services without public IPs.
