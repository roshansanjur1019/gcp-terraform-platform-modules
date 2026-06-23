variable "project_id" {
  description = "GCP project ID where the shared VPC will be created."
  type        = string
}

variable "network_name" {
  description = "Name of the shared VPC network."
  type        = string
  default     = "shared-vpc"
}

variable "description" {
  description = "Optional description for the VPC network."
  type        = string
  default     = null
}

variable "routing_mode" {
  description = "Network routing mode: GLOBAL or REGIONAL."
  type        = string
  default     = "GLOBAL"

  validation {
    condition     = contains(["GLOBAL", "REGIONAL"], var.routing_mode)
    error_message = "routing_mode must be GLOBAL or REGIONAL."
  }
}

variable "region" {
  description = "Default region for regional resources such as the Cloud NAT router."
  type        = string
  default     = "us-central1"
}

variable "subnets" {
  description = "List of subnets to create within the shared VPC."
  type = list(object({
    name                     = string
    region                   = string
    cidr                     = string
    private_ip_google_access = optional(bool, true)
    flow_logs                = optional(bool, false)
  }))
  default = []

  validation {
    condition     = length(distinct([for s in var.subnets : s.name])) == length(var.subnets)
    error_message = "Subnet names must be unique."
  }
}

variable "cloud_nat" {
  description = "Cloud NAT configuration for outbound internet access from private subnets."
  type = object({
    create           = optional(bool, true)
    min_ports_per_vm = optional(number, 64)
    max_ports_per_vm = optional(number, 65536)
    log_type         = optional(string, "ALL")
  })
  default = {
    create           = true
    min_ports_per_vm = 64
    max_ports_per_vm = 65536
    log_type         = "ALL"
  }

  validation {
    condition     = contains(["", "ERRORS_ONLY", "ALL", "TRANSLATIONS_ONLY"], var.cloud_nat.log_type)
    error_message = "cloud_nat.log_type must be one of: '', 'ERRORS_ONLY', 'ALL', 'TRANSLATIONS_ONLY'."
  }
}

variable "firewall_rules" {
  description = "List of firewall rules to apply to the shared VPC."
  type = list(object({
    name               = string
    description        = optional(string, "")
    direction          = optional(string, "INGRESS")
    priority           = optional(number, 1000)
    source_ranges      = optional(list(string), [])
    destination_ranges = optional(list(string), [])
    source_tags        = optional(list(string), [])
    target_tags        = optional(list(string), [])
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = []

  validation {
    condition     = length(distinct([for r in var.firewall_rules : r.name])) == length(var.firewall_rules)
    error_message = "Firewall rule names must be unique."
  }

  validation {
    condition = alltrue([
      for r in var.firewall_rules :
      contains(["INGRESS", "EGRESS"], r.direction)
    ])
    error_message = "Firewall rule direction must be INGRESS or EGRESS."
  }
}

variable "labels" {
  description = "Labels to apply to the VPC network and other resources."
  type        = map(string)
  default     = {}
}
