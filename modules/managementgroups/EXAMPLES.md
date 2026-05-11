# Management Groups Examples

## Child Management Group

```hcl
module "corp_mg" {
  source = "../managementgroups"

  name                       = "corp"
  display_name               = "Corporate"
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/contoso-root"
}
```
