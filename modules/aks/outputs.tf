output "id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "resource_group_name" {
  description = "The resource group containing the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.resource_group_name
}

output "location" {
  description = "The location of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.location
}

output "fqdn" {
  description = "The public FQDN of the AKS API server when available."
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "private_fqdn" {
  description = "The private FQDN of the AKS API server when private cluster mode is enabled."
  value       = try(azurerm_kubernetes_cluster.this.private_fqdn, null)
}

output "kubernetes_version" {
  description = "The resolved Kubernetes version of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.kubernetes_version
}

output "node_resource_group" {
  description = "The node resource group managed by AKS."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "azure_policy_enabled" {
  description = "Whether the Azure Policy AKS add-on is enabled."
  value       = azurerm_kubernetes_cluster.this.azure_policy_enabled
}

output "image_cleaner_enabled" {
  description = "Whether the AKS image cleaner feature is enabled."
  value       = azurerm_kubernetes_cluster.this.image_cleaner_enabled
}

output "private_dns_zone_id" {
  description = "The effective private DNS zone ID used by the AKS cluster when private cluster mode is enabled."
  value       = try(azurerm_kubernetes_cluster.this.private_dns_zone_id, null)
}

output "identity_principal_id" {
  description = "The principal ID of the AKS system-assigned managed identity."
  value       = try(azurerm_kubernetes_cluster.this.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "The tenant ID of the AKS system-assigned managed identity."
  value       = try(azurerm_kubernetes_cluster.this.identity[0].tenant_id, null)
}

output "kubelet_identity" {
  description = "The kubelet identity block exposed by AKS."
  value       = try(azurerm_kubernetes_cluster.this.kubelet_identity[0], null)
}

output "key_vault_secrets_provider_identity" {
  description = "The Key Vault Secrets Provider identity block when the addon is enabled."
  value       = try(azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0], null)
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL when OIDC is enabled."
  value       = try(azurerm_kubernetes_cluster.this.oidc_issuer_url, null)
}

output "diagnostic_setting_id" {
  description = "The ID of the AKS diagnostic setting, if created."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "tags" {
  description = "The effective tags assigned to the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.tags
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "terraform_execution_identity_cluster_access_role_assignment_id" {
  description = "The Azure Kubernetes Service RBAC role assignment ID granted to the current Terraform execution identity, if enabled."
  value       = try(azurerm_role_assignment.terraform_execution_identity_cluster_access[0].id, null)
}
