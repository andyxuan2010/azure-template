variable "name" {
  description = "Globally unique Key Vault name."
  type        = string
  default     = "kv-orders-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing workload resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault."
  type        = string
  default     = "canadacentral"
}

variable "shared_services_subscription_id" {
  description = "Subscription ID containing the shared VNet and private DNS zone."
  type        = string
}

variable "private_endpoint_subnet_name" {
  description = "Name of the existing private endpoint subnet."
  type        = string
  default     = "snet-private-endpoints"
}

variable "private_endpoint_vnet_name" {
  description = "Name of the existing shared-services VNet."
  type        = string
}

variable "network_resource_group_name" {
  description = "Resource group containing the shared VNet."
  type        = string
}

variable "dns_resource_group_name" {
  description = "Resource group containing the private DNS zone."
  type        = string
}
