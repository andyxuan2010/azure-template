# Unit tests: mocked providers, plan-only. No cloud authentication and no cloud resources.

mock_provider "azurerm" {}

mock_provider "azuread" {}

variables {
  name           = "iactest"
  app_env        = "prod"
  location       = "canadacentral"
  resource_group = "rg-ccoe-iac-cc-dev"

  identity_type                            = "SystemAssigned"
  public_network_enabled                   = false
  managed_virtual_network_enabled          = true
  create_default_azure_integration_runtime = true
  app_admin_group                          = []
  app_user_group                           = []
  permissions                              = []
  enable_diagnostics                       = false
  log_analytics_workspace                  = {}
  managed_private_endpoint                 = []
  global_parameter                         = []
  enable_private_endpoint                  = false
  self_hosted_integration_runtime_enabled  = false

  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "plan" {
  command = plan

  assert {
    condition     = output.name == "iactest"
    error_message = "ADF explicit name override was not preserved."
  }

  assert {
    condition     = !contains(keys(output.merged_tags), "module") && !contains(keys(output.merged_tags), "name")
    error_message = "ADF merged tags should not include module-generated module or name tags."
  }

  assert {
    condition     = output.diagnostics_enabled == false
    error_message = "ADF diagnostics should be disabled when no workspace mapping is provided."
  }
}
