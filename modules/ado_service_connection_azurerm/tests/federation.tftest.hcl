# Apply against mocked providers only; no Azure/DevOps API calls, credentials, resources, or costs.
mock_provider "azuredevops" {
  mock_resource "azuredevops_serviceendpoint_azurerm" {
    defaults = {
      id                                   = "55555555-5555-5555-5555-555555555555"
      workload_identity_federation_issuer  = "https://login.microsoftonline.com/44444444-4444-4444-4444-444444444444/v2.0"
      workload_identity_federation_subject = "opaque-provider-returned-subject"
    }
  }
}
mock_provider "azurerm" {}
variables {
  project_id        = "11111111-1111-1111-1111-111111111111"
  name              = "sc-test"
  subscription_name = "Example subscription"
  managed_identity = {
    id        = "/subscriptions/22222222-2222-2222-2222-222222222222/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-build"
    client_id = "33333333-3333-3333-3333-333333333333"
    tenant_id = "44444444-4444-4444-4444-444444444444"
  }
  subscription_id = "22222222-2222-2222-2222-222222222222"
}

run "federation_contract" {
  command = apply
  variables { pipeline_ids = { build = 42 } }
  assert {
    condition     = azurerm_federated_identity_credential.this.issuer == "https://login.microsoftonline.com/44444444-4444-4444-4444-444444444444/v2.0" && azurerm_federated_identity_credential.this.subject == "opaque-provider-returned-subject"
    error_message = "Trust must use exactly the issuer and opaque subject returned by Azure DevOps."
  }
  assert {
    condition     = azuredevops_pipeline_authorization.this["build"].resource_id == azuredevops_serviceendpoint_azurerm.this.id && azuredevops_pipeline_authorization.this["build"].pipeline_id == 42
    error_message = "Pipeline access must reference this endpoint and the selected pipeline."
  }
  assert {
    condition     = output.workload_identity_federation_issuer == azurerm_federated_identity_credential.this.issuer && output.workload_identity_federation_subject == azurerm_federated_identity_credential.this.subject
    error_message = "Trust outputs must describe the credential actually provisioned."
  }
}
