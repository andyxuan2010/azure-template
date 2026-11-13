output "id" {
  description = "Azure DevOps service connection ID."
  value       = azuredevops_serviceendpoint_azurerm.this.id
}

output "name" {
  description = "Service connection name for task inputs."
  value       = azuredevops_serviceendpoint_azurerm.this.service_endpoint_name
}

output "project_id" {
  description = "Azure DevOps project ID."
  value       = var.project_id
}

output "client_id" {
  description = "Managed identity client ID used by the connection."
  value       = var.managed_identity.client_id
}

output "federated_identity_credential_id" {
  description = "Federated trust resource ID."
  value       = azurerm_federated_identity_credential.this.id
}

output "workload_identity_federation_issuer" {
  description = "Issuer returned by Azure DevOps; do not construct this value manually."
  value       = azuredevops_serviceendpoint_azurerm.this.workload_identity_federation_issuer
}

output "workload_identity_federation_subject" {
  description = "Subject returned by Azure DevOps; do not construct this value manually."
  value       = azuredevops_serviceendpoint_azurerm.this.workload_identity_federation_subject
}

output "pipeline_authorization_ids" {
  description = "Explicit pipeline authorizations keyed by caller-supplied names."
  value       = { for key, authorization in azuredevops_pipeline_authorization.this : key => authorization.id }
}

output "federated_credential_name" {
  description = "Effective federated credential name, explicit or deterministically generated."
  value       = local.federated_credential_name
}
