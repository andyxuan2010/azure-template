
# -------------------------------------------------------------------
# Root Harness Notes
# -------------------------------------------------------------------
# This file is intentionally organized in exact modules/ folder order.
# Each block is isolated, plan-oriented, and guarded by
# local.module_plan_enabled.<module_name> so the root can remain a clean
# validation harness without forcing every module's live prerequisites
# to exist at the same time.
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# acr
# -------------------------------------------------------------------
module "acr" {
  count  = local.module_plan_enabled.acr ? 1 : 0
  source = "./modules/acr"

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name         = local.resource_group_name
  location                    = var.location
  name                        = "acr${var.workload}${var.environment}001"
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# adf
# -------------------------------------------------------------------
module "adf" {
  count  = local.module_plan_enabled.adf ? 1 : 0
  source = "./modules/adf"

  name                        = var.workload
  workload                    = var.workload
  inherit_resource_group_tags = false
  location                    = var.location
  iac_rg                      = local.resource_group_name
  iac_kv                      = local.key_vault_name
  iac_st                      = local.storage_account_name
  app_rg                      = local.resource_group_name
  app_snet                    = local.app_subnet_name
  app_vnet_rg                 = local.network_resource_group
  app_vnet                    = local.vnet_name
  app_vm                      = local.vm_name
  app_env                     = var.environment
  resource_group              = local.resource_group_name
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# aks
# -------------------------------------------------------------------
module "aks" {
  count  = local.module_plan_enabled.aks ? 1 : 0
  source = "./modules/aks"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = "aks-${local.name_suffix}"
  default_node_pool = {
    vnet_subnet_id = local.app_subnet_id
  }
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# applicationgateway
# -------------------------------------------------------------------
module "applicationgateway" {
  count  = local.module_plan_enabled.applicationgateway ? 1 : 0
  source = "./modules/applicationgateway"

  name                        = trimspace(var.applicationgateway_name) != "" ? var.applicationgateway_name : "agw-${local.name_suffix}"
  resource_group_name         = local.resource_group_name
  location                    = var.location
  subnet_id                   = trimspace(var.applicationgateway_subnet_id) != "" ? var.applicationgateway_subnet_id : local.app_subnet_id
  backend_address_pools       = var.applicationgateway_backend_address_pools
  backend_http_settings       = var.applicationgateway_backend_http_settings
  http_listeners              = var.applicationgateway_http_listeners
  request_routing_rules       = var.applicationgateway_request_routing_rules
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  tags                        = var.tags
}

# -------------------------------------------------------------------
# appregistration
# -------------------------------------------------------------------
module "appregistration" {
  count  = local.module_plan_enabled.appregistration ? 1 : 0
  source = "./modules/appregistration"

  name = "appreg-${local.name_suffix}"
  tags = ["terraform", "plan-harness"]
}

# -------------------------------------------------------------------
# appservice
# -------------------------------------------------------------------
module "appservice" {
  count  = local.module_plan_enabled.appservice ? 1 : 0
  source = "./modules/appservice"

  depends_on = [module.appserviceplan]

  name                        = "app-${local.name_suffix}"
  resource_group_name         = local.resource_group_name
  location                    = var.location
  app_service_plan_id         = local.module_plan_enabled.appserviceplan ? module.appserviceplan[0].id : local.app_service_plan_id
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# appserviceplan
# -------------------------------------------------------------------
module "appserviceplan" {
  count  = local.module_plan_enabled.appserviceplan ? 1 : 0
  source = "./modules/appserviceplan"

  name                        = local.app_service_plan_name
  resource_group_name         = local.resource_group_name
  location                    = var.location
  sku_name                    = "S1"
  log_analytics_workspace_id  = ""
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# automationaccount
# -------------------------------------------------------------------
module "automationaccount" {
  count  = local.module_plan_enabled.automationaccount ? 1 : 0
  source = "./modules/automationaccount"

