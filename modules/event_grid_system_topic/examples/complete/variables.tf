variable "name" {
  description = "Event Grid System Topic name."
  type        = string
  default     = "egt-platform-complete-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Event Grid System Topic."
  type        = string
  default     = "canadacentral"
}

variable "topic_type" {
  description = "Event Grid topic type for the source resource."
  type        = string
  default     = "Microsoft.Storage.StorageAccounts"
}

variable "source_resource_id" {
  description = "Full Azure resource ID for the event source."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Event Grid System Topic."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Component   = "event-grid-system-topic"
  }
}
