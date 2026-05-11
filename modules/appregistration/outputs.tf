output "application_object_id" {
  description = "Object ID of the app registration."
  value       = azuread_application.this.object_id
}

output "application_id" {
  description = "Application (client) ID of the app registration."
  value       = azuread_application.this.client_id
}

output "service_principal_object_id" {
  description = "Object ID of the created service principal."
  value       = var.create_service_principal ? azuread_service_principal.this[0].object_id : null
}

output "client_secret" {
  description = "Generated client secret value."
  value       = var.create_client_secret ? azuread_application_password.this[0].value : null
  sensitive   = true
}

output "client_secret_key_id" {
  description = "Key ID of the generated client secret."
  value       = var.create_client_secret ? azuread_application_password.this[0].key_id : null
}

output "client_secret_key_vault_secret_id" {
  description = "ID of the Key Vault secret storing the generated client secret."
  value       = length(azurerm_key_vault_secret.client_secret) > 0 ? azurerm_key_vault_secret.client_secret[0].id : null
}

output "required_resource_access" {
  description = "Resolved API permissions configured on the app registration."
  value = {
    for key, access in local.flattened_required_resource_access : key => {
      api_key             = access.api_key
      resource_app_id     = access.resource_app_id
      id                  = access.resolved_id
      type                = access.type
      value               = access.resolved_value
      grant_admin_consent = access.grant_admin_consent
    }
  }
}

output "web_redirect_uris" {
  description = "Effective web redirect URIs configured on the app registration, including any generated App Service callback URIs."
  value       = local.effective_web_redirect_uris
}
