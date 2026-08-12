variable "name" {
  description = "Azure Firewall name."
  type        = string
  default     = "afw-vhub-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing Virtual WAN resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the secured Virtual Hub."
  type        = string
  default     = "canadacentral"
}

variable "virtual_hub_id" {
  description = "Resource ID of the existing Azure Virtual Hub."
  type        = string
}

variable "virtual_hub_public_ip_count" {
  description = "Number of public IPs allocated by Azure for the hub firewall."
  type        = number
  default     = 2
}
