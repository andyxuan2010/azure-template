locals {
  location_normalized = lower(trimspace(var.location))

  location_code_map = {
    australiaeast      = "aue"
    brazilsouth        = "brs"
    canadacentral      = "cac"
    canadaeast         = "cae"
    centralindia       = "cin"
    centralus          = "cus"
    eastasia           = "ea"
    eastus             = "eus"
    eastus2            = "eus2"
    francecentral      = "frc"
    germanywestcentral = "gwc"
    japaneast          = "jpe"
    koreacentral       = "krc"
    northeurope        = "neu"
    southcentralus     = "scus"
    southeastasia      = "sea"
    uksouth            = "uks"
    ukwest             = "ukw"
    westcentralus      = "wcus"
    westeurope         = "weu"
    westus             = "wus"
    westus2            = "wus2"
    westus3            = "wus3"
  }

  location_code_resolved = trimspace(var.location_code) != "" ? lower(trimspace(var.location_code)) : lookup(local.location_code_map, local.location_normalized, lower(join("", regexall("[a-z0-9]", replace(var.location, " ", "")))))
  random_suffix          = try(random_string.random[0].result, null)
  generated_suffix       = var.use_random_suffix ? local.random_suffix : trimspace(var.instance)
  generated_name_parts = compact([
    trimspace(var.name_prefix),
    trimspace(var.workload_name),
    var.include_environment_in_name ? var.app_env : "",
    local.location_code_resolved,
    local.generated_suffix
  ])
  generated_name      = substr(join("-", local.generated_name_parts), 0, 90)
  resource_group_name = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name

  environment_tags = {
    prod    = { Environment = "Production", CostCenter = "Operations" }
    staging = { Environment = "Staging", CostCenter = "Operations" }
    dev     = { Environment = "Development", CostCenter = "Development" }
    sbx     = { Environment = "Sandbox", CostCenter = "Development" }
    test    = { Environment = "Test", CostCenter = "QA" }
    qa      = { Environment = "QA", CostCenter = "QA" }
    poc     = { Environment = "POC", CostCenter = "Development" }
  }

  tags = merge(
    lookup(local.environment_tags, var.app_env, {}),
    {
      ManagedBy = "Terraform"
      module    = "rg"
      name      = local.resource_group_name
      app_env   = var.app_env
    },
    var.tags
  )

  lock_name_effective  = trimspace(var.lock_name) != "" ? trimspace(var.lock_name) : "${azurerm_resource_group.this.name}-lock"
  lock_notes_effective = trimspace(var.lock_notes) != "" ? trimspace(var.lock_notes) : "Managed by Terraform"

  app_admin_group_values = tolist(toset(compact([
    for value in coalesce(var.app_admin_group, []) : trimspace(value)
  ])))
  app_user_group_values = tolist(toset(compact([
    for value in coalesce(var.app_user_group, []) : trimspace(value)
  ])))

  entra_object_id_pattern = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"

  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex(local.entra_object_id_pattern, value))])

  app_admin_group_principal_ids = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )
  app_user_group_principal_ids = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )
}
