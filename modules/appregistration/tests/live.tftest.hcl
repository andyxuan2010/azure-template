provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {

  display_name                = "appreg-iactest-prod-ef8f"
  sign_in_audience            = "AzureADMyOrg"
  owners                      = []
  add_current_caller_as_owner = true
  web_redirect_uris           = ["https://example.contoso.com/signin-oidc"]
  app_service_redirect_hostnames = [
    "appreg-iactest-prod-ef8f.azurewebsites.net"
  ]
  app_service_auth_mode = "both"
  spa_redirect_uris     = []
  required_resource_access = {
    microsoft_graph = {
      resource_app_id = "00000003-0000-0000-c000-000000000000"
      resource_access = [
        {
          type  = "Role"
          value = "User.Read.All"
        }
      ]
    }
  }
  create_service_principal = true
  create_client_secret     = false
  #key_vault_name  = "kv-ccoe-eus-prod"
  key_vault_id                        = ""
  client_secret_key_vault_secret_name = ""
  tags = [
    "env:prod",
    "iac:terraform",
    "module:appregistration"
  ]
}

run "apply" {
  command = apply
}
