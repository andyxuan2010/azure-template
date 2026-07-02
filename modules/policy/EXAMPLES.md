# Policy Examples

## Custom Policy Definition Without Assignment

```hcl
module "allowed_locations" {
  source = "../policy"

  name         = "allowed-locations"
  display_name = "Allowed Azure Locations"
  policy_rule  = jsonencode({
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
    }
  })
}
```

## Resource Group Assignment With Exclusion

```hcl
module "require_owner" {
  source = "../policy"

  name         = "require-owner"
  display_name = "Require Owner Tag"
  policy_rule  = jsonencode({
    if = {
      field  = "tags['Owner']"
      exists = "false"
    }
    then = { effect = "audit" }
  })

  create_assignment = true
  assignment_scope  = azurerm_resource_group.application.id
  assignment_not_scopes = [
    "${azurerm_resource_group.application.id}/providers/Microsoft.Resources/deployments/bootstrap"
  ]

  non_compliance_messages = [{
    content = "Resources must include an Owner tag."
  }]
}
```
