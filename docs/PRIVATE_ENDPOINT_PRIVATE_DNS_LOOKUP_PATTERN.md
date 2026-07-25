# Private Endpoint And Private DNS Lookup Pattern

This document records the private endpoint and private DNS lookup pattern that was applied to:

- `modules/appservice`
- `modules/storageaccount`
- `modules/keyvault`

Use this as the reference when the same change is needed in other modules.

## Why This Change Was Needed

In this repository, workload resources are often deployed from one subscription while shared networking and private DNS zones live in another subscription, typically accessed through the aliased provider `azurerm.prod`.

Before this change, several modules had one or both of these limitations:

- they could look up the private endpoint subnet by name, but only through the default `azurerm` provider
- they required a hardcoded `private_dns_zone_id` instead of allowing lookup by `private_dns_zone_name`

That caused two recurring problems:

- cross-subscription subnet or DNS lookups failed or required manual IDs
- root `terraform.tfvars` files accumulated hardcoded private DNS zone IDs that were harder to maintain

The goal of the pattern is to let callers choose either:

- direct ID input when they already have the resource ID
- lookup by name when the resource exists in the shared networking subscription

## Target Behavior

For a private-endpoint-capable module, the desired behavior is:

1. Support direct subnet ID input.
2. Support subnet lookup by `subnet_name`, `vnet_name`, and `network_resource_group_name`.
3. Support direct private DNS zone ID input.
4. Support private DNS zone lookup by `private_dns_zone_name` and `private_dns_zone_resource_group_name`.
5. Use `azurerm.prod` for lookup data sources when the shared networking and DNS resources live in that provider context.
6. Keep direct-ID behavior working so existing callers do not have to switch immediately.

## Implementation Pattern

Apply these steps inside the module.

### 1. Declare The Provider Alias

In `terraform.tf`, declare:

```hcl
terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.prod]
    }
  }
}
```

This is required whenever the module references `azurerm.prod`.

### 2. Use `azurerm.prod` For Lookup Data Sources

For private endpoint subnet lookup and private DNS zone lookup, use:

```hcl
provider = azurerm.prod
```

This should be applied to `data "azurerm_subnet"` and `data "azurerm_private_dns_zone"` when those lookups are meant to resolve shared network resources.

### 3. Keep Direct ID Inputs

Do not remove existing direct-ID inputs such as:

- `private_endpoint_subnet_id`
- `private_dns_zone_id`
- `private_dns_zone_ids`

Direct IDs remain the safest backward-compatible path.

### 4. Add Name-Based DNS Lookup Inputs

For single-zone services, the pattern is:

```hcl
variable "private_dns_zone_name" {}
variable "private_dns_zone_resource_group_name" {}
```

For multi-zone services such as Storage Account, the pattern is:

```hcl
variable "private_dns_zone_names" {
  type = map(string)
}

variable "private_dns_zone_resource_group_name" {}
```

### 5. Resolve Final IDs In `locals.tf`

Use locals so resources consume a single resolved value.

Single-zone example:

```hcl
private_dns_zone_id_resolved = trimspace(var.private_dns_zone_id) != "" ? var.private_dns_zone_id : try(data.azurerm_private_dns_zone.this[0].id, "")
```

Multi-zone example:

```hcl
private_dns_zone_ids_resolved = merge(
  { for key, value in var.private_dns_zone_ids : lower(key) => value },
  { for key, zone in data.azurerm_private_dns_zone.this : key => zone.id }
)
```

### 6. Validate Input Combinations

Validation should enforce:

- subnet ID or subnet lookup inputs when private endpoint is enabled
- DNS zone ID or DNS zone lookup inputs when private endpoint is enabled
- for map-based DNS inputs, keys must match expected subresource names

### 7. Update Resource Blocks To Use Resolved Values

The private endpoint resource should use the resolved subnet ID and resolved DNS zone ID rather than raw inputs.

### 8. Update Module Callers

Any caller that relies on lookup behavior must pass:

```hcl
providers = {
  azurerm      = azurerm
  azurerm.prod = azurerm.prod
}
```

This applies to:

- root module wiring
- landing zone wrappers
- examples
- Terraform tests

### 9. Update Docs And Tests

After the code change, also update:

- `README.md`
- `EXAMPLES.md`
- `QUICK_REFERENCE.md`
- `INDEX.md`
- `tests/live.tftest.hcl`
- root `variables.tf`
- root `main.tf`
- root `terraform.tfvars`

## Modules Already Updated

### App Service

Status: completed

Behavior:

- supports subnet lookup by name
- supports private DNS zone lookup by name
- uses `azurerm.prod` for the DNS lookup path

Primary files:

- `modules/appservice/data.tf`
- `modules/appservice/terraform.tf`

### Storage Account

Status: completed

Behavior:

