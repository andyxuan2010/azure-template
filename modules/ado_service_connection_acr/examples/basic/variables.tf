variable "organization_url" {
  description = "Azure DevOps organization URL, for example https://dev.azure.com/example."
  type        = string
}
variable "project_id" {
  description = "Existing Azure DevOps project UUID."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.project_id))
    error_message = "project_id must be a UUID."
  }
}
variable "name" {
  description = "Explicit service connection name used in Azure Pipelines task inputs."
  type        = string
  nullable    = false
  validation {
    condition     = length(trimspace(var.name)) > 0 && var.name == trimspace(var.name)
    error_message = "name must be nonempty without leading or trailing whitespace."
  }
}
variable "description" {
  description = "Service connection description for ownership and operational context."
  type        = string
  default     = "Managed by Terraform - CCOE"
  nullable    = false
}
variable "managed_identity" {
  description = "Existing user-assigned managed identity resource ID, client ID, and tenant ID; all must identify the same identity."
  type = object({
    id        = string
    client_id = string
    tenant_id = string
  })
  nullable = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/resourceGroups/[^/]+/providers/Microsoft.ManagedIdentity/userAssignedIdentities/[^/]+$", var.managed_identity.id)) && can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.managed_identity.client_id)) && can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.managed_identity.tenant_id))
    error_message = "managed_identity requires a user-assigned identity ARM ID and valid client and tenant UUIDs."
  }
}
variable "subscription_name" {
  description = "Display name of the target Azure subscription. This metadata does not grant Azure access."
  type        = string
  nullable    = false
  validation {
    condition     = length(trimspace(var.subscription_name)) > 0
    error_message = "subscription_name must not be empty."
  }
}
variable "pipeline_ids" {
  description = "Explicit existing pipeline IDs keyed by stable caller-defined names. Empty grants no pipeline access; all-pipeline authorization is unsupported."
  type        = map(number)
  default     = {}
  nullable    = false
  validation {
    condition     = alltrue([for id in values(var.pipeline_ids) : try(id > 0 && floor(id) == id, false)])
    error_message = "Every pipeline ID must be a positive integer."
  }
  validation {
    condition     = length(distinct(values(var.pipeline_ids))) == length(var.pipeline_ids)
    error_message = "Each pipeline ID must appear only once; duplicate IDs would manage the same authorization more than once."
  }
}
variable "federated_credential_name" {
  description = "Optional explicit federated credential name, unique within the identity. Null generates a deterministic name from the project and connection name."
  type        = string
  default     = null
  validation {
    condition     = var.federated_credential_name == null ? true : can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{2,119}$", var.federated_credential_name))
    error_message = "federated_credential_name must be null or 3-120 alphanumeric, hyphen, or underscore characters and start with an alphanumeric character."
  }
}
variable "registry_id" {
  description = "Existing ACR ARM resource ID; subscription, resource group, and registry name are derived from it."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(?i)^/subscriptions/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/resourceGroups/[^/]+/providers/Microsoft.ContainerRegistry/registries/[a-zA-Z0-9]{5,50}$", var.registry_id))
    error_message = "registry_id must be a complete Azure Container Registry ARM resource ID."
  }
}
