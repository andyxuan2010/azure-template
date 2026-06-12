# Tagging Standard

This repository uses a root-owned tagging model for Azure ARM resources.

Microsoft Entra modules such as app registrations and enterprise applications are different: their `tags` arguments are Entra metadata sets, not Azure ARM resource tags. Do not apply this ARM tag map pattern to those resources.

## Source Of Truth

Root compositions own enterprise tag normalization. Reusable modules consume already-normalized tags.

The root composition is responsible for:

- normalizing reserved tag keys and values
- producing the canonical tag map
- applying the canonical tags to the resource group
- passing the canonical tags to child modules through `inherited_resource_group_tags`

Reusable modules are responsible for:

- keeping `inherit_resource_group_tags` enabled by default
- accepting `inherited_resource_group_tags`
- merging inherited tags with resource-specific `var.tags`
- avoiding module-local `Environment` or `Workload` remapping

## Standard Inputs

Modules that support ARM tag inheritance must expose:

```hcl
variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into module resources."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module falls back to reading the resource group."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Additional resource-specific tags."
  default     = {}
}
```

## Merge Order

Modules should merge tags in this order:

```hcl
tags = merge(
  local.inherited_tags,
  var.tags
)
```

The intended precedence is:

1. Inherited resource group tags provide the enterprise baseline.
2. Resource-specific `var.tags` can add or override non-reserved metadata.

Modules must not append their own mandatory `Environment` or `Workload` map after `var.tags`. Reserved enterprise tags are normalized by the root composition.

## Inheritance Behavior

Use plan-known inherited tags when the root composition provides them:

```hcl
locals {
  inherited_tags = var.inherit_resource_group_tags ? coalesce(
    var.inherited_resource_group_tags,
    try(data.azurerm_resource_group.rg[0].tags, {})
  ) : {}
}
```

If a module also reads the resource group for location or other metadata, only skip the resource group data lookup when it is no longer needed:

```hcl
resource_group_lookup_required = trimspace(var.location) == "" || (
  var.inherit_resource_group_tags && var.inherited_resource_group_tags == null
)
```

This keeps standalone module usage compatible while avoiding `known after apply` tag maps when a root composition already has the canonical tag map.

## Azure Policy Compatibility

Some environments enforce tag inheritance through Azure Policy outside Terraform. Keep `inherit_resource_group_tags` defaulted to `true` so module behavior remains aligned with those guardrails.

When Azure Policy is also active, Terraform should still pass the same canonical inherited tag map from the root composition. That gives stable plans while policy remains available for enforcement and remediation of out-of-band resources.

## Validation Checklist

When adding or changing a module:

- Ensure Azure ARM resources that support tags use the module's final tag local.
- Ensure modules with ARM tag inheritance expose `inherited_resource_group_tags`.
- Ensure modules do not remap `Environment` or `Workload`.
- Keep Entra application/service principal tags separate from ARM tags.
- Run `terraform fmt -check -recursive`, `git diff --check`, and module/root validation where provider initialization is available.
