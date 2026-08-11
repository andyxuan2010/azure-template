terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "policy" {
  source = "../.."

  name                = "allowed-platform-locations"
  display_name        = "Allowed platform locations"
  management_group_id = var.management_group_id
  policy_rule = jsonencode({
    if = {
      not = {
        field = "location"
        in    = "[parameters('allowedLocations')]"
      }
    }
    then = {
      effect = "deny"
    }
  })
  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
      }
    }
  })

  create_assignment = true
  assignment_scope  = var.management_group_id
  assignment_parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_locations
    }
  })
  non_compliance_messages = [{
    content = "Resources must be deployed to an approved Azure region."
  }]
}
