# Management Groups Examples

## Child Management Group

```hcl
module "corp_mg" {
  source = "./modules/managementgroups"

  name                       = "corp"
  display_name               = "Corporate"
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/contoso-root"
}
```

## Management Group With Subscription Placement

```hcl
subscription_ids = [
  "00000000-0000-0000-0000-000000000000"
]
```

Subscription IDs must be unique GUIDs. This module manages their placement
when they are included.
