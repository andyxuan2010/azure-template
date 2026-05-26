locals {
  environment_tag_map = {
    prod    = "Production"
    dev     = "Development"
    qa      = "QA"
    test    = "Test"
    sbx     = "Sandbox"
    poc     = "POC"
    staging = "Staging"
  }

  location                 = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.adf[0].location
  is_production            = contains(["prod"], var.app_env)
  iac_lookup_required      = var.self_hosted_integration_runtime_enabled || var.enable_key_vault_secret_user_role_assignment
  storage_lookup_required  = var.self_hosted_integration_runtime_enabled
  private_endpoint_by_name = var.enable_private_endpoint && trimspace(var.private_endpoint_subnet_id) == ""
  network_inputs_required  = var.self_hosted_integration_runtime_enabled || local.private_endpoint_by_name
  use_vsts_configuration   = var.vsts_configuration != null ? trimspace(try(var.vsts_configuration.repository_name, "")) != "" : false
  use_github_configuration = var.github_configuration != null ? trimspace(try(var.github_configuration.repository_name, "")) != "" : false

  merged_tags = merge(
    var.inherit_resource_group_tags ? try(data.azurerm_resource_group.adf[0].tags, {}) : {},
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, var.app_env, var.app_env)
      workload    = var.workload
    }
  )

  diagnostics_enabled        = var.enable_diagnostics || length(var.log_analytics_workspace) > 0
  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) > 0])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) == 0])
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) > 0])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) == 0])

  region_code_map = {
    canadacentral  = "cc"
    canadaeast     = "ce"
    eastus         = "eus"
    eastus2        = "eus2"
    centralus      = "cus"
    southcentralus = "scus"
    northcentralus = "ncus"
    westus         = "wus"
    westus2        = "wus2"
    westus3        = "wus3"
  }
  suffix_map = {
    prod = "001"
    qa   = "301"
    dev  = "601"
    poc  = "701"
    test = "801"
    sbx  = "901"
  }
  suffix = lookup(local.suffix_map, var.app_env, "000")

  normalized_location = replace(replace(lower(local.location), " ", ""), "-", "")
  region_code         = lookup(local.region_code_map, local.normalized_location, substr(local.normalized_location, 0, 3))
  name                = lower(trimspace(var.name))
  adf_name            = var.custom_adf_name == null ? "adf-${local.region_code}-${local.name}-${var.app_env}-${local.suffix}" : trimspace(var.custom_adf_name)
  ir_name             = var.custom_default_ir_name == null ? "DefaultAutoResolve" : trimspace(var.custom_default_ir_name)
  shir_name           = var.custom_shir_name == null ? "shir-${local.name}-${var.app_env}-${local.suffix}" : trimspace(var.custom_shir_name)
  diagnostics_name    = var.custom_diagnostics_name == null ? "${local.name}-${local.region_code}-${var.app_env}" : trimspace(var.custom_diagnostics_name)

  private_endpoint_subnet_name_final = trimspace(var.private_endpoint_subnet_name) != "" ? trimspace(var.private_endpoint_subnet_name) : trimspace(var.app_snet)
  private_endpoint_vnet_name_final   = trimspace(var.private_endpoint_vnet_name) != "" ? trimspace(var.private_endpoint_vnet_name) : trimspace(var.app_vnet)
  private_endpoint_rg_name_final     = trimspace(var.private_endpoint_network_resource_group_name) != "" ? trimspace(var.private_endpoint_network_resource_group_name) : trimspace(var.app_vnet_rg)
  private_endpoint_subnet_id_final   = trimspace(var.private_endpoint_subnet_id) != "" ? trimspace(var.private_endpoint_subnet_id) : try(data.azurerm_subnet.app[0].id, null)
  private_dns_zone_id_final          = trimspace(var.private_dns_zone_id) != "" ? trimspace(var.private_dns_zone_id) : try(data.azurerm_private_dns_zone.adf_datafactory[0].id, "")

  additional_role_assignments = {
    for permission in var.permissions : "${permission.object_id}-${permission.role}" => permission
  }

  managed_private_endpoints = {
    for endpoint in var.managed_private_endpoint : endpoint.name => endpoint
  }
}
