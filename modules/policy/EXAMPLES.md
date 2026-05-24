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
