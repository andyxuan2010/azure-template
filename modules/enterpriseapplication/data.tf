data "azuread_client_config" "current" {}

data "azuread_application" "this" {
  count = var.create_application_proxy ? 1 : 0

  client_id = var.application_id
}
