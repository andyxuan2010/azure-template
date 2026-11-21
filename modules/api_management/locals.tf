locals {
  workload_code = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))
  naming_suffix = "${local.workload_code}-${var.app_env}-${trimspace(var.instance)}"
  apim_name     = trimspace(var.name) != "" ? trimspace(var.name) : trim(substr("apim-${local.naming_suffix}", 0, 50), "-")

  inherited_tags = var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {}
  tags           = merge(local.inherited_tags, var.tags)
}