  resource_group_name         = local.resource_group_name
  location                    = var.location
  name                        = "aa-${local.name_suffix}"
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# availabilityset
# -------------------------------------------------------------------
module "availabilityset" {
  for_each = local.module_plan_enabled.availabilityset ? var.availabilitysets : {}
  source   = "./modules/availabilityset"

  name                         = trimspace(try(each.value.name, "")) != "" ? each.value.name : "avail-${var.workload}-${local.region_code}-${var.environment}-${each.key}"
  resource_group_name          = trimspace(try(each.value.resource_group_name, "")) != "" ? each.value.resource_group_name : local.resource_group_name
  location                     = trimspace(try(each.value.location, "")) != "" ? each.value.location : var.location
  location_code                = try(each.value.location_code, local.region_code)
  workload_name                = try(each.value.workload_name, var.workload)
  app_env                      = try(each.value.app_env, var.environment)
  instance                     = try(each.value.instance, each.key)
  platform_fault_domain_count  = try(each.value.platform_fault_domain_count, 2)
  platform_update_domain_count = try(each.value.platform_update_domain_count, 5)
  managed                      = try(each.value.managed, true)
  proximity_placement_group_id = try(each.value.proximity_placement_group_id, null)
  inherit_resource_group_tags  = try(each.value.inherit_resource_group_tags, false)
  tags                         = merge(var.tags, try(each.value.tags, {}))
}

# -------------------------------------------------------------------
# azure_ai_search
# -------------------------------------------------------------------
module "azure_ai_search" {
  count  = local.module_plan_enabled.azure_ai_search ? 1 : 0
  source = "./modules/azure_ai_search"

  resource_group_name         = local.resource_group_name
  location                    = var.location
  name                        = "srch-${local.name_suffix}"
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# azure_ai_service
# -------------------------------------------------------------------
module "azure_ai_service" {
  count  = local.module_plan_enabled.azure_ai_service ? 1 : 0
  source = "./modules/azure_ai_service"

  resource_group_name         = local.resource_group_name
  location                    = var.location
  name                        = "ais-${local.name_suffix}"
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# containerapp
# -------------------------------------------------------------------
module "containerapp" {
  count  = local.module_plan_enabled.containerapp ? 1 : 0
  source = "./modules/containerapp"

  resource_group_name           = local.resource_group_name
  location                      = var.location
  name                          = trimspace(var.containerapp_name) != "" ? var.containerapp_name : "ca-${var.workload}-${local.region_code}-${var.environment}-001"
  app_env                       = var.environment
  workload                      = var.workload
  location_code                 = local.region_code
  container_app_environment_id  = trimspace(var.containerapp_environment_id) != "" ? var.containerapp_environment_id : local.containerapp_environment_id
  revision_mode                 = var.containerapp_revision_mode
  containers                    = var.containerapp_containers
  ingress                       = var.containerapp_ingress
  min_replicas                  = var.containerapp_min_replicas
  max_replicas                  = var.containerapp_max_replicas
  secrets                       = var.containerapp_secrets
  registries                    = var.containerapp_registries
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}
  tags                          = var.tags
}

# -------------------------------------------------------------------
# cosmosdb
# -------------------------------------------------------------------
module "cosmosdb" {
  count  = local.module_plan_enabled.cosmosdb ? 1 : 0
  source = "./modules/cosmosdb"

  resource_group_name         = local.resource_group_name
  location                    = var.location
  name                        = trimspace(var.cosmosdb_name) != "" ? var.cosmosdb_name : "cosmos-${local.name_suffix}"
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  sql_databases               = var.cosmosdb_sql_databases
  sql_containers              = var.cosmosdb_sql_containers
  tags                        = var.tags
}

# -------------------------------------------------------------------
# databricks
# -------------------------------------------------------------------
module "databricks" {
  count  = local.module_plan_enabled.databricks ? 1 : 0
  source = "./modules/databricks"

