mock_provider "azuredevops" {
  mock_resource "azuredevops_serviceendpoint_azurecr" {
    defaults = {
      workload_identity_federation_issuer  = "https://login.microsoftonline.com/44444444-4444-4444-4444-444444444444/v2.0"
      workload_identity_federation_subject = "provider-returned-subject"
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
  registry_id = "/subscriptions/22222222-2222-2222-2222-222222222222/resourceGroups/rg-acr/providers/Microsoft.ContainerRegistry/registries/acrtest"
}
run "secure_defaults" {
  command = plan
  assert {
    condition     = azuredevops_serviceendpoint_azurecr.this.service_endpoint_authentication_scheme == "WorkloadIdentityFederation"
    error_message = "Authentication must always use workload identity federation."
  }
  assert {
    condition     = azuredevops_serviceendpoint_azurecr.this.credentials[0].serviceprincipalid == var.managed_identity.client_id
    error_message = "The endpoint must use the caller-owned identity."
  }
  assert {
    condition     = length(azuredevops_pipeline_authorization.this) == 0
    error_message = "No pipeline access may be granted by default."
  }
  assert {
    condition     = azurerm_federated_identity_credential.this.parent_id == var.managed_identity.id && azurerm_federated_identity_credential.this.audience == tolist(["api://AzureADTokenExchange"])
    error_message = "Trust must target the supplied identity and Azure token exchange audience."
  }
}
run "explicit_pipeline_access" {
  command = plan
  variables {
    pipeline_ids              = { build = 42, release = 84 }
    federated_credential_name = "ado-specific-trust"
  }
  assert {
    condition     = length(azuredevops_pipeline_authorization.this) == 2 && azuredevops_pipeline_authorization.this["build"].pipeline_id == 42 && azuredevops_pipeline_authorization.this["release"].pipeline_id == 84
    error_message = "Only the explicitly selected pipelines may be authorized."
  }
  assert {
    condition     = alltrue([for authorization in azuredevops_pipeline_authorization.this : authorization.type == "endpoint" && authorization.project_id == var.project_id])
    error_message = "Authorizations must be service endpoints in the supplied project."
  }
  assert {
    condition     = azurerm_federated_identity_credential.this.name == "ado-specific-trust"
    error_message = "Credential naming must support multiple connections per identity."
  }
}
run "reject_invalid_pipeline_id" {
  command = plan
  variables { pipeline_ids = { invalid = 0 } }
  expect_failures = [var.pipeline_ids]
}
run "reject_fractional_pipeline_id" {
  command = plan
  variables { pipeline_ids = { invalid = 1.5 } }
  expect_failures = [var.pipeline_ids]
}
run "reject_blank_name" {
  command = plan
  variables { name = " " }
  expect_failures = [var.name]
}
run "reject_invalid_identity" {
  command = plan
  variables {
    managed_identity = {
      id        = "/subscriptions/22222222-2222-2222-2222-222222222222/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-test"
      client_id = "invalid"
      tenant_id = "44444444-4444-4444-4444-444444444444"
    }
  }
  expect_failures = [var.managed_identity]
}
run "target_scope_metadata" {
  command = plan
  assert {
    condition     = azuredevops_serviceendpoint_azurecr.this.azurecr_subscription_id == "22222222-2222-2222-2222-222222222222" && azuredevops_serviceendpoint_azurecr.this.resource_group == "rg-acr" && azuredevops_serviceendpoint_azurecr.this.azurecr_name == "acrtest"
    error_message = "The endpoint target metadata must match the requested Azure scope."
  }
}
run "reject_invalid_project" {
  command = plan
  variables { project_id = "invalid" }
  expect_failures = [var.project_id]
}
run "reject_invalid_credential_name" {
  command = plan
  variables { federated_credential_name = "contains spaces" }
  expect_failures = [var.federated_credential_name]
}
