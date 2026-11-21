variable "name" {
  description = "Globally unique API Management service name."
  type        = string
  default     = "apim-platform-dev-001"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "Canada Central"
}

variable "resource_group_name" {
  description = "Existing resource group name."
  type        = string
  default     = "rg-platform-dev"
}

variable "publisher_name" {
  description = "Publisher name shown in the developer portal."
  type        = string
  default     = "Contoso Platform"
}

variable "publisher_email" {
  description = "Publisher contact email."
  type        = string
  default     = "platform@example.com"
}

variable "workload" {
  description = "Workload name used for generated resource names."
  type        = string
  default     = "platform"
}

variable "app_env" {
  description = "Environment used for generated resource names."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = { Owner = "CCOE" }
}
