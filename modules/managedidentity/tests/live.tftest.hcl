provider "azurerm" {
  features {}
}

variables {
  name                = "id-iactest-${formatdate("MMDDhhmmss", timestamp())}"
  resource_group_name = "rg-ba-cc-prd-shared-management"
  location            = "canadacentral"
}

run "apply" {
  command = apply

  variables {
    name                           = var.name
    resource_group_name            = var.resource_group_name
    location                       = var.location
    federated_identity_credentials = {}
    role_assignments               = {}
    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.name == var.name
    error_message = "Managed identity test name was not propagated to the module."
  }
}