  resource_group_name         = local.resource_group_name
  location                    = var.location
  name                        = trimspace(var.databricks_name) != "" ? var.databricks_name : "dbw-${local.name_suffix}"
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# enterpriseapplication
# -------------------------------------------------------------------
module "enterpriseapplication" {
  count  = local.module_plan_enabled.enterpriseapplication ? 1 : 0
  source = "./modules/enterpriseapplication"

  application_id                = trimspace(var.enterprise_application_application_id) != "" ? var.enterprise_application_application_id : one(module.appregistration[*].application_id)
  account_enabled               = var.enterprise_application_account_enabled
  app_role_assignment_required  = var.enterprise_application_app_role_assignment_required
  description                   = var.enterprise_application_description
  notes                         = var.enterprise_application_notes
  login_url                     = var.enterprise_application_login_url
  preferred_single_sign_on_mode = var.enterprise_application_preferred_single_sign_on_mode
  saml_relay_state              = var.enterprise_application_saml_relay_state
  owners                        = var.enterprise_application_owners
  add_current_caller_as_owner   = var.enterprise_application_add_current_caller_as_owner
  notification_email_addresses  = var.enterprise_application_notification_email_addresses
  feature_tags                  = var.enterprise_application_feature_tags
  use_existing                  = var.enterprise_application_use_existing
  app_role_assignments          = var.enterprise_application_app_role_assignments
  create_application_proxy      = var.enterprise_application_create_application_proxy
  application_proxy             = var.enterprise_application_create_application_proxy ? var.enterprise_application_application_proxy : null
}

# -------------------------------------------------------------------
# eventhub
# -------------------------------------------------------------------
module "eventhub" {
  count  = local.module_plan_enabled.eventhub ? 1 : 0
  source = "./modules/eventhub"

  resource_group_name         = local.resource_group_name
  location                    = var.location
  name                        = trimspace(var.eventhub_name) != "" ? var.eventhub_name : "evh-${local.name_suffix}"
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  eventhubs                   = var.eventhub_eventhubs
  tags                        = var.tags
}

# -------------------------------------------------------------------
# firewall
# -------------------------------------------------------------------
module "firewall" {
  count  = local.module_plan_enabled.firewall ? 1 : 0
  source = "./modules/firewall"

  name                        = trimspace(var.firewall_name) != "" ? var.firewall_name : "afw-${local.name_suffix}"
  resource_group_name         = local.resource_group_name
  location                    = var.location
  subnet_id                   = trimspace(var.firewall_subnet_id) != "" ? var.firewall_subnet_id : local.firewall_subnet_id
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  tags                        = var.tags
}

# -------------------------------------------------------------------
# fortigate
# -------------------------------------------------------------------
module "fortigate" {
  count  = local.module_plan_enabled.fortigate ? 1 : 0
  source = "./modules/fortigate"

