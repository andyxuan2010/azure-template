data "azuread_client_config" "current" {}

data "azuread_application" "this" {
  client_id = var.application_id
}
