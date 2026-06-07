locals {
  name_suffix         = "${var.workload}-${var.environment}"
  normalized_location = replace(replace(lower(var.location), " ", ""), "-", "")
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
  region_code = lookup(local.region_code_map, local.normalized_location, substr(local.normalized_location, 0, 3))

  subscription_id_resolved = trimspace(var.subscription_id) != "" ? trimspace(var.subscription_id) : data.azurerm_client_config.current.subscription_id
  tenant_id_resolved       = trimspace(var.tenant_id) != "" ? trimspace(var.tenant_id) : data.azurerm_client_config.current.tenant_id

  resource_group_name        = var.shared_resource_group_name
  network_resource_group     = var.network_resource_group_name
  private_dns_resource_group = var.private_dns_resource_group_name
  vnet_name                  = var.shared_vnet_name
  app_subnet_name            = var.app_subnet_name
  private_endpoint_subnet    = var.private_endpoint_subnet_name
  firewall_subnet_name       = var.firewall_subnet_name

  subscription_resource_id   = "/subscriptions/${local.subscription_id_resolved}"
  resource_group_id          = "${local.subscription_resource_id}/resourceGroups/${local.resource_group_name}"
  network_resource_group_id  = "${local.subscription_resource_id}/resourceGroups/${local.network_resource_group}"
  vnet_id                    = "${local.subscription_resource_id}/resourceGroups/${local.network_resource_group}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}"
  app_subnet_id              = "${local.vnet_id}/subnets/${local.app_subnet_name}"
  private_endpoint_subnet_id = "${local.vnet_id}/subnets/${local.private_endpoint_subnet}"
  firewall_subnet_id         = "${local.vnet_id}/subnets/${local.firewall_subnet_name}"

  storage_account_name  = trimspace(var.shared_storage_account_name) != "" ? trimspace(var.shared_storage_account_name) : "st${var.workload}${local.region_code}${var.environment}"
  key_vault_name        = trimspace(var.shared_key_vault_name) != "" ? trimspace(var.shared_key_vault_name) : "kv${var.workload}${local.region_code}${var.environment}"
  log_analytics_name    = trimspace(var.shared_log_analytics_name) != "" ? trimspace(var.shared_log_analytics_name) : "law-${var.workload}-${var.environment}"
  app_service_plan_name = trimspace(var.shared_app_service_plan_name) != "" ? trimspace(var.shared_app_service_plan_name) : "asp-${var.workload}-${var.environment}"
  vm_name               = trimspace(var.shared_vm_name) != "" ? trimspace(var.shared_vm_name) : substr("vm${var.workload}${var.environment}", 0, 12)
  management_group_name = var.shared_management_group_name
  management_group_id   = "/providers/Microsoft.Management/managementGroups/${local.management_group_name}"

  storage_account_id         = "${local.resource_group_id}/providers/Microsoft.Storage/storageAccounts/${local.storage_account_name}"
  key_vault_id               = "${local.resource_group_id}/providers/Microsoft.KeyVault/vaults/${local.key_vault_name}"
  log_analytics_workspace_id = "${local.resource_group_id}/providers/Microsoft.OperationalInsights/workspaces/${local.log_analytics_name}"
  app_service_plan_id        = "${local.resource_group_id}/providers/Microsoft.Web/serverFarms/${local.app_service_plan_name}"
  user_assigned_identity_id  = "${local.resource_group_id}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-${local.name_suffix}"

  private_dns_zone_id = "${local.subscription_resource_id}/resourceGroups/${local.private_dns_resource_group}/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"

  private_dns_zones = {
    "privatelink.azurewebsites.net" = {
      vnet_links = {
        sample = {
          virtual_network_id   = local.vnet_id
          registration_enabled = false
          tags                 = var.tags
        }
      }
      a_records = {}
    }
  }

  default_vnet_subnets = {
    (local.app_subnet_name) = {
      address_prefixes = ["10.42.1.0/24"]
      delegations = local.module_plan_enabled.sqlmi || local.module_plan_enabled.sqlmi_db ? {
        sqlmi = {
          name                    = "sqlmi"
          service_delegation_name = "Microsoft.Sql/managedInstances"
          actions                 = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
        }
      } : {}
    }
    (local.private_endpoint_subnet) = {
      address_prefixes                  = ["10.42.2.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }
  vnet_subnets = merge(local.default_vnet_subnets, var.vnet_subnets)

  sample_policy_rule = jsonencode({
    if = {
      field = "location"
      notIn = [var.location]
    }
    then = {
      effect = "audit"
    }
  })

  sample_role_assignments = {
    reader = {
      scope                = local.subscription_resource_id
      role_definition_name = "Reader"
      principal_id         = var.sample_principal_object_id
    }
  }

  feature_keys = keys(var.features)
  feature_flags = {
    enable_acr                             = lookup(var.features, "enable_acr", var.module_plan_enabled.acr)
    enable_adf                             = lookup(var.features, "enable_adf", var.module_plan_enabled.adf)
    enable_aks                             = lookup(var.features, "enable_aks", var.module_plan_enabled.aks)
    enable_application_gateway             = lookup(var.features, "enable_application_gateway", var.module_plan_enabled.applicationgateway)
    enable_app_registration_for_appservice = lookup(var.features, "enable_app_registration_for_appservice", var.module_plan_enabled.appregistration)
    enable_app_services                    = lookup(var.features, "enable_app_services", var.module_plan_enabled.appservice || var.module_plan_enabled.appserviceplan)
    enable_automation_accounts             = lookup(var.features, "enable_automation_accounts", var.module_plan_enabled.automationaccount)
    enable_automation_ari_workloads        = lookup(var.features, "enable_automation_ari_workloads", false)
    enable_azure_ai_search                 = lookup(var.features, "enable_azure_ai_search", var.module_plan_enabled.azure_ai_search)
    enable_azure_ai_service                = lookup(var.features, "enable_azure_ai_service", var.module_plan_enabled.azure_ai_service)
    enable_cosmosdb                        = lookup(var.features, "enable_cosmosdb", var.module_plan_enabled.cosmosdb)
    enable_databricks                      = lookup(var.features, "enable_databricks", var.module_plan_enabled.databricks)
    enable_enterprise_application          = lookup(var.features, "enable_enterprise_application", var.module_plan_enabled.enterpriseapplication)
    enable_eventhub                        = lookup(var.features, "enable_eventhub", var.module_plan_enabled.eventhub)
    enable_firewall                        = lookup(var.features, "enable_firewall", var.module_plan_enabled.firewall)
    enable_functionapp                     = lookup(var.features, "enable_functionapp", var.module_plan_enabled.functionapp)
    enable_keyvault                        = lookup(var.features, "enable_keyvault", var.module_plan_enabled.keyvault)
    enable_linux_vm                        = lookup(var.features, "enable_linux_vm", var.module_plan_enabled.linuxvm)
    enable_loganalytics                    = lookup(var.features, "enable_loganalytics", var.module_plan_enabled.loganalytics)
    enable_logicapp                        = lookup(var.features, "enable_logicapp", var.module_plan_enabled.logicapp)
    enable_managed_identity                = lookup(var.features, "enable_managed_identity", var.module_plan_enabled.managedidentity)
    enable_management_group                = lookup(var.features, "enable_management_group", var.module_plan_enabled.managementgroups)
    enable_nsg                             = lookup(var.features, "enable_nsg", var.module_plan_enabled.nsg)
    enable_openai                          = lookup(var.features, "enable_openai", var.module_plan_enabled.openai)
    enable_policy                          = lookup(var.features, "enable_policy", var.module_plan_enabled.policy)
    enable_private_dns                     = lookup(var.features, "enable_private_dns", var.module_plan_enabled.private_dns)
    enable_resource_group                  = lookup(var.features, "enable_resource_group", var.module_plan_enabled.rg)
    enable_roleassignments                 = lookup(var.features, "enable_roleassignments", var.module_plan_enabled.roleassignments)
    enable_route_table                     = lookup(var.features, "enable_route_table", var.module_plan_enabled.route_table)
    enable_servicebus                      = lookup(var.features, "enable_servicebus", var.module_plan_enabled.servicebus)
    enable_sqldb                           = lookup(var.features, "enable_sqldb", var.module_plan_enabled.sqldb)
    enable_sqlmi                           = lookup(var.features, "enable_sqlmi", var.module_plan_enabled.sqlmi)
    enable_sqlmi_db                        = lookup(var.features, "enable_sqlmi_db", var.module_plan_enabled.sqlmi_db)
    enable_storageaccount                  = lookup(var.features, "enable_storageaccount", var.module_plan_enabled.storageaccount)
    enable_subscription_bootstrap          = lookup(var.features, "enable_subscription_bootstrap", var.module_plan_enabled.subscription_vending)
    enable_vnet                            = lookup(var.features, "enable_vnet", var.module_plan_enabled.vnet)
    enable_winvm                           = lookup(var.features, "enable_winvm", var.module_plan_enabled.winvm)
  }

  module_plan_enabled = merge(var.module_plan_enabled, {
    acr                   = local.feature_flags.enable_acr
    adf                   = local.feature_flags.enable_adf
    aks                   = local.feature_flags.enable_aks
    applicationgateway    = local.feature_flags.enable_application_gateway
    appregistration       = contains(local.feature_keys, "enable_app_services") || contains(local.feature_keys, "enable_app_registration_for_appservice") ? local.feature_flags.enable_app_services && local.feature_flags.enable_app_registration_for_appservice : var.module_plan_enabled.appregistration
    appservice            = contains(local.feature_keys, "enable_app_services") ? local.feature_flags.enable_app_services : var.module_plan_enabled.appservice
    appserviceplan        = contains(local.feature_keys, "enable_app_services") ? local.feature_flags.enable_app_services : var.module_plan_enabled.appserviceplan
    automationaccount     = local.feature_flags.enable_automation_accounts
    azure_ai_search       = local.feature_flags.enable_azure_ai_search
    azure_ai_service      = local.feature_flags.enable_azure_ai_service
    cosmosdb              = local.feature_flags.enable_cosmosdb
    databricks            = local.feature_flags.enable_databricks
    enterpriseapplication = local.feature_flags.enable_enterprise_application
    eventhub              = local.feature_flags.enable_eventhub
    firewall              = local.feature_flags.enable_firewall
    functionapp           = local.feature_flags.enable_functionapp
    keyvault              = local.feature_flags.enable_keyvault
    linuxvm               = local.feature_flags.enable_linux_vm
    loganalytics          = local.feature_flags.enable_loganalytics
    logicapp              = local.feature_flags.enable_logicapp
    managedidentity       = local.feature_flags.enable_managed_identity
    managementgroups      = local.feature_flags.enable_management_group
    nsg                   = local.feature_flags.enable_nsg
    openai                = local.feature_flags.enable_openai
    policy                = local.feature_flags.enable_policy
    private_dns           = local.feature_flags.enable_private_dns
    rg                    = local.feature_flags.enable_resource_group
    roleassignments       = local.feature_flags.enable_roleassignments
    route_table           = local.feature_flags.enable_route_table
    servicebus            = local.feature_flags.enable_servicebus
    sqldb                 = local.feature_flags.enable_sqldb
    sqlmi                 = local.feature_flags.enable_sqlmi
    sqlmi_db              = local.feature_flags.enable_sqlmi_db
    storageaccount        = local.feature_flags.enable_storageaccount
    subscription_vending  = local.feature_flags.enable_subscription_bootstrap
    vnet                  = local.feature_flags.enable_vnet
    winvm                 = local.feature_flags.enable_winvm
  })
}

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

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = "acr${var.workload}${var.environment}001"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  tags                = var.tags
}

# -------------------------------------------------------------------
# adf
# -------------------------------------------------------------------
module "adf" {
  count  = local.module_plan_enabled.adf ? 1 : 0
  source = "./modules/adf"

  name            = var.workload
  workload        = var.workload
  location        = var.location
  iac_rg          = local.resource_group_name
  iac_kv          = local.key_vault_name
  iac_st          = local.storage_account_name
  app_rg          = local.resource_group_name
  app_snet        = local.app_subnet_name
  app_vnet_rg     = local.network_resource_group
  app_vnet        = local.vnet_name
  app_vm          = local.vm_name
  app_env         = var.environment
  resource_group  = local.resource_group_name
  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = var.tags
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
  app_env         = var.environment
  workload        = var.workload
  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = var.tags
}

# -------------------------------------------------------------------
# applicationgateway
# -------------------------------------------------------------------
module "applicationgateway" {
  count  = local.module_plan_enabled.applicationgateway ? 1 : 0
  source = "./modules/applicationgateway"

  name                  = trimspace(var.applicationgateway_name) != "" ? var.applicationgateway_name : "agw-${local.name_suffix}"
  resource_group_name   = local.resource_group_name
  location              = var.location
  subnet_id             = trimspace(var.applicationgateway_subnet_id) != "" ? var.applicationgateway_subnet_id : local.app_subnet_id
  backend_address_pools = var.applicationgateway_backend_address_pools
  backend_http_settings = var.applicationgateway_backend_http_settings
  http_listeners        = var.applicationgateway_http_listeners
  request_routing_rules = var.applicationgateway_request_routing_rules
  app_env               = var.environment
  workload              = var.workload
  tags                  = var.tags
}

# -------------------------------------------------------------------
# appregistration
# -------------------------------------------------------------------
module "appregistration" {
  count  = local.module_plan_enabled.appregistration ? 1 : 0
  source = "./modules/appregistration"

  display_name = "appreg-${local.name_suffix}"
  tags         = ["terraform", "plan-harness"]
}

# -------------------------------------------------------------------
# appservice
# -------------------------------------------------------------------
module "appservice" {
  count  = local.module_plan_enabled.appservice ? 1 : 0
  source = "./modules/appservice"

  depends_on = [module.appserviceplan]

  app_name            = "app-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location
  app_service_plan_id = local.module_plan_enabled.appserviceplan ? module.appserviceplan[0].id : local.app_service_plan_id
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  tags                = var.tags
}

# -------------------------------------------------------------------
# appserviceplan
# -------------------------------------------------------------------
module "appserviceplan" {
  count  = local.module_plan_enabled.appserviceplan ? 1 : 0
  source = "./modules/appserviceplan"

  name                       = local.app_service_plan_name
  resource_group_name        = local.resource_group_name
  location                   = var.location
  sku_name                   = "S1"
  log_analytics_workspace_id = ""
  app_env                    = var.environment
  workload                   = var.workload
  app_admin_group            = var.app_admin_group
  app_user_group             = var.app_user_group
  tags                       = var.tags
}

# -------------------------------------------------------------------
# automationaccount
# -------------------------------------------------------------------
module "automationaccount" {
  count  = local.module_plan_enabled.automationaccount ? 1 : 0
  source = "./modules/automationaccount"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = "aa-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  tags                = var.tags
}

# -------------------------------------------------------------------
# azure_ai_search
# -------------------------------------------------------------------
module "azure_ai_search" {
  count  = local.module_plan_enabled.azure_ai_search ? 1 : 0
  source = "./modules/azure_ai_search"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = "srch-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  tags                = var.tags
}

# -------------------------------------------------------------------
# azure_ai_service
# -------------------------------------------------------------------
module "azure_ai_service" {
  count  = local.module_plan_enabled.azure_ai_service ? 1 : 0
  source = "./modules/azure_ai_service"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = "ais-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  tags                = var.tags
}

# -------------------------------------------------------------------
# cosmosdb
# -------------------------------------------------------------------
module "cosmosdb" {
  count  = local.module_plan_enabled.cosmosdb ? 1 : 0
  source = "./modules/cosmosdb"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = trimspace(var.cosmosdb_name) != "" ? var.cosmosdb_name : "cosmos-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  sql_databases       = var.cosmosdb_sql_databases
  sql_containers      = var.cosmosdb_sql_containers
  tags                = var.tags
}

# -------------------------------------------------------------------
# databricks
# -------------------------------------------------------------------
module "databricks" {
  count  = local.module_plan_enabled.databricks ? 1 : 0
  source = "./modules/databricks"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = trimspace(var.databricks_name) != "" ? var.databricks_name : "dbw-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  tags                = var.tags
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

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = trimspace(var.eventhub_name) != "" ? var.eventhub_name : "evh-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  eventhubs           = var.eventhub_eventhubs
  tags                = var.tags
}

# -------------------------------------------------------------------
# firewall
# -------------------------------------------------------------------
module "firewall" {
  count  = local.module_plan_enabled.firewall ? 1 : 0
  source = "./modules/firewall"

  name                = trimspace(var.firewall_name) != "" ? var.firewall_name : "afw-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location
  subnet_id           = trimspace(var.firewall_subnet_id) != "" ? var.firewall_subnet_id : local.firewall_subnet_id
  app_env             = var.environment
  workload            = var.workload
  tags                = var.tags
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

  resource_group_name = local.resource_group_name
  location            = var.location
  tenant_id           = local.tenant_id_resolved
  name                = trimspace(var.keyvault_name) != "" ? var.keyvault_name : local.key_vault_name
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  tags                = var.tags
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
  vm_name                        = local.vm_name
  app_env                        = var.environment
  workload                       = var.workload
  admin_username                 = var.azure-user
  admin_password                 = var.azure-password
  admin_ssh_key                  = var.azure-ssh-key
  admin_credentials_key_vault_id = local.key_vault_id
  datadog_api_key                = var.linux_vm_datadog_api_key
  app_admin_group                = var.app_admin_group
  app_user_group                 = var.app_user_group
  tags                           = var.tags
}

# -------------------------------------------------------------------
# loganalytics
# -------------------------------------------------------------------
module "loganalytics" {
  count  = local.module_plan_enabled.loganalytics ? 1 : 0
  source = "./modules/loganalytics"

  name                = trimspace(var.loganalytics_name) != "" ? var.loganalytics_name : local.log_analytics_name
  resource_group_name = local.resource_group_name
  location            = var.location
  app_env             = var.environment
  workload            = var.workload
  tags                = var.tags
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

  name                = trimspace(var.managedidentity_name) != "" ? var.managedidentity_name : "id-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location
  app_env             = var.environment
  workload            = var.workload
  tags                = var.tags
}

# -------------------------------------------------------------------
# managementgroups
# -------------------------------------------------------------------
module "managementgroups" {
  count  = local.module_plan_enabled.managementgroups ? 1 : 0
  source = "./modules/managementgroups"

  name         = local.management_group_name
  display_name = "Platform ${upper(var.environment)}"
  tags         = var.tags
}

# -------------------------------------------------------------------
# nsg
# -------------------------------------------------------------------
module "nsg" {
  count  = local.module_plan_enabled.nsg ? 1 : 0
  source = "./modules/nsg"

  name                  = trimspace(var.nsg_name) != "" ? var.nsg_name : "nsg-${local.name_suffix}"
  resource_group_name   = local.resource_group_name
  location              = var.location
  security_rules        = var.nsg_security_rules
  subnet_ids            = var.nsg_subnet_ids
  network_interface_ids = var.nsg_network_interface_ids
  app_env               = var.environment
  workload              = var.workload
  tags                  = var.tags
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
  app_env         = var.environment
  workload        = var.workload
  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = var.tags
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

  resource_group_name = local.private_dns_resource_group
  zones               = local.private_dns_zones
  app_env             = var.environment
  workload            = var.workload
  tags                = var.tags
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

  name                = trimspace(var.route_table_name) != "" ? var.route_table_name : "rt-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location
  routes              = var.route_table_routes
  subnet_ids          = var.route_table_subnet_ids
  app_env             = var.environment
  workload            = var.workload
  tags                = var.tags
}

# -------------------------------------------------------------------
# servicebus
# -------------------------------------------------------------------
module "servicebus" {
  count  = local.module_plan_enabled.servicebus ? 1 : 0
  source = "./modules/servicebus"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = trimspace(var.servicebus_name) != "" ? var.servicebus_name : "sb-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  queues              = var.servicebus_queues
  topics              = var.servicebus_topics
  subscriptions       = var.servicebus_subscriptions
  tags                = var.tags
}

# -------------------------------------------------------------------
# sqldb
# -------------------------------------------------------------------
module "sqldb" {
  count  = local.module_plan_enabled.sqldb ? 1 : 0
  source = "./modules/sqldb"

  server_name                = "sql-${var.workload}-${var.environment}"
  database_name              = "sqldb-${var.workload}-${var.environment}"
  max_size_gb                = 32
  admin_username             = "sqladminuser"
  admin_password             = "ChangeMe12345!"
  ad_admin_login_name        = "sql-admin-group"
  ad_admin_object_id         = var.sample_principal_object_id
  sku_name                   = "S0"
  resource_group_name        = local.resource_group_name
  app_env                    = var.environment
  workload                   = var.workload
  location                   = var.location
  private_endpoint_subnet_id = local.private_endpoint_subnet_id
  app_admin_group            = var.app_admin_group
  app_user_group             = var.app_user_group
  tags                       = var.tags
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
  app_sqlmi_db    = trimspace(var.sqlmi_db_name) != "" ? var.sqlmi_db_name : "sqlmidb-${local.name_suffix}"
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

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = trimspace(var.storageaccount_name) != "" ? var.storageaccount_name : local.storage_account_name
  blob_properties     = var.shared_storage_blob_properties
  containers          = var.storageaccount_containers
  file_shares         = var.storageaccount_file_shares
  queues              = var.storageaccount_queues
  tables              = var.storageaccount_tables
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  tags                = var.tags
}

# -------------------------------------------------------------------
# subscription_vending
# -------------------------------------------------------------------
module "subscription_vending" {
  count  = local.module_plan_enabled.subscription_vending ? 1 : 0
  source = "./modules/subscription_vending"

  subscription_name        = "sub-${local.name_suffix}"
  existing_subscription_id = local.subscription_resource_id
  management_group_id      = local.management_group_id
  tags                     = var.tags
}

# -------------------------------------------------------------------
# vnet
# -------------------------------------------------------------------
module "vnet" {
  count  = local.module_plan_enabled.vnet ? 1 : 0
  source = "./modules/vnet"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = trimspace(var.vnet_name) != "" ? var.vnet_name : local.vnet_name
  address_space       = var.vnet_address_space
  subnets             = local.vnet_subnets
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  tags                = var.tags
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
  app_vm                           = local.vm_name
  app_env                          = var.environment
  workload                         = var.workload
  azure-user                       = var.azure-user
  azure-password                   = var.azure-password
  admin_credentials_key_vault_id   = local.key_vault_id
  app_admin_group                  = var.app_admin_group
  app_user_group                   = var.app_user_group
  vm_remote_group                  = var.winvm_vm_remote_group
  vm_admin_group                   = var.winvm_vm_admin_group
  public_network_enabled           = var.winvm_public_network_enabled
  enable_domain_join               = var.winvm_enable_domain_join
  domain_join_user                 = var.winvm_domain_join_user
  domain_join_password             = var.winvm_domain_join_password
  domain_join_username_secret_name = var.winvm_domain_join_username_secret_name
  domain_join_password_secret_name = var.winvm_domain_join_password_secret_name
  enable_shir                      = var.winvm_enable_shir
  tags                             = var.tags
}