  architecture                        = var.fortigate_architecture
  resource_group_name                 = local.resource_group_name
  location                            = var.location
  name                                = trimspace(var.fortigate_name_prefix) != "" ? var.fortigate_name_prefix : "fgt-${local.name_suffix}"
  app_env                             = var.environment
  workload                            = var.workload
  license_type                        = var.fortigate_license_type
  vm_size                             = var.fortigate_vm_size
  availability_zones                  = var.fortigate_availability_zones
  single_zone                         = var.fortigate_single_zone
  load_balancer_frontend_zones        = var.fortigate_load_balancer_frontend_zones
  admin_username                      = var.fortigate_admin_username
  admin_password                      = var.fortigate_admin_password
  admin_ssh_public_key                = var.fortigate_admin_ssh_public_key
  management_access_model             = var.fortigate_management_access_model
  image                               = var.fortigate_image
  marketplace_plan                    = var.fortigate_marketplace_plan
  os_disk                             = var.fortigate_os_disk
  custom_data                         = var.fortigate_custom_data
  create_subnets                      = var.fortigate_create_subnets
  virtual_network_name                = trimspace(var.fortigate_virtual_network_name) != "" ? var.fortigate_virtual_network_name : local.vnet_name
  virtual_network_resource_group_name = trimspace(var.fortigate_virtual_network_resource_group_name) != "" ? var.fortigate_virtual_network_resource_group_name : local.network_resource_group
  interfaces = {
    for name, interface in var.fortigate_interfaces : name => merge(interface, {
      subnet_id = try(trimspace(interface.subnet_id), "") != "" ? interface.subnet_id : "${local.vnet_id}/subnets/snet-fortigate-${name}"
    })
  }
  create_network_security_group = var.fortigate_create_network_security_group
  network_security_group_name   = var.fortigate_network_security_group_name
  network_security_rules        = var.fortigate_network_security_rules
  internal_load_balancer        = var.fortigate_internal_load_balancer
  external_load_balancer        = var.fortigate_external_load_balancer
  tags                          = var.tags
}

# -------------------------------------------------------------------
# functionapp
# -------------------------------------------------------------------
module "functionapp" {
  count  = local.module_plan_enabled.functionapp ? 1 : 0
  source = "./modules/functionapp"

  depends_on = [module.appserviceplan, module.storageaccount]

  resource_group_name                 = local.resource_group_name
  name                                = trimspace(var.functionapp_name) != "" ? var.functionapp_name : "func-${local.name_suffix}"
  location                            = var.location
  service_plan_id                     = trimspace(var.functionapp_service_plan_id) != "" ? var.functionapp_service_plan_id : (local.module_plan_enabled.appserviceplan ? module.appserviceplan[0].id : local.app_service_plan_id)
  storage_account_name                = trimspace(var.functionapp_storage_account_name) != "" ? var.functionapp_storage_account_name : (local.module_plan_enabled.storageaccount ? module.storageaccount[0].name : local.storage_account_name)
  storage_account_resource_group_name = trimspace(var.functionapp_storage_account_resource_group_name) != "" ? var.functionapp_storage_account_resource_group_name : (local.module_plan_enabled.storageaccount ? module.storageaccount[0].resource_group_name : local.resource_group_name)
  app_env                             = var.environment
  workload                            = var.workload
  inherit_resource_group_tags         = false
  app_admin_group                     = var.app_admin_group
  app_user_group                      = var.app_user_group
  tags                                = var.tags
}

# -------------------------------------------------------------------
# keyvault
# -------------------------------------------------------------------
module "keyvault" {
  count  = local.module_plan_enabled.keyvault ? 1 : 0
  source = "./modules/keyvault"

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name         = local.resource_group_name
  location                    = var.location
  tenant_id                   = local.tenant_id_resolved
  name                        = trimspace(var.keyvault_name) != "" ? var.keyvault_name : local.key_vault_name
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# linuxvm
# -------------------------------------------------------------------
module "linuxvm" {
  count  = local.module_plan_enabled.linuxvm ? 1 : 0
  source = "./modules/linuxvm"

  iac_rg                         = local.resource_group_name
  iac_kv                         = local.key_vault_name
  iac_kv_id                      = local.key_vault_id
  iac_st                         = local.storage_account_name
  iac_st_id                      = local.storage_account_id
  iac_st_primary_blob_endpoint   = "https://${local.storage_account_name}.blob.core.windows.net/"
  resource_group_name            = local.resource_group_name
  subnet_name                    = local.app_subnet_name
  subnet_id                      = local.app_subnet_id
  vnet_resource_group_name       = local.network_resource_group
  vnet_name                      = local.vnet_name
  name                           = local.vm_name
  app_env                        = var.environment
  workload                       = var.workload
  inherit_resource_group_tags    = false
  admin_username                 = var.azure-user
  admin_password                 = var.azure-password
  admin_ssh_key                  = var.azure-ssh-key
  admin_credentials_key_vault_id = local.key_vault_id
  datadog_api_key                = var.linux_vm_datadog_api_key
  private_ip_addresses           = var.linuxvm_private_ip_addresses
  app_admin_group                = var.app_admin_group
  app_user_group                 = var.app_user_group
  tags                           = var.tags
}

# -------------------------------------------------------------------
# loadbalancer
# -------------------------------------------------------------------
module "loadbalancer" {
  for_each = local.module_plan_enabled.loadbalancer ? var.loadbalancers : {}
  source   = "./modules/loadbalancer"

