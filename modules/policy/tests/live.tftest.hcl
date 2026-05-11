provider "azurerm" {
  features {}
}

variables {
  name         = "require-tag-owner"
  display_name = "Require Owner Tag"
  policy_rule = jsonencode({
    if = {
      field  = "tags['Owner']"
      exists = "false"
    }
    then = {
      effect = "audit"
    }
  })
  parameters        = "{}"
  metadata          = jsonencode({ category = "Tags" })
  create_assignment = false
}

run "plan" {
  command = plan
}
