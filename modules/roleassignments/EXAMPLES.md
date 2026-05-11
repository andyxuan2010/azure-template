# Examples

## Resource Group RBAC

Assign `Contributor` and `Reader` roles to known principal IDs or Entra group display names.

```hcl
module "roleassignments" {
  source = "./modules/roleassignments"

  assignments = {
    app_team_contributor = {
      scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-dev"
      role_definition_name = "Contributor"
      principal_name       = "APP-DEV-CONTRIBUTORS"
      principal_type       = "Group"
    }

    audit_reader = {
      scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-dev"
      role_definition_name = "Reader"
      principal_id         = "11111111-1111-1111-1111-111111111111"
      principal_type       = "ServicePrincipal"
    }
  }
}
```

## Subnet RBAC

Assign `Network Contributor` on a subnet to one or more Entra groups by display name.

```hcl
module "roleassignments" {
  source = "./modules/roleassignments"

  assignments = {
    dns_admins_subnet_network_contributor = {
      scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/snet-dns"
      role_definition_name = "Network Contributor"
      principal_name       = "Entuity_Admin"
      principal_type       = "Group"
    }

    dns_owners_subnet_network_contributor = {
      scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/snet-dns"
      role_definition_name = "Network Contributor"
      principal_name       = "BA-G-Azure-Owner-F"
      principal_type       = "Group"
    }
  }
}
```

## Idempotency Behavior

- Re-running `terraform apply` is safe for assignments already tracked in Terraform state.
- The module generates deterministic role assignment names for missing assignments it creates.
- The module now checks Azure for existing matching role assignments at each referenced scope and skips creating duplicates.
- Matching is based on `scope`, resolved role definition ID, resolved principal ID, `principal_type`, `condition`, and `condition_version`.
- Existing Azure assignments are skipped, not imported into Terraform state.

## Existing Azure Assignment Example

If the `Network Contributor` assignment below already exists in Azure at the target subnet for `Entuity_Admin`, the module will detect it and omit creation from the apply plan.

```hcl
module "roleassignments" {
  source = "./modules/roleassignments"

  assignments = {
    existing_dns_admins_subnet_network_contributor = {
      scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/snet-dns"
      role_definition_name = "Network Contributor"
      principal_name       = "Entuity_Admin"
      principal_type       = "Group"
    }
  }
}
```

## Import Example

If you want an already-existing Azure assignment to be managed in Terraform state instead of only skipped during create, import it explicitly.

```powershell
terraform import 'module.roleassignments.azurerm_role_assignment.this["app_team_contributor"]' "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/22222222-2222-2222-2222-222222222222"
```