  name                = trimspace(try(each.value.name, "")) != "" ? each.value.name : "lb-${each.key}"
  resource_group_name = trimspace(try(each.value.resource_group_name, "")) != "" ? each.value.resource_group_name : local.resource_group_name
  location            = trimspace(try(each.value.location, "")) != "" ? each.value.location : var.location
  sku                 = try(each.value.sku, "Standard")
  sku_tier            = try(each.value.sku_tier, "Regional")
  frontend_ip_configurations = [
    for frontend in try(each.value.frontend_ip_configurations, []) : merge(frontend, {
      subnet_id = try(trimspace(frontend.public_ip_address_id), "") != "" ? try(frontend.subnet_id, null) : (try(trimspace(frontend.subnet_id), "") != "" ? frontend.subnet_id : local.app_subnet_id)
    })
  ]
  backend_address_pools       = try(each.value.backend_address_pools, [])
  probes                      = try(each.value.probes, [])
  lb_rules                    = try(each.value.lb_rules, [])
  outbound_rules              = try(each.value.outbound_rules, [])
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = try(each.value.inherit_resource_group_tags, false)
  tags                        = merge(var.tags, try(each.value.tags, {}))
}

# -------------------------------------------------------------------
# loganalytics
# -------------------------------------------------------------------
module "loganalytics" {
  count  = local.module_plan_enabled.loganalytics ? 1 : 0
  source = "./modules/loganalytics"

  name                        = trimspace(var.loganalytics_name) != "" ? var.loganalytics_name : local.log_analytics_name
  resource_group_name         = local.resource_group_name
  location                    = var.location
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  tags                        = var.tags
}

# -------------------------------------------------------------------
# logicapp
# -------------------------------------------------------------------
module "logicapp" {
  count  = local.module_plan_enabled.logicapp ? 1 : 0
  source = "./modules/logicapp"

  depends_on = [module.appserviceplan, module.storageaccount]

  resource_group_name                 = local.resource_group_name
  name                                = trimspace(var.logicapp_name) != "" ? var.logicapp_name : "logic-${local.name_suffix}"
  location                            = var.location
  service_plan_id                     = trimspace(var.logicapp_service_plan_id) != "" ? var.logicapp_service_plan_id : (local.module_plan_enabled.appserviceplan ? module.appserviceplan[0].id : local.app_service_plan_id)
  storage_account_name                = trimspace(var.logicapp_storage_account_name) != "" ? var.logicapp_storage_account_name : (local.module_plan_enabled.storageaccount ? module.storageaccount[0].name : local.storage_account_name)
  storage_account_resource_group_name = trimspace(var.logicapp_storage_account_resource_group_name) != "" ? var.logicapp_storage_account_resource_group_name : (local.module_plan_enabled.storageaccount ? module.storageaccount[0].resource_group_name : local.resource_group_name)
  app_env                             = var.environment
  workload                            = var.workload
  inherit_resource_group_tags         = false
  app_admin_group                     = var.app_admin_group
  app_user_group                      = var.app_user_group
  tags                                = var.tags
}

# -------------------------------------------------------------------
# managedidentity
# -------------------------------------------------------------------
module "managedidentity" {
  count  = local.module_plan_enabled.managedidentity ? 1 : 0
  source = "./modules/managedidentity"