- supports subnet lookup by name
- supports direct private DNS zone IDs keyed by subresource
- now also supports private DNS zone lookup by name keyed by subresource
- uses `azurerm.prod` for subnet and DNS lookups

Primary files:

- `modules/storageaccount/main.tf`
- `modules/storageaccount/locals.tf`
- `modules/storageaccount/variables.tf`
- `modules/storageaccount/terraform.tf`

Root-level additions:

- `storage_account_private_dns_zone_names`
- `storage_account_private_dns_zone_resource_group_name`

Example:

```hcl
storage_account_private_dns_zone_ids = {}

storage_account_private_dns_zone_names = {
  blob = "privatelink.blob.core.windows.net"
}

storage_account_private_dns_zone_resource_group_name = "rg-ba-cc-prod-app-network"
```

### Key Vault

Status: completed

Behavior:

- supports subnet lookup by name
- supports direct private DNS zone ID
- now also supports private DNS zone lookup by name
- uses `azurerm.prod` for subnet and DNS lookups

Primary files:

- `modules/keyvault/main.tf`
- `modules/keyvault/locals.tf`
- `modules/keyvault/variables.tf`
- `modules/keyvault/terraform.tf`

Root-level additions:

- `key_vault_private_dns_zone_name`
- `key_vault_private_dns_zone_resource_group_name`

Example:

```hcl
key_vault_private_dns_zone_id                  = ""
key_vault_private_dns_zone_name                = "privatelink.vaultcore.azure.net"
key_vault_private_dns_zone_resource_group_name = "rg-ba-cc-prod-app-network"
```

## Validation Approach

Direct `terraform validate` inside a child module can be misleading once the module expects an aliased provider from a caller.

Preferred validation approach:

1. create a small synthetic root module
2. declare both `azurerm` and `azurerm.prod`
3. call the child module with a `providers` map
4. run `terraform init -backend=false`
5. run `terraform validate`

This is the validation method used for the later storage account and key vault changes.

## Future Candidate Modules

The scan shows several modules with private endpoint support that still appear to rely on direct `private_dns_zone_id` input and default-provider subnet lookup.

### Highest Priority Candidates

- `modules/acr`
  Current shape: subnet lookup by name exists, private DNS is still ID-only.
  Why it fits: same exact pattern as the modules already updated.

- `modules/eventhub`
  Current shape: subnet lookup by name exists, private DNS is still ID-only.
  Why it fits: namespace private endpoint plus zone attachment follow the same single-zone model as Key Vault.

- `modules/servicebus`
  Current shape: subnet lookup by name exists, private DNS is still ID-only.
  Why it fits: same private endpoint and namespace DNS pattern as Event Hub.

- `modules/automationaccount`
  Current shape: subnet lookup by name exists, private DNS is still ID-only.
  Why it fits: private endpoint support already exists, but DNS lookup behavior is not aligned.

- `modules/azure_ai_service`
  Current shape: subnet lookup by name exists, private DNS is still ID-only.
  Why it fits: same pattern as OpenAI and other private-link-enabled PaaS services.

- `modules/openai`
  Current shape: subnet lookup by name exists, private DNS is still ID-only.
  Why it fits: same pattern as Azure AI Service.

### Secondary Review Candidates

- `modules/functionapp`
  Current shape: already supports subnet lookup and private DNS lookup by name.
  Gap to review: it does not currently declare or use the `azurerm.prod` alias pattern seen in the updated modules.

- `modules/adf`
  Current shape: already supports private DNS lookup by name.
  Gap to review: it should be checked for the same cross-subscription provider-alias pattern if DNS and network resources live in `azurerm.prod`.

### Lower Priority Or Different Pattern

- `modules/sqldb`
  Current shape: private endpoint support exists, but the subnet input pattern is more ID-driven and does not currently match the same lookup model.
  Recommendation: review separately rather than copy the pattern mechanically.

- `modules/aks`
  Uses private DNS for private cluster behavior, but this is not the same private endpoint DNS-group pattern as the PaaS modules above.

## Recommended Next Order

If more modules need this pattern, the recommended order is:

1. `acr`
2. `eventhub`
3. `servicebus`
4. `automationaccount`
5. `azure_ai_service`
6. `openai`
7. `functionapp` review for `azurerm.prod` alignment
8. `adf` review for `azurerm.prod` alignment

## Short Change Checklist

When applying this pattern to another module, use this checklist:

- add `configuration_aliases = [azurerm.prod]`
- move lookup data sources to `provider = azurerm.prod`
- add name-based DNS lookup inputs if missing
- resolve final subnet and DNS IDs in locals
- update private endpoint resource blocks to use resolved values
- update validations
- update examples
- update live tests
- update root `variables.tf`
- update root `main.tf`, even if the module block is commented out
- update root `terraform.tfvars`
- validate from a synthetic root module that passes `azurerm.prod`
