variable "name" {
  description = "Name of the user-assigned managed identity."
  type        = string
  default     = "id-orders-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the managed identity."
  type        = string
  default     = "canadacentral"
}

variable "aks_oidc_issuer_url" {
  description = "HTTPS OIDC issuer URL exposed by the target AKS cluster."
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace containing the trusted service account."
  type        = string
}

variable "kubernetes_service_account_name" {
  description = "Name of the trusted Kubernetes service account."
  type        = string
}

variable "role_assignment_scope" {
  description = "Existing Azure resource scope where the identity receives access."
  type        = string
}

variable "role_definition_name" {
  description = "Least-privilege built-in role assigned to the identity."
  type        = string
  default     = "Reader"
}