  name                        = trimspace(var.managedidentity_name) != "" ? var.managedidentity_name : "id-${local.name_suffix}"
  resource_group_name         = local.resource_group_name
  location                    = var.location
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  tags                        = var.tags
}

# -------------------------------------------------------------------
# managementgroups
# -------------------------------------------------------------------
module "managementgroups" {
  count  = local.module_plan_enabled.managementgroups ? 1 : 0
  source = "./modules/managementgroups"

  name         = local.management_group_name
  display_name = "Platform ${upper(var.environment)}"
  app_env      = var.environment
  workload     = var.workload
  tags         = var.tags
}

# -------------------------------------------------------------------
# nsg
# -------------------------------------------------------------------
module "nsg" {
  count  = local.module_plan_enabled.nsg ? 1 : 0
  source = "./modules/nsg"

  name                        = trimspace(var.nsg_name) != "" ? var.nsg_name : "nsg-${local.name_suffix}"
  resource_group_name         = local.resource_group_name
  location                    = var.location
  security_rules              = var.nsg_security_rules
  subnet_ids                  = var.nsg_subnet_ids
  network_interface_ids       = var.nsg_network_interface_ids
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  tags                        = var.tags
}

# -------------------------------------------------------------------
# openai
# -------------------------------------------------------------------
module "openai" {
  count  = local.module_plan_enabled.openai ? 1 : 0
  source = "./modules/openai"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = "oai-${local.name_suffix}"
  deployments = {
    gpt4o_mini = {
      model_format = "OpenAI"
      model_name   = "gpt-4o-mini"
      sku_name     = "Standard"
    }
  }
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# policy
# -------------------------------------------------------------------
module "policy" {
  count  = local.module_plan_enabled.policy ? 1 : 0
  source = "./modules/policy"

  name                = trimspace(var.policy_name) != "" ? var.policy_name : "allowed-location-${var.environment}"
  display_name        = trimspace(var.policy_display_name) != "" ? var.policy_display_name : "Allowed Location ${upper(var.environment)}"
  management_group_id = trimspace(var.policy_management_group_id) != "" ? var.policy_management_group_id : local.management_group_id
  policy_rule         = trimspace(var.policy_rule) != "" ? var.policy_rule : local.sample_policy_rule
}

# -------------------------------------------------------------------
# private_dns
# -------------------------------------------------------------------
module "private_dns" {
  count  = local.module_plan_enabled.private_dns ? 1 : 0
  source = "./modules/private_dns"

  resource_group_name         = local.private_dns_resource_group
  zones                       = local.private_dns_zones
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  tags                        = var.tags
}

# -------------------------------------------------------------------
# private_endpoint
# -------------------------------------------------------------------
module "private_endpoint" {
  count  = local.module_plan_enabled.private_endpoint ? 1 : 0
  source = "./modules/private_endpoint"

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  name                                 = trimspace(var.private_endpoint_name) != "" ? var.private_endpoint_name : "pep-${local.name_suffix}"
  resource_group_name                  = local.resource_group_name
  location                             = var.location
  subnet_id                            = trimspace(var.private_endpoint_subnet_id) != "" ? var.private_endpoint_subnet_id : local.private_endpoint_subnet_id
  private_connection_resource_id       = trimspace(var.private_endpoint_private_connection_resource_id) != "" ? var.private_endpoint_private_connection_resource_id : local.storage_account_id
  subresource_names                    = var.private_endpoint_subresource_names
  private_dns_zone_ids                 = var.private_endpoint_private_dns_zone_ids
  private_dns_zone_names               = var.private_endpoint_private_dns_zone_names
  private_dns_zone_resource_group_name = trimspace(var.private_endpoint_private_dns_zone_resource_group_name) != "" ? var.private_endpoint_private_dns_zone_resource_group_name : local.private_dns_resource_group
  ip_configurations                    = var.private_endpoint_ip_configurations
  app_env                              = var.environment
  workload                             = var.workload
  inherit_resource_group_tags          = false
  tags                                 = var.tags
}

# -------------------------------------------------------------------
# rg
# -------------------------------------------------------------------
module "rg" {
  count  = local.module_plan_enabled.rg ? 1 : 0
  source = "./modules/rg"

