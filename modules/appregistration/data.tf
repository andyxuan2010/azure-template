data "azuread_client_config" "current" {}

data "azuread_service_principal" "api" {
  for_each = local.normalized_required_resource_access

  client_id = each.value.resource_app_id
}
