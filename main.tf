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
    enable_management_group                = lookup(var.features, "enable_management_group", var.module_plan_enabled.managementgroups)
    enable_subscription_bootstrap          = lookup(var.features, "enable_subscription_bootstrap", var.module_plan_enabled.subscription_vending)
    enable_private_dns                     = lookup(var.features, "enable_private_dns", var.module_plan_enabled.private_dns)
    enable_adf                             = lookup(var.features, "enable_adf", var.module_plan_enabled.adf)
    enable_azure_ai_search                 = lookup(var.features, "enable_azure_ai_search", var.module_plan_enabled.azure_ai_search)
    enable_azure_ai_service                = lookup(var.features, "enable_azure_ai_service", var.module_plan_enabled.azure_ai_service)
    enable_openai                          = lookup(var.features, "enable_openai", var.module_plan_enabled.openai)
    enable_acr                             = lookup(var.features, "enable_acr", var.module_plan_enabled.acr)
    enable_app_services                    = lookup(var.features, "enable_app_services", var.module_plan_enabled.appservice || var.module_plan_enabled.appserviceplan)
    enable_app_registration_for_appservice = lookup(var.features, "enable_app_registration_for_appservice", var.module_plan_enabled.appregistration)
    enable_automation_accounts             = lookup(var.features, "enable_automation_accounts", var.module_plan_enabled.automationaccount)
    enable_automation_ari_workloads        = lookup(var.features, "enable_automation_ari_workloads", false)
    enable_linux_vm                        = lookup(var.features, "enable_linux_vm", var.module_plan_enabled.linuxvm)
    enable_aks                             = lookup(var.features, "enable_aks", var.module_plan_enabled.aks)
    enable_sqldb                           = lookup(var.features, "enable_sqldb", var.module_plan_enabled.sqldb)
  }

  module_plan_enabled = merge(var.module_plan_enabled, {
    acr                  = local.feature_flags.enable_acr
    adf                  = local.feature_flags.enable_adf
    aks                  = local.feature_flags.enable_aks
    appregistration      = contains(local.feature_keys, "enable_app_services") || contains(local.feature_keys, "enable_app_registration_for_appservice") ? local.feature_flags.enable_app_services && local.feature_flags.enable_app_registration_for_appservice : var.module_plan_enabled.appregistration
    appservice           = contains(local.feature_keys, "enable_app_services") ? local.feature_flags.enable_app_services : var.module_plan_enabled.appservice
    appserviceplan       = contains(local.feature_keys, "enable_app_services") ? local.feature_flags.enable_app_services : var.module_plan_enabled.appserviceplan
    automationaccount    = local.feature_flags.enable_automation_accounts
    azure_ai_service     = local.feature_flags.enable_azure_ai_service
    azure_ai_search      = local.feature_flags.enable_azure_ai_search
    linuxvm              = local.feature_flags.enable_linux_vm
    managementgroups     = local.feature_flags.enable_management_group
    openai               = local.feature_flags.enable_openai
    private_dns          = local.feature_flags.enable_private_dns
    sqldb                = local.feature_flags.enable_sqldb
    subscription_vending = local.feature_flags.enable_subscription_bootstrap
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
# appregistration
# -------------------------------------------------------------------
module "appregistration" {
  count  = local.module_plan_enabled.appregistration ? 1 : 0
  source = "./modules/appregistration"

  display_name = "appreg-${local.name_suffix}"
  tags         = ["terraform", "plan-harness"]
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
# applicationgateway
# -------------------------------------------------------------------
module "applicationgateway" {
  count  = local.module_plan_enabled.applicationgateway ? 1 : 0
  source = "./modules/applicationgateway"

  name                = "agw-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location
  subnet_id           = local.app_subnet_id
  backend_address_pools = {
    app = {
      ip_addresses = ["10.42.1.4"]
    }
  }
  backend_http_settings = {
    app = {
      port     = 80
      protocol = "Http"
    }
  }
  http_listeners = {
    public = {
      frontend_port_name = "http"
      protocol           = "Http"
    }
  }
  request_routing_rules = {
    public = {
      rule_type                  = "Basic"
      http_listener_name         = "public"
      backend_address_pool_name  = "app"
      backend_http_settings_name = "app"
      priority                   = 100
    }
  }
  app_env  = var.environment
  workload = var.workload
  tags     = var.tags
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
# cosmosdb
# -------------------------------------------------------------------
module "cosmosdb" {
  count  = local.module_plan_enabled.cosmosdb ? 1 : 0
  source = "./modules/cosmosdb"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = "cosmos-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  sql_databases = {
    app = {
      autoscale_max_ru = 4000
    }
  }
  sql_containers = {
    items = {
      database_name       = "app"
      partition_key_paths = ["/tenantId"]
      autoscale_max_ru    = 4000
    }
  }
  tags = var.tags
}

# -------------------------------------------------------------------
# databricks
# -------------------------------------------------------------------
module "databricks" {
  count  = local.module_plan_enabled.databricks ? 1 : 0
  source = "./modules/databricks"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = "dbw-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  tags                = var.tags
}

# -------------------------------------------------------------------
# eventhub
# -------------------------------------------------------------------
module "eventhub" {
  count  = local.module_plan_enabled.eventhub ? 1 : 0
  source = "./modules/eventhub"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = "evh-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
  eventhubs = {
    telemetry = {
      partition_count   = 2
      message_retention = 1
    }
  }
  tags = var.tags
}

# -------------------------------------------------------------------
# firewall
# -------------------------------------------------------------------
module "firewall" {
  count  = local.module_plan_enabled.firewall ? 1 : 0
  source = "./modules/firewall"

  name                = "afw-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location
  subnet_id           = local.firewall_subnet_id
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
  name                                = "func-${local.name_suffix}"
  location                            = var.location
  service_plan_id                     = local.module_plan_enabled.appserviceplan ? module.appserviceplan[0].id : local.app_service_plan_id
  storage_account_name                = local.module_plan_enabled.storageaccount ? module.storageaccount[0].name : local.storage_account_name
  storage_account_resource_group_name = local.module_plan_enabled.storageaccount ? module.storageaccount[0].resource_group_name : local.resource_group_name
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
  name                = local.key_vault_name
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

  name                = local.log_analytics_name
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
  name                                = "logic-${local.name_suffix}"
  location                            = var.location
  service_plan_id                     = local.module_plan_enabled.appserviceplan ? module.appserviceplan[0].id : local.app_service_plan_id
  storage_account_name                = local.module_plan_enabled.storageaccount ? module.storageaccount[0].name : local.storage_account_name
  storage_account_resource_group_name = local.module_plan_enabled.storageaccount ? module.storageaccount[0].resource_group_name : local.resource_group_name
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

  name                = "id-${local.name_suffix}"
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

  name                = "nsg-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location
  app_env             = var.environment
  workload            = var.workload
  tags                = var.tags
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

  name                = "allowed-location-${var.environment}"
  display_name        = "Allowed Location ${upper(var.environment)}"
  management_group_id = local.management_group_id
  policy_rule         = local.sample_policy_rule
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

  name            = local.resource_group_name
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

  assignments = local.sample_role_assignments
}

# -------------------------------------------------------------------
# route_table
# -------------------------------------------------------------------
module "route_table" {
  count  = local.module_plan_enabled.route_table ? 1 : 0
  source = "./modules/route_table"

  name                = "rt-${local.name_suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location
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
  name                = "sb-${local.name_suffix}"
  app_env             = var.environment
  workload            = var.workload
  app_admin_group     = var.app_admin_group
  app_user_group      = var.app_user_group
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

  name                         = "sqlmi-${local.name_suffix}"
  resource_group_name          = local.resource_group_name
  subnet_id                    = local.module_plan_enabled.vnet ? module.vnet[0].subnet_ids[local.app_subnet_name] : local.app_subnet_id
  administrator_login          = "sqladminuser"
  administrator_login_password = "ChangeMeSqlMi12345!"
  sku_name                     = "GP_Gen5"
  vcores                       = 4
  storage_size_in_gb           = 64
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
  app_sqlmi_db    = "sqlmidb-${local.name_suffix}"
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
  name                = local.storage_account_name
  blob_properties     = var.shared_storage_blob_properties
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
  name                = local.vnet_name
  address_space       = ["10.42.0.0/16"]
  subnets = {
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
  app_env         = var.environment
  workload        = var.workload
  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = var.tags
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
  vm_remote_group                  = null
  vm_admin_group                   = null
  public_network_enabled           = false
  enable_domain_join               = var.winvm_enable_domain_join
  domain_join_user                 = var.winvm_domain_join_user
  domain_join_password             = var.winvm_domain_join_password
  domain_join_username_secret_name = var.winvm_domain_join_username_secret_name
  domain_join_password_secret_name = var.winvm_domain_join_password_secret_name
  enable_shir                      = false
  tags                             = var.tags
}