  name            = trimspace(var.rg_name) != "" ? var.rg_name : local.resource_group_name
  location        = var.location
  app_env         = var.environment
  workload        = var.workload
  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = var.tags
}

# -------------------------------------------------------------------
# roleassignments
# -------------------------------------------------------------------
module "roleassignments" {
  count  = local.module_plan_enabled.roleassignments ? 1 : 0
  source = "./modules/roleassignments"

  assignments = length(var.roleassignments_assignments) > 0 ? var.roleassignments_assignments : local.sample_role_assignments
}

# -------------------------------------------------------------------
# route_table
# -------------------------------------------------------------------
module "route_table" {
  count  = local.module_plan_enabled.route_table ? 1 : 0
  source = "./modules/route_table"

  name                        = trimspace(var.route_table_name) != "" ? var.route_table_name : "rt-${local.name_suffix}"
  resource_group_name         = local.resource_group_name
  location                    = var.location
  routes                      = var.route_table_routes
  subnet_ids                  = var.route_table_subnet_ids
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  tags                        = var.tags
}

# -------------------------------------------------------------------
# servicebus
# -------------------------------------------------------------------
module "servicebus" {
  count  = local.module_plan_enabled.servicebus ? 1 : 0
  source = "./modules/servicebus"

  resource_group_name         = local.resource_group_name
  location                    = var.location
  name                        = trimspace(var.servicebus_name) != "" ? var.servicebus_name : "sb-${local.name_suffix}"
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  queues                      = var.servicebus_queues
  topics                      = var.servicebus_topics
  subscriptions               = var.servicebus_subscriptions
  tags                        = var.tags
}

# -------------------------------------------------------------------
# sqldb
# -------------------------------------------------------------------
module "sqldb" {
  count  = local.module_plan_enabled.sqldb ? 1 : 0
  source = "./modules/sqldb"

  server_name                 = "sql-${var.workload}-${var.environment}"
  name                        = "sqldb-${var.workload}-${var.environment}"
  max_size_gb                 = 32
  admin_username              = "sqladminuser"
  admin_password              = "ChangeMe12345!"
  ad_admin_login_name         = "sql-admin-group"
  ad_admin_object_id          = var.sample_principal_object_id
  sku_name                    = "S0"
  resource_group_name         = local.resource_group_name
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  location                    = var.location
  private_endpoint_subnet_id  = local.private_endpoint_subnet_id
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# sqlmi
# -------------------------------------------------------------------
module "sqlmi" {
  count  = local.module_plan_enabled.sqlmi ? 1 : 0
  source = "./modules/sqlmi"

  depends_on = [module.vnet]

  name                         = trimspace(var.sqlmi_name) != "" ? var.sqlmi_name : "sqlmi-${local.name_suffix}"
  resource_group_name          = local.resource_group_name
  subnet_id                    = local.module_plan_enabled.vnet ? module.vnet[0].subnet_ids[local.app_subnet_name] : local.app_subnet_id
  administrator_login          = var.sqlmi_administrator_login
  administrator_login_password = var.sqlmi_administrator_login_password
  sku_name                     = var.sqlmi_sku_name
  vcores                       = var.sqlmi_vcores
  storage_size_in_gb           = var.sqlmi_storage_size_in_gb
  app_env                      = var.environment
  workload                     = var.workload
  inherit_resource_group_tags  = false
  app_admin_group              = var.app_admin_group
  app_user_group               = var.app_user_group
  tags                         = var.tags
}

# -------------------------------------------------------------------
# sqlmi_db
# -------------------------------------------------------------------
module "sqlmi_db" {
  count  = local.module_plan_enabled.sqlmi_db ? 1 : 0
  source = "./modules/sqlmi_db"

