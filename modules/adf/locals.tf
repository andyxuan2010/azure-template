locals {
  is_production            = contains(["prod"], var.app_env)
  network_inputs_required  = var.self_hosted_integration_runtime_enabled || var.enable_private_endpoint
  use_vsts_configuration   = var.vsts_configuration != null ? trimspace(try(var.vsts_configuration.repository_name, "")) != "" : false
  use_github_configuration = var.github_configuration != null ? trimspace(try(var.github_configuration.repository_name, "")) != "" : false

  environment_tags = {
    prod    = { Environment = "Production", CostCenter = "Operations" }
    staging = { Environment = "Staging", CostCenter = "Operations" }
    dev     = { Environment = "Development", CostCenter = "Development" }
    sbx     = { Environment = "Sandbox", CostCenter = "Development" }
    test    = { Environment = "Test", CostCenter = "QA" }
    qa      = { Environment = "QA", CostCenter = "QA" }
    poc     = { Environment = "POC", CostCenter = "Development" }
  }

  merged_tags = merge(
    lookup(local.environment_tags, var.app_env, {}),
    { ManagedBy = "Terraform" },
    var.tags
  )

  diagnostics_enabled        = length(var.log_analytics_workspace) > 0
  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])

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

  normalized_location = replace(replace(lower(var.location), " ", ""), "-", "")
  region_code         = lookup(local.region_code_map, local.normalized_location, substr(local.normalized_location, 0, 3))
  name                = trimspace(var.name)
  adf_name            = var.custom_adf_name == null ? "adf-${local.region_code}-${local.name}-${var.app_env}-${local.suffix}" : var.custom_adf_name
  ir_name             = var.custom_default_ir_name == null ? "DefaultAutoResolve" : var.custom_default_ir_name
  shir_name           = var.custom_shir_name == null ? "shir-${local.name}-${var.app_env}-${local.suffix}" : var.custom_shir_name
  diagnostics_name    = var.custom_diagnostics_name == null ? "${local.name}-cc-${var.app_env}" : var.custom_diagnostics_name

  endpoint = {
    for target, values in var.managed_private_endpoint : "pep-${target.name}-${local.suffix}" => values
  }
}
