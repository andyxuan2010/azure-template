mock_provider "azurerm" {}

variables {
  name                          = "id-platform-prod-001"
  resource_group_name           = "rg-platform-prod"
  location                      = "canadacentral"
  inherited_resource_group_tags = {}

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_identity_baseline" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Managed identity name was not propagated."
  }

  assert {
    condition     = output.tags.Owner == "CCOE" && !contains(keys(output.tags), "Environment")
    error_message = "Managed identity should preserve caller tags without adding module-generated tags."
  }
}

run "plan_federation_and_role_assignment" {
  command = plan

  variables {
    federated_identity_credentials = {
      github_main = {
        audience = ["api://AzureADTokenExchange"]
        issuer   = "https://token.actions.githubusercontent.com"
        subject  = "repo:contoso/platform:ref:refs/heads/main"
      }
    }
    role_assignments = {
      reader = {
        scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-prod"
        role_definition_name = "Reader"
      }
    }
  }

  assert {
    condition     = length(output.federated_identity_credential_ids) == 1 && length(output.role_assignment_ids) == 1
    error_message = "Expected one federated credential and one role assignment."
  }
}

run "reject_invalid_federated_credential" {
  command = plan

  variables {
    federated_identity_credentials = {
      bad = {
        audience = []
        issuer   = "not-https"
        subject  = ""
      }
    }
  }

  expect_failures = [
    var.federated_identity_credentials,
  ]
}
