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

  name         = "require-configured-tag"
  display_name = "Require configured tag"
  description  = "Audits resources that do not include the configured tag."
  policy_rule = jsonencode({
    if = {
      field  = "[concat('tags[', parameters('tagName'), ']')]"
      exists = "false"
    }
    then = {
      effect = "audit"
    }
  })
  parameters = jsonencode({
    tagName = {
      type = "String"
      metadata = {
        displayName = "Required tag name"
      }
    }
  })
  metadata = jsonencode({
    category = "Tags"
    version  = "1.0.0"
  })

  create_assignment      = true
  assignment_scope       = var.resource_group_id
  assignment_description = "Audits the required application tag."
  assignment_parameters = jsonencode({
    tagName = {
      value = var.required_tag_name
    }
  })
  assignment_metadata = jsonencode({
    owner = "platform-governance"
  })
  assignment_not_scopes = var.excluded_scopes
  non_compliance_messages = [{
    content = "Resources must include the required application tag."
  }]
  enforcement_mode = false
  identity_type    = "SystemAssigned"
  location         = var.location
}
