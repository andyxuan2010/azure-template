variable "name" {
  description = "Route table name."
  type        = string
  default     = "rt-firewall-egress-cc-prod-001"
}

variable "resource_group_name" {
  description = "Existing network resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the route table."
  type        = string
  default     = "canadacentral"
}

variable "firewall_private_ip" {
  description = "Reachable private frontend IP of the Azure Firewall or network virtual appliance."
  type        = string
}

variable "workload_subnet_ids" {
  description = "Workload subnet IDs whose default egress route is sent to the firewall."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to the route table."
  type        = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