  depends_on = [module.sqlmi]

  app_sqlmi       = local.module_plan_enabled.sqlmi ? module.sqlmi[0].name : "sqlmi-${local.name_suffix}"
  name            = trimspace(var.sqlmi_db_name) != "" ? var.sqlmi_db_name : "sqlmidb-${local.name_suffix}"
  app_sqlmi_rg    = local.module_plan_enabled.sqlmi ? module.sqlmi[0].resource_group_name : local.resource_group_name
  app_env         = var.environment
  workload        = var.workload
  tags            = var.tags
  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
}

# -------------------------------------------------------------------
# storageaccount
# -------------------------------------------------------------------
module "storageaccount" {
  count  = local.module_plan_enabled.storageaccount ? 1 : 0
  source = "./modules/storageaccount"

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name         = local.resource_group_name
  location                    = var.location
  name                        = trimspace(var.storageaccount_name) != "" ? var.storageaccount_name : local.storage_account_name
  blob_properties             = var.shared_storage_blob_properties
  containers                  = var.storageaccount_containers
  file_shares                 = var.storageaccount_file_shares
  queues                      = var.storageaccount_queues
  tables                      = var.storageaccount_tables
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# subscription_vending
# -------------------------------------------------------------------
module "subscription_vending" {
  count  = local.module_plan_enabled.subscription_vending ? 1 : 0
  source = "./modules/subscription_vending"

  name                     = "sub-${local.name_suffix}"
  existing_subscription_id = local.subscription_resource_id
  management_group_id      = local.management_group_id
  app_env                  = var.environment
  workload                 = var.workload
  tags                     = var.tags
}

# -------------------------------------------------------------------
# vnet
# -------------------------------------------------------------------
module "vnet" {
  count  = local.module_plan_enabled.vnet ? 1 : 0
  source = "./modules/vnet"

  resource_group_name         = local.resource_group_name
  location                    = var.location
  name                        = trimspace(var.vnet_name) != "" ? var.vnet_name : local.vnet_name
  address_space               = var.vnet_address_space
  subnets                     = local.vnet_subnets
  app_env                     = var.environment
  workload                    = var.workload
  inherit_resource_group_tags = false
  app_admin_group             = var.app_admin_group
  app_user_group              = var.app_user_group
  tags                        = var.tags
}

# -------------------------------------------------------------------
# winvm
# -------------------------------------------------------------------
module "winvm" {
  count  = local.module_plan_enabled.winvm ? 1 : 0
  source = "./modules/winvm"

  iac_rg                           = local.resource_group_name
  iac_kv                           = local.key_vault_name
  iac_st                           = local.storage_account_name
  app_rg                           = local.resource_group_name
  app_snet                         = local.app_subnet_name
  app_vnet_rg                      = local.network_resource_group
  app_vnet                         = local.vnet_name
  name                             = local.vm_name
  app_env                          = var.environment
  workload                         = var.workload
  inherit_resource_group_tags      = false
  azure-user                       = var.azure-user
  azure-password                   = var.azure-password
  admin_credentials_key_vault_id   = local.key_vault_id
  app_admin_group                  = var.app_admin_group
  app_user_group                   = var.app_user_group
  vm_remote_group                  = var.winvm_vm_remote_group
  vm_admin_group                   = var.winvm_vm_admin_group
  public_network_enabled           = var.winvm_public_network_enabled
  private_ip_addresses             = var.winvm_private_ip_addresses
  enable_domain_join               = var.winvm_enable_domain_join
  domain_join_user                 = var.winvm_domain_join_user
  domain_join_password             = var.winvm_domain_join_password
  domain_join_username_secret_name = var.winvm_domain_join_username_secret_name
  domain_join_password_secret_name = var.winvm_domain_join_password_secret_name
  enable_shir                      = var.winvm_enable_shir
  tags                             = var.tags
}
