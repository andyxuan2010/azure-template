# Tagging Standard

This repository uses one ARM tagging pattern for Terraform modules that create Azure resources with `tags = map(string)`.

Microsoft Entra modules such as app registrations and enterprise applications are different: their `tags` arguments are Entra metadata sets, not Azure ARM resource tags. Do not apply this ARM tag map pattern to those resources.

## Required Tags

ARM-tagged modules must always produce these standard tags:

| Tag | Source | Logic |
| --- | --- | --- |
| `Environment` | Environment input such as `app_env` | Trim and lowercase the input for lookup, then map known values to the standard uppercase value. Unknown non-empty values are uppercased. |
| `Workload` | `workload` input | Trim the input and apply it as the workload tag value. |

Current modules use `app_env` as the environment input. If a future module uses `env` or `environment` instead, its `Environment` tag must use that module-specific environment input with the same mapping logic.

## Environment Mapping

Known environment values map as follows:

| Input | Tag Value |
| --- | --- |
| `prod` | `PROD` |
| `dev` | `DEV` |
| `qa` | `QA` |
| `test` | `TEST` |
| `sbx` | `SBX` |
| `poc` | `POC` |

Any other non-empty environment value falls back to `upper(trimspace(<environment input>))`.

## Merge Order

Modules should merge tags in this order:

```hcl
tags = merge(
  local.inherited_tags,
  var.tags,
  local.mandatory_tags
)
```

The intended precedence is:

1. Inherited resource group tags provide a baseline when the module supports `inherit_resource_group_tags`.
2. Caller-provided `var.tags` can override inherited tags.
3. Mandatory module tags override both inherited and caller-provided values for `Environment` and `Workload`.

This guarantees consumers cannot accidentally set conflicting `Environment` or `Workload` values through `var.tags`.

## Standard Locals

Use this pattern for modules that support resource group tag inheritance:

```hcl
locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  inherited_tags = var.inherit_resource_group_tags ? try(data.azurerm_resource_group.rg[0].tags, {}) : {}

  mandatory_tags = {
    Environment = lookup(local.environment_tag_map, lower(trimspace(var.app_env)), upper(trimspace(var.app_env)))
    Workload    = trimspace(var.workload)
  }

  tags = merge(
    local.inherited_tags,
    var.tags,
    local.mandatory_tags
  )
}
```

For modules that do not inherit resource group tags, omit `local.inherited_tags` and merge only `var.tags` plus `local.mandatory_tags`.

Some existing modules expose the final map as `local.tags`, `local.merged_tags`, or `local.effective_tags`. New modules should prefer `local.tags`; existing modules can keep their current local name when changing it would create unnecessary churn.

## Per-Resource Tags

When a resource supports its own additional tag map, merge resource-specific tags between the module standard tags and the mandatory tags:

```hcl
tags = merge(
  local.tags,
  try(each.value.tags, {}),
  local.mandatory_tags
)
```

This allows resource-specific metadata while still enforcing the standard `Environment` and `Workload` values.

## Root Harness

The root module passes the root `environment` variable into child module `app_env` inputs and passes the root `workload` variable into child module `workload` inputs. The GitHub workflow does not derive Terraform environment values from branch names; Terraform uses normal variable sources such as `terraform.tfvars`, CLI variables, environment variables, and defaults.

## Validation Checklist

When adding or changing a module:

- Ensure every Azure ARM resource that supports tags uses the module's final tag local.
- Ensure `Environment` is based on the module environment input, currently usually `app_env`.
- Ensure `Workload` is based on `trimspace(var.workload)`.
- Ensure mandatory tags are merged last.
- Keep Entra application/service principal tags separate from ARM tags.
- Run `terraform fmt -check -recursive`, `git diff --check`, and `terraform validate -no-color` from the repo root.
