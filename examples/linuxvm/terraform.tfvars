########################################
## this is for dev environment
########################################
# could be dev/qa/pod/sbx/prod
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Shared Root Inputs
# The values below are shared across multiple module blocks in main.tf.
# -------------------------------------------------------------------

# no more than 8 characters since it will be used as part of generated resource names.
# VM name pattern: <azuwa><workload><suffix>, where suffix is a 3-digit number.
workload = "grafana"
#environment = "dev"

# -------------------------------------------------------------------
# End of Shared Root Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Azure Container Registry Module Inputs
# The values below feed module "acr_basic" in main.tf.
# -------------------------------------------------------------------
acr_resource_group_name = "rg-ba-cc-prd-shared-management"
acr_location            = "canadacentral"
acr_name                = "acriactestprod001"

acr_sku                             = "Premium"
acr_admin_enabled                   = false
acr_public_network_access_enabled   = false
acr_anonymous_pull_enabled          = false
acr_data_endpoint_enabled           = false
acr_system_managed_identity_enabled = false

# Optional ACR RBAC groups.
# Leave as [] to skip group-based role assignments.
# If a display name is duplicated in Entra ID, use the group's object ID instead.
acr_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
acr_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

# Premium SKU ACR network rules.
acr_enable_network_rule_set     = false
acr_network_rule_bypass_option  = "AzureServices"
acr_network_rule_default_action = "Deny"
acr_network_rule_ip_rules       = []

acr_enable_private_endpoint                      = false
acr_private_endpoint_subnet_id                   = ""
acr_private_endpoint_subnet_name                 = ""
acr_private_endpoint_vnet_name                   = ""
acr_private_endpoint_network_resource_group_name = ""
acr_private_dns_zone_id                          = ""
acr_private_dns_zone_name                        = ""
acr_private_dns_zone_resource_group_name         = ""

acr_enable_diagnostics = false
# Optional override: leave commented to use data.azurerm_log_analytics_workspace.this.id.
# acr_log_analytics_workspace_id   = "<log-analytics-workspace-resource-id>"
acr_diagnostic_log_categories    = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]
acr_diagnostic_metric_categories = ["AllMetrics"]

acr_tags = {
  "Environment" = "Production"
  "Owner"       = "CCOE"
  "IaC"         = "Terraform"
}

# -------------------------------------------------------------------
# End of Azure Container Registry Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Azure Data Factory Module Inputs
# The values below feed module "adf_basic" in main.tf.
# -------------------------------------------------------------------
## for ADF
# self_hosted_integration_runtime_enabled = true
# vsts_configuration = {
#   account_name         = "CCOE-Azure"
#   project_name         = "CCoE-Infra-IaC"
#   repository_name      = "adf-lab-deploy-repo"
#   branch_name          = "adf_publish"
#   root_folder          = "/"
#   tenant_id            = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
#   collaboration_branch = "main"
# }
# ADF resource RBAC:
adf_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
adf_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
# -------------------------------------------------------------------
# End of Azure Data Factory Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# AKS Module Inputs
# The values below feed module "aks_basic" in main.tf.
# -------------------------------------------------------------------
# Optional override: leave commented to use app_rg and that resource group's location.
# aks_resource_group_name = "rg-ba-cc-prd-shared-management"
# aks_location            = "canadacentral"
# Optional override: leave commented to let the module auto-generate the cluster name and DNS prefix.
# aks_name       = "aks-iactest-prod-001"
# aks_dns_prefix = "aks-iactest-prod-001"

aks_kubernetes_version        = null
aks_sku_tier                  = "Free"
aks_automatic_upgrade_channel = "patch"

aks_private_cluster_enabled              = true
aks_private_dns_zone_id                  = ""
aks_private_dns_zone_name                = ""
aks_private_dns_zone_resource_group_name = ""

aks_role_based_access_control_enabled = true
aks_azure_rbac_enabled                = true
aks_local_account_disabled            = true
aks_oidc_issuer_enabled               = true
aks_workload_identity_enabled         = true

aks_app_admin_group = []
aks_app_user_group  = []

aks_default_node_pool = {
  name = "system"
  #vm_size             = "Standard_D4s_v5"
  vm_size             = "Standard_B2ms"
  node_count          = 1
  enable_auto_scaling = false
  zones               = []
  os_disk_size_gb     = 128
  os_sku              = "Ubuntu"
  type                = "VirtualMachineScaleSets"
  vnet_subnet_id      = ""
}

aks_network_profile = {
  network_plugin    = "azure"
  load_balancer_sku = "standard"
  outbound_type     = "loadBalancer"
}

aks_enable_diagnostics = false
# Optional override: leave commented to use data.azurerm_log_analytics_workspace.this.id.
# aks_log_analytics_workspace_id   = "<log-analytics-workspace-resource-id>"
aks_diagnostic_log_categories    = []
aks_diagnostic_metric_categories = ["AllMetrics"]

aks_tags = {
  "Environment" = "Production"
  "Owner"       = "CCOE"
  "IaC"         = "Terraform"
}

# -------------------------------------------------------------------
# End of AKS Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# App Registration Module Inputs
# The values below feed module "app_registration" in main.tf.
# -------------------------------------------------------------------
enable_app_registration_for_appservice = true
app_registration_create_client_secret  = true
# -------------------------------------------------------------------
# End of App Registration Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# App Service Module Inputs
# The values below feed module "app_service" in main.tf.
# -------------------------------------------------------------------
# App Service auth/runtime options (from app-service-demo-python)
app_service_auth_mode              = "both"
app_service_allow_anonymous        = true
app_service_unauthenticated_action = "AllowAnonymous"
appservice_stack                   = "python"
app_service_app_admin_group        = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
app_service_app_user_group         = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
app_service_app_settings = {
  "MY_SETTING"      = "value"
  "ANOTHER_SETTING" = "value"
}
# -------------------------------------------------------------------
# End of App Service Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# App Service Plan Module Inputs
# The values below feed module "app_service_plan" in main.tf.
# -------------------------------------------------------------------
# Available os_type values: "Linux" or "Windows".
function_app_os_type                      = "Windows"
function_app_service_plan_sku_name        = "B1"
function_app_service_plan_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
function_app_service_plan_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
# -------------------------------------------------------------------
# End of App Service Plan Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Automation Account Module Inputs
# The values below feed module "automation_account" in main.tf.
# -------------------------------------------------------------------
# Automation Account connectivity model.
automation_account_public_access_enabled = true
enable_webhook_private_endpoint          = false
enable_hrw_private_endpoint              = false
automation_account_app_admin_group       = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
automation_account_app_user_group        = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
# Optional override. Leave commented to let Terraform default it to 24 hours from apply time.
# ari_schedule_start_time = "2026-03-22T08:00:00-04:00"
# ARI runbook output settings.
ari_container_name = "ari"
ari_report_name    = "2JOINUS_AZURE"
# Existing Windows VM used for the Hybrid Runbook Worker.
hybrid_worker_vm_name           = "azuwiccoejmp001"
hybrid_worker_vm_resource_group = "rg-ba-cc-prd-shared-management"
# Optional extension settings shown here for completeness.
# hybrid_worker_extension_name                 = "HybridWorkerExtension"
# hybrid_worker_extension_type_handler_version = "1.1"
# -------------------------------------------------------------------
# End of Automation Account Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Azure AI Service Module Inputs
# The values below feed module "azure_ai_service_basic" in main.tf.
# -------------------------------------------------------------------
# Optional overrides: leave commented to use app_rg and that resource group's location.
# azure_ai_service_resource_group_name = "rg-ba-cc-prd-shared-management"
# azure_ai_service_location            = "canadacentral"
# Optional override: leave commented to let the module generate an account name.
# azure_ai_service_name = "ais-iactest-prod-001"
azure_ai_service_sku_name                           = "S0"
azure_ai_service_custom_subdomain_name              = ""
azure_ai_service_public_network_access_enabled      = true
azure_ai_service_outbound_network_access_restricted = false
azure_ai_service_local_auth_enabled                 = true
azure_ai_service_dynamic_throttling_enabled         = false
azure_ai_service_fqdns                              = []
azure_ai_service_project_management_enabled         = false
azure_ai_service_identity                           = null
azure_ai_service_customer_managed_key               = null
azure_ai_service_storage                            = []
azure_ai_service_network_acls                       = null

azure_ai_service_enable_private_endpoint                      = false
azure_ai_service_private_endpoint_subnet_id                   = ""
azure_ai_service_private_endpoint_subnet_name                 = ""
azure_ai_service_private_endpoint_vnet_name                   = ""
azure_ai_service_private_endpoint_network_resource_group_name = ""
azure_ai_service_private_dns_zone_id                          = ""

azure_ai_service_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
azure_ai_service_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

azure_ai_service_enable_diagnostics           = false
azure_ai_service_log_analytics_workspace_id   = ""
azure_ai_service_diagnostic_log_categories    = []
azure_ai_service_diagnostic_metric_categories = ["AllMetrics"]

azure_ai_service_tags = {
  "resourceType" = "AzureAIService"
}
# -------------------------------------------------------------------
# End of Azure AI Service Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Databricks Module Inputs
# The values below feed module "databricks_basic" in main.tf.
# -------------------------------------------------------------------
# Optional overrides: leave commented to use app_rg and that resource group's location.
# databricks_resource_group_name = "rg-ba-cc-prd-shared-management"
# databricks_location            = "canadacentral"
# Optional override: leave commented to let the module generate a workspace name.
# databricks_name = "dbw-iactest-prod-001"
databricks_sku                                                 = "premium"
databricks_managed_resource_group_name                         = ""
databricks_public_network_access_enabled                       = true
databricks_network_security_group_rules_required               = "AllRules"
databricks_customer_managed_key_enabled                        = false
databricks_infrastructure_encryption_enabled                   = false
databricks_default_storage_firewall_enabled                    = false
databricks_access_connector_id                                 = ""
databricks_load_balancer_backend_address_pool_id               = ""
databricks_managed_disk_cmk_key_vault_id                       = ""
databricks_managed_disk_cmk_key_vault_key_id                   = ""
databricks_managed_disk_cmk_rotation_to_latest_version_enabled = false
databricks_managed_services_cmk_key_vault_id                   = ""
databricks_managed_services_cmk_key_vault_key_id               = ""

databricks_custom_parameters            = null
databricks_enhanced_security_compliance = null
databricks_app_admin_group              = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
databricks_app_user_group               = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

databricks_enable_diagnostics           = false
databricks_log_analytics_workspace_id   = ""
databricks_diagnostic_log_categories    = []
databricks_diagnostic_metric_categories = ["AllMetrics"]

databricks_tags = {
  "resourceType" = "Databricks"
}
# -------------------------------------------------------------------
# End of Databricks Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Event Hub Module Inputs
# The values below feed module "eventhub_basic" in main.tf.
# -------------------------------------------------------------------
# Optional overrides: leave commented to use app_rg and that resource group's location.
# eventhub_resource_group_name = "rg-ba-cc-prd-shared-management"
# eventhub_location            = "canadacentral"
# Optional override: leave commented to let the module generate a namespace name.
# eventhub_name = "evh-iactest-prod-001"
eventhub_sku                             = "Standard"
eventhub_capacity                        = 1
eventhub_auto_inflate_enabled            = false
eventhub_maximum_throughput_units        = 0
eventhub_local_authentication_enabled    = true
eventhub_public_network_access_enabled   = true
eventhub_minimum_tls_version             = "1.2"
eventhub_system_managed_identity_enabled = false

eventhub_eventhubs = {
  telemetry = {
    partition_count   = 2
    message_retention = 1
    status            = "Active"
  }
}

eventhub_authorization_rules = {
  sender = {
    listen = false
    send   = true
    manage = false
  }
}

eventhub_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
eventhub_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

eventhub_enable_private_endpoint                      = false
eventhub_private_endpoint_subnet_id                   = ""
eventhub_private_endpoint_subnet_name                 = ""
eventhub_private_endpoint_vnet_name                   = ""
eventhub_private_endpoint_network_resource_group_name = ""
eventhub_private_dns_zone_id                          = ""

eventhub_enable_diagnostics           = false
eventhub_log_analytics_workspace_id   = ""
eventhub_diagnostic_log_categories    = ["ArchiveLogs", "OperationalLogs"]
eventhub_diagnostic_metric_categories = ["AllMetrics"]

eventhub_tags = {
  "resourceType" = "EventHub"
}
# -------------------------------------------------------------------
# End of Event Hub Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Firewall Module Inputs
# The values below feed module "firewall_basic" in main.tf.
# -------------------------------------------------------------------
# Optional overrides: leave commented to use app_rg and that resource group's location.
# firewall_resource_group_name = "rg-ba-cc-prd-shared-management"
# firewall_location            = "canadacentral"
firewall_name      = "afw-iactest-prod-001"
firewall_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<network-rg>/providers/Microsoft.Network/virtualNetworks/<hub-vnet>/subnets/AzureFirewallSubnet"

firewall_sku_tier       = "Standard"
firewall_sku_name       = "AZFW_VNet"
firewall_zones          = []
firewall_public_ip_name = ""
firewall_policy_name    = ""

firewall_application_rule_collections = {}
firewall_network_rule_collections     = {}
firewall_nat_rule_collections         = {}

firewall_tags = {
  "resourceType" = "Firewall"
}
# -------------------------------------------------------------------
# End of Firewall Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Function App Module Inputs
# The values below feed module "function_app_basic" in main.tf.
# -------------------------------------------------------------------
# Optional override: leave commented to use app_rg and that resource group's location.
# function_app_resource_group_name = "rg-ba-cc-prd-shared-management"
# function_app_location            = "canadacentral"
# Optional override: leave commented to use func-${workload}-${app_env}-${suffix}.
# function_app_name = "func-iactest-prod-001"
# Optional override: leave commented to use the iac storage account and iac resource group.
# function_app_storage_account_name                = "stiactestprod001"
# function_app_storage_account_resource_group_name = "rg-ba-cc-prd-shared-management"

function_app_storage_uses_managed_identity = false
function_app_functions_extension_version   = "~4"
function_app_builtin_logging_enabled       = false
function_app_https_only                    = true
function_app_public_network_access_enabled = false

function_app_app_settings = {
  "FUNCTIONS_WORKER_RUNTIME" = "python"
  "WEBSITE_RUN_FROM_PACKAGE" = "1"
}

function_app_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
function_app_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

function_app_connection_strings = []

# application_stack must match function_app_os_type.
# Linux examples:
# function_app_application_stack = { python_version = "3.11" }
# function_app_application_stack = { node_version = "20" }
# function_app_application_stack = { dotnet_version = "8.0" }
# function_app_application_stack = { powershell_core_version = "7.4" }
# function_app_application_stack = { use_custom_runtime = true }
# Windows examples:
# function_app_application_stack = { dotnet_version = "v8.0" }
# function_app_application_stack = { node_version = "20" }
# function_app_application_stack = { java_version = "17" }
# function_app_application_stack = { powershell_core_version = "7.4" }
# function_app_application_stack = { use_custom_runtime = true }
function_app_application_stack = {
  #python_version = "3.11"
  dotnet_version = "v8.0"
}

function_app_system_assigned_identity_enabled = true
function_app_identity_ids                     = []
function_app_key_vault_reference_identity_id  = null

function_app_virtual_network_subnet_id                    = ""
function_app_vnet_integration_subnet_name                 = ""
function_app_vnet_integration_vnet_name                   = ""
function_app_vnet_integration_network_resource_group_name = ""
function_app_vnet_route_all_enabled                       = false

function_app_always_on                               = true
function_app_ftps_state                              = "Disabled"
function_app_http2_enabled                           = true
function_app_minimum_tls_version                     = "1.2"
function_app_use_32_bit_worker                       = false
function_app_health_check_path                       = null
function_app_health_check_eviction_time_in_min       = null
function_app_runtime_scale_monitoring_enabled        = false
function_app_daily_memory_time_quota                 = null
function_app_zip_deploy_file                         = null
function_app_sticky_settings_app_setting_names       = []
function_app_sticky_settings_connection_string_names = []

function_app_enable_private_endpoint                      = false
function_app_private_endpoint_subnet_id                   = ""
function_app_private_endpoint_subnet_name                 = ""
function_app_private_endpoint_vnet_name                   = ""
function_app_private_endpoint_network_resource_group_name = ""
function_app_private_dns_zone_id                          = ""
function_app_private_dns_zone_name                        = ""
function_app_private_dns_zone_resource_group_name         = ""

function_app_enable_diagnostics = false
# Optional override: leave commented to use data.azurerm_log_analytics_workspace.this.id.
# function_app_log_analytics_workspace_id   = "<log-analytics-workspace-resource-id>"
function_app_diagnostic_log_categories    = ["AppServiceHTTPLogs", "AppServiceConsoleLogs", "AppServiceAppLogs", "AppServiceAuditLogs", "AppServiceIPSecAuditLogs", "AppServicePlatformLogs"]
function_app_diagnostic_metric_categories = ["AllMetrics"]

function_app_tags = {
  "Environment" = "Production"
  "Owner"       = "CCOE"
  "IaC"         = "Terraform"
}

# -------------------------------------------------------------------
# End of Function App Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Key Vault Module Inputs
# The values below feed module "key_vault_basic" in main.tf.
# -------------------------------------------------------------------
key_vault_resource_group_name = "rg-ba-cc-prd-shared-management"
key_vault_location            = "canadacentral"
key_vault_tenant_id           = ""
key_vault_name                = "kviactestprod001"

key_vault_sku_name                        = "standard"
key_vault_enable_rbac_authorization       = true
key_vault_public_network_access_enabled   = false
key_vault_purge_protection_enabled        = false
key_vault_soft_delete_retention_days      = 90
key_vault_enabled_for_deployment          = false
key_vault_enabled_for_disk_encryption     = false
key_vault_enabled_for_template_deployment = false

# Optional key-vault RBAC groups.
# Leave as [] to skip group-based role assignments.
key_vault_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
key_vault_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

key_vault_enable_network_acls                     = false
key_vault_network_acls_default_action             = "Deny"
key_vault_network_acls_bypass                     = "AzureServices"
key_vault_network_acls_ip_rules                   = []
key_vault_network_acls_virtual_network_subnet_ids = []

key_vault_enable_private_endpoint                      = false
key_vault_private_endpoint_subnet_id                   = ""
key_vault_private_endpoint_subnet_name                 = null
key_vault_private_endpoint_vnet_name                   = null
key_vault_private_endpoint_network_resource_group_name = null
key_vault_private_dns_zone_id                          = ""
key_vault_private_dns_zone_name                        = ""
key_vault_private_dns_zone_resource_group_name         = ""

key_vault_enable_diagnostics = false
# Optional override: leave commented to use data.azurerm_log_analytics_workspace.this.id.
# key_vault_log_analytics_workspace_id   = "<log-analytics-workspace-resource-id>"
key_vault_diagnostic_log_categories    = ["AuditEvent"]
key_vault_diagnostic_metric_categories = ["AllMetrics"]

key_vault_tags = {
  "Environment" = "Production"
  "Owner"       = "CCOE"
  "IaC"         = "Terraform"
}

# -------------------------------------------------------------------
# End of Key Vault Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Linux VM Module Inputs
# The values below feed module "linux_vm_basic" in main.tf.
# -------------------------------------------------------------------
linux_vm_common_tags = {
  "Application Name"                  = "CCOE INFRA IAC"
  "Application Owner"                 = "CCOE"
  "AppSupport Team"                   = "CCOE"
  "Approval Group"                    = "CCOE"
  "Business Owner"                    = "CCOE"
  "Environment"                       = "Prod"
  "Infra Availability Classification" = "Bronze"
  "InfraSupport Team"                 = "CCOE"
  "Maintenance Window"                = "CCOE"
  "Project Name"                      = "CCOE INFRA IAC"
  "Project Number"                    = "N/A"
  "RPO-RTO"                           = "48H/24H"
  "Run Cost(Approved Run Budget)-USD" = "100"
}

# To refresh linux_vm_rg_tags from the existing resource group in Azure, run:
# $rgName="rg-ba-cc-prd-shared-management"; $tags=az group show --name $rgName --query tags -o json | ConvertFrom-Json; $keys=$tags.PSObject.Properties.Name | Sort-Object; $maxLen=($keys | % { $_.Length } | measure -Maximum).Maximum; "linux_vm_rg_tags = {"; foreach($key in $keys){$padding=" " * ($maxLen-$key.Length); $value=[string]$tags.$key; '  "{0}"{1} = "{2}"' -f $key,$padding,$value}; "}"
linux_vm_rg_tags = {
  "Application Name"                  = "BIS Shared Management - Logs&Monitoring"
  "Application Owner"                 = "CCOE"
  "Approval Group"                    = "BA-APPR-Cloud-Architects Group"
  "AppSupport Team"                   = "2join.us"
  "Business Owner"                    = "Jean-Olivier LeBrun"
  "Environment"                       = "PROD"
  "Infra Availability Classification" = "Gold"
  "InfraSupport Team"                 = "TCS"
  "Maintenance Window"                = "CCOE"
  "Project Name"                      = "Azure Foundation"
  "Project Number"                    = "60505-B"
  "Project Status"                    = "Operations"
  "RPO-RTO"                           = "0h/4h"
  "Run Cost(Approved Run Budget)-USD" = "5000"
  "Project Status"                    = "Operations"
  "workload"                          = "grafana"
  "IaC"                               = "Terraform"
  "Requested By"                      = "JO"
  "Provisioned By"                    = "admin@2join.us"
  "Technical contact"                 = "admin@2join.us"
  "Business contact"                  = "admin@2join.us"
  "ADO Project"                       = "CCoE-Infra-IaC"
  "ADO Repo"                          = "linuxvm-bis-observability-prod"
  "ADO Link"                          = "https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/linuxvm-bis-observability-prod"
}

linux_vm_location = "canadacentral"
linux_vm_app_env  = "prod"
linux_vm_workload = "grafana"

# Password override usage:
# - Leave linux_vm_azure_password = "" to use the azure-password secret from linux_vm_iac_kv.
# - Set a non-empty value only when you intentionally need to override the Key Vault secret at deploy time.
linux_vm_azure_password = ""
# Post-init customization usage:
# - Leave linux_vm_post_init_script = "" to run only the module's built-in init.sh bootstrap.
# - Or load it from a checked-in shell script under scripts/.

linux_vm_datadog_api_key = "sample_api_key"

linux_vm_disksize = 100
#linux_vm_app_vm_number          = 1
# Common VM sizes for linux_vm_app_vm_size:
# Pricing below is Linux pay-as-you-go in Canada Central as of 2026-03-22.
# Monthly price is an estimate based on 730 hours and excludes disks, networking, backup, tax, and discounts.
# Smaller dev/test VM sizes:
# Standard_B1ls    = 1 vCPU, 0.5 GiB RAM, 4.23 USD/month
# Standard_B1s     = 1 vCPU, 1 GiB RAM, 8.47 USD/month
# Standard_B1ms    = 1 vCPU, 2 GiB RAM, 16.79 USD/month
# Standard_B2as_v2 = 2 vCPU, 4 GiB RAM, 61.03 USD/month
# Standard_B2s     = 2 vCPU, 4 GiB RAM, 33.87 USD/month
# Standard_B2ms    = 2 vCPU, 8 GiB RAM, 67.74 USD/month
# General-purpose VM sizes:
# Standard_D2s_v3  = 2 vCPU, 8 GiB RAM, 81.03 USD/month
# Standard_D4s_v3  = 4 vCPU, 16 GiB RAM, 162.06 USD/month
# Standard_D8s_v3  = 8 vCPU, 32 GiB RAM, 324.12 USD/month
# Standard_D2s_v5  = 2 vCPU, 8 GiB RAM, 78.11 USD/month
# Standard_D4s_v5  = 4 vCPU, 16 GiB RAM, 156.22 USD/month
# Standard_D8s_v5  = 8 vCPU, 32 GiB RAM, 312.44 USD/month
# Memory-optimized VM sizes:
# Standard_E2s_v3  = 2 vCPU, 16 GiB RAM, 106.58 USD/month
# Standard_E4s_v3  = 4 vCPU, 32 GiB RAM, 213.16 USD/month
# Standard_E8s_v3  = 8 vCPU, 64 GiB RAM, 426.32 USD/month
# Standard_E2s_v5  = 2 vCPU, 16 GiB RAM, 100.74 USD/month
# Standard_E4s_v5  = 4 vCPU, 32 GiB RAM, 201.48 USD/month
# Standard_E8s_v5  = 8 vCPU, 64 GiB RAM, 402.96 USD/month
# Example:
# linux_vm_app_vm_size = "Standard_D4s_v3"
linux_vm_app_vm_size            = "Standard_B2s"
linux_vm_enable_entra_ssh_login = true
# Localization extension behavior:
# - Leave linux_vm_enable_linux_vm_extension = false to rely only on custom_data/init.sh and optional post-init content.
# - Set it to true only when you want the VM to download and run localization scripts from the shared IaC storage account.
# - linux_vm_enable_system_assigned_identity must stay true when the localization extension is enabled so the VM can read from storage.
linux_vm_enable_linux_vm_extension       = true
linux_vm_enable_system_assigned_identity = true
linux_vm_localization_container_name     = "localization"
#linux_vm_localization_os_script_name     = "ubuntu.sh"
# Domain join behavior:
# - Leave linux_vm_enable_domain_join = false to keep the Linux VM off domain and skip the domain-join secret lookup.
# - Set it to true only when you want init.sh to attempt AD join during bootstrap.
linux_vm_enable_domain_join = false

# Popular values for linux_vm_image_offer:
# Canonical:
# linux_vm_image_offer = "ubuntu-24_04-lts"
# linux_vm_image_offer = "ubuntu-22_04-lts"
# linux_vm_image_offer = "0001-com-ubuntu-server-jammy"
# Red Hat:
# linux_vm_image_offer = "RHEL"
# linux_vm_image_offer = "RHEL-SAP"
# SUSE:
# linux_vm_image_offer = "sles-15-sp5"
# Debian:
# linux_vm_image_offer = "debian-12"
# Oracle:
# linux_vm_image_offer = "oracle-linux"
# Make sure linux_vm_image_publisher, linux_vm_image_offer, linux_vm_image_sku, and linux_vm_image_version match the same image family.
linux_vm_image_publisher = "Canonical"
linux_vm_image_offer     = "ubuntu-24_04-lts"
linux_vm_image_sku       = "server"
linux_vm_image_version   = "latest"

linux_vm_iac_rg = "rg-ccoe-iac-cc-prod"
linux_vm_iac_kv = "kv-ccoe-cc-prod"
linux_vm_iac_st = "stccoeiacprod"

linux_vm_app_rg      = "rg-ba-cc-prd-shared-management"
linux_vm_app_snet    = "snet-ba-cc-prod-hub-sysmgmt"
linux_vm_app_vnet_rg = "rg-ba-cc-prod-hub-network"
linux_vm_app_vnet    = "vnet-ba-cc-prod-hub"
linux_vm_app_vm      = "azuligrafana"

linux_vm_domain           = "2join.us"
linux_vm_domain_join_user = "AERO\\\\b1001332a1"
linux_vm_domain_join_ou   = "azure"

# Linux access groups:
# - linux_vm_app_user_group is the preferred input for SSH access groups and gets Reader on each VM resource.
# - linux_vm_app_admin_group is the preferred input for sudo/admin access groups and gets Contributor on each VM resource.
# - when Bastion is configured, both groups also get Network Contributor on that Bastion host.
# linux_vm_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "c4f6e953-7e5d-45fc-8092-4a48a59069d5"]
# linux_vm_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
linux_vm_app_user_group              = ["Entuity_Admin"]
linux_vm_app_admin_group             = ["Entuity_Admin", "BA-G-Azure-Owner-F"]
linux_vm_bastion_resource_name       = "bas-net-cc-prd"
linux_vm_bastion_resource_group_name = "rg-ba-cc-prod-hub-network"


linux_vm_public_network_enabled = false

# -------------------------------------------------------------------
# End of Linux VM Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Log Analytics Module Inputs
# The values below feed module "log_analytics_workspace_basic" in main.tf.
# -------------------------------------------------------------------
# Optional overrides: leave commented to use app_rg and that resource group's location.
# loganalytics_resource_group_name = "rg-ba-cc-prd-shared-management"
# loganalytics_location            = "canadacentral"
loganalytics_name = "law-iactest-prod-001"

loganalytics_sku                                = "PerGB2018"
loganalytics_retention_in_days                  = 30
loganalytics_daily_quota_gb                     = -1
loganalytics_internet_ingestion_enabled         = true
loganalytics_internet_query_enabled             = true
loganalytics_local_authentication_disabled      = false
loganalytics_reservation_capacity_in_gb_per_day = null

loganalytics_tags = {
  "resourceType" = "LogAnalytics"
}
# -------------------------------------------------------------------
# End of Log Analytics Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Managed Identity Module Inputs
# The values below feed module "managed_identity" in main.tf.
# -------------------------------------------------------------------
# Optional override: leave commented to use app_rg and that resource group's location.
# managed_identity_resource_group_name = "rg-ba-cc-prd-shared-management"
# managed_identity_location            = "canadacentral"
managed_identity_name = "id-iactest-prod-001"

# Optional workload identity federation examples:
# managed_identity_federated_identity_credentials = {
#   github_main = {
#     audience = ["api://AzureADTokenExchange"]
#     issuer   = "https://token.actions.githubusercontent.com"
#     subject  = "repo:contoso/platform:ref:refs/heads/main"
#   }
# }
managed_identity_federated_identity_credentials = {}

# Optional RBAC examples:
# managed_identity_role_assignments = {
#   kv_secrets_user = {
#     scope                = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<kv-name>"
#     role_definition_name = "Key Vault Secrets User"
#   }
# }
managed_identity_role_assignments = {}

managed_identity_tags = {
  "Environment" = "Production"
  "Owner"       = "CCOE"
  "IaC"         = "Terraform"
}

# -------------------------------------------------------------------
# End of Managed Identity Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Management Groups Module Inputs
# The values below feed module "management_groups" in main.tf.
# -------------------------------------------------------------------
# Optional override: leave empty to let the module generate an ID from the display name.
management_group_name = "plz-terraform-plan"

management_group_display_name = "Platform Landing Zone"

# Optional parent management group resource ID:
# management_group_parent_management_group_id = "/providers/Microsoft.Management/managementGroups/<parent-management-group-id>"
management_group_parent_management_group_id = ""

# Optional subscription placement:
# management_group_subscription_ids = [
#   "<subscription-guid-1>",
#   "<subscription-guid-2>"
# ]
management_group_subscription_ids = []

management_group_tags = {
  "Environment" = "Production"
  "Owner"       = "CCOE"
  "IaC"         = "Terraform"
}

# -------------------------------------------------------------------
# End of Management Groups Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# NSG Module Inputs
# The values below feed module "network_security_group" in main.tf.
# -------------------------------------------------------------------
# Optional override: leave commented to use app_rg and that resource group's location.
# nsg_resource_group_name = "rg-ba-cc-prd-shared-management"
# nsg_location            = "canadacentral"
nsg_name = "nsg-iactest-prod-001"

nsg_security_rules = {
  allow_https_in = {
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTPS inbound."
  }
}

# Optional associations:
# nsg_subnet_ids = [
#   "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
# ]
nsg_subnet_ids = []

# nsg_network_interface_ids = [
#   "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/networkInterfaces/<nic-name>"
# ]
nsg_network_interface_ids = []

nsg_tags = {
  "Environment" = "Production"
  "Owner"       = "CCOE"
  "IaC"         = "Terraform"
}

# -------------------------------------------------------------------
# End of NSG Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# OpenAI Module Inputs
# The values below feed module "openai_basic" in main.tf.
# -------------------------------------------------------------------
# Optional overrides: leave commented to use app_rg and that resource group's location.
# openai_resource_group_name = "rg-ba-cc-prd-shared-management"
# openai_location            = "canadacentral"
# Optional override: leave commented to let the module generate an account name.
# openai_name = "oai-iactest-prod-001"
openai_sku_name                                     = "S0"
openai_custom_subdomain_name                        = ""
openai_public_network_access_enabled                = true
openai_outbound_network_access_restricted           = false
openai_local_auth_enabled                           = true
openai_dynamic_throttling_enabled                   = false
openai_custom_question_answering_search_service_id  = ""
openai_custom_question_answering_search_service_key = ""
openai_identity                                     = null
openai_customer_managed_key                         = null
openai_network_acls                                 = null
openai_deployments                                  = {}

openai_enable_private_endpoint                      = false
openai_private_endpoint_subnet_id                   = ""
openai_private_endpoint_subnet_name                 = ""
openai_private_endpoint_vnet_name                   = ""
openai_private_endpoint_network_resource_group_name = ""
openai_private_dns_zone_id                          = ""

openai_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
openai_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

openai_enable_diagnostics           = false
openai_log_analytics_workspace_id   = ""
openai_diagnostic_log_categories    = []
openai_diagnostic_metric_categories = ["AllMetrics"]

openai_tags = {
  "resourceType" = "OpenAI"
}
# -------------------------------------------------------------------
# End of OpenAI Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Policy Module Inputs
# The values below feed module "policy_definition" in main.tf.
# -------------------------------------------------------------------
policy_name         = "require-tag-owner"
policy_display_name = "Require Owner Tag"
policy_description  = ""

# Optional definition scope:
# policy_management_group_id = "/providers/Microsoft.Management/managementGroups/<management-group-id>"
policy_management_group_id = ""

policy_rule = "{\"if\":{\"field\":\"tags['Owner']\",\"exists\":\"false\"},\"then\":{\"effect\":\"audit\"}}"

policy_parameters = "{}"
policy_metadata   = "{\"category\":\"Tags\"}"
policy_type       = "Custom"
policy_mode       = "All"

policy_create_assignment = false

# Optional assignment examples:
# policy_assignment_scope        = "/providers/Microsoft.Management/managementGroups/<management-group-id>"
# policy_assignment_display_name = "Require Owner Tag Assignment"
# policy_assignment_description  = "Assign the Require Owner Tag policy."
# policy_assignment_parameters   = "{}"
# policy_location               = "canadacentral"
# policy_identity_type          = "SystemAssigned"
policy_assignment_scope        = ""
policy_assignment_display_name = ""
policy_assignment_description  = ""
policy_assignment_parameters   = "{}"
policy_enforcement_mode        = true
policy_location                = ""
policy_identity_type           = ""

# -------------------------------------------------------------------
# End of Policy Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Private DNS Module Inputs
# The values below feed module "private_dns_basic" in main.tf.
# -------------------------------------------------------------------
# Optional override: leave commented to use app_rg.
# private_dns_resource_group_name = "rg-ba-cc-prd-shared-management"
private_dns_zones = {
  "privatelink.blob.core.windows.net" = {
    vnet_links = {}
    a_records  = {}
  }
}

private_dns_tags = {
  "resourceType" = "PrivateDNS"
}
# -------------------------------------------------------------------
# End of Private DNS Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Resource Group Module Inputs
# The values below feed module "resource_group_basic" in main.tf.
# -------------------------------------------------------------------
resource_group_name     = "rg-ba-cc-prd-shared-management-02"
resource_group_location = "canadacentral"

resource_group_enable_lock = false
resource_group_lock_level  = "CanNotDelete"
resource_group_lock_notes  = "Managed by Terraform"

# Optional resource-group RBAC groups.
# Leave as [] to skip group-based role assignments.
resource_group_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
resource_group_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

resource_group_tags = {
  "Environment" = "Production"
  "Owner"       = "CCOE"
  "IaC"         = "Terraform"
}

# -------------------------------------------------------------------
# End of Resource Group Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Role Assignments Module Inputs
# The values below feed module "role_assignments_basic" in main.tf.
# -------------------------------------------------------------------
roleassignments_assignments = {}
# -------------------------------------------------------------------
# End of Role Assignments Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Route Table Module Inputs
# The values below feed module "route_table_basic" in main.tf.
# -------------------------------------------------------------------
# Optional overrides: leave commented to use app_rg and that resource group's location.
# route_table_resource_group_name = "rg-ba-cc-prd-shared-management"
# route_table_location            = "canadacentral"
route_table_name = "rt-iactest-prod-001"

route_table_disable_bgp_route_propagation = false
route_table_routes                        = {}
route_table_subnet_ids                    = []

route_table_tags = {
  "resourceType" = "RouteTable"
}
# -------------------------------------------------------------------
# End of Route Table Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Service Bus Module Inputs
# The values below feed module "servicebus_basic" in main.tf.
# -------------------------------------------------------------------
# Optional overrides: leave commented to use app_rg and that resource group's location.
# servicebus_resource_group_name = "rg-ba-cc-prd-shared-management"
# servicebus_location            = "canadacentral"
# Optional override: leave commented to let the module generate a namespace name.
# servicebus_name = "sb-iactest-prod-001"
servicebus_sku                             = "Standard"
servicebus_capacity                        = 0
servicebus_premium_messaging_partitions    = 0
servicebus_local_auth_enabled              = true
servicebus_public_network_access_enabled   = true
servicebus_minimum_tls_version             = "1.2"
servicebus_system_managed_identity_enabled = false

servicebus_enable_network_rule_set     = false
servicebus_network_rule_default_action = "Allow"
servicebus_network_rule_ip_rules       = []
servicebus_trusted_services_allowed    = false
servicebus_network_rules               = []

servicebus_queues = {
  orders = {
    max_size_in_megabytes                = 1024
    max_delivery_count                   = 10
    lock_duration                        = "PT1M"
    default_message_ttl                  = "P14D"
    dead_lettering_on_message_expiration = true
    requires_duplicate_detection         = false
    requires_session                     = false
    partitioning_enabled                 = false
    express_enabled                      = false
    batched_operations_enabled           = true
    status                               = "Active"
  }
}

servicebus_topics = {
  events = {
    max_size_in_megabytes        = 1024
    default_message_ttl          = "P14D"
    requires_duplicate_detection = false
    partitioning_enabled         = false
    express_enabled              = false
    batched_operations_enabled   = true
    support_ordering             = false
    status                       = "Active"
  }
}

servicebus_subscriptions = {
  events-processor = {
    topic_name                           = "events"
    max_delivery_count                   = 10
    lock_duration                        = "PT1M"
    default_message_ttl                  = "P14D"
    dead_lettering_on_message_expiration = true
    requires_session                     = false
    batched_operations_enabled           = true
    status                               = "Active"
  }
}

servicebus_authorization_rules = {
  sender = {
    listen = false
    send   = true
    manage = false
  }
}

servicebus_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
servicebus_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

servicebus_enable_private_endpoint                      = false
servicebus_private_endpoint_subnet_id                   = ""
servicebus_private_endpoint_subnet_name                 = ""
servicebus_private_endpoint_vnet_name                   = ""
servicebus_private_endpoint_network_resource_group_name = ""
servicebus_private_dns_zone_id                          = ""

servicebus_enable_diagnostics           = false
servicebus_log_analytics_workspace_id   = ""
servicebus_diagnostic_log_categories    = ["OperationalLogs", "VNetAndIPFilteringLogs", "RuntimeAuditLogs", "ApplicationMetricsLogs"]
servicebus_diagnostic_metric_categories = ["AllMetrics"]

servicebus_tags = {
  "resourceType" = "ServiceBus"
}
# -------------------------------------------------------------------
# End of Service Bus Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# SQL DB Module Inputs
# The values below feed module "sqldb_basic" in main.tf.
# -------------------------------------------------------------------
# Optional overrides when you enable module "sqldb_basic":
# app_sqlserver_name = "sql-ccoe-iac-cc-prod-001"
# app_sqldb_name     = "sqldb-ccoe-iac-cc-prod-001"
# sqldb_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
# sqldb_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
# sql_ad_group    = "BA-G-Azure-Owner-F"
# sql_ad_group_id = "962b2502-5355-48bd-a33e-9280db2ac892"
# -------------------------------------------------------------------
# End of SQL DB Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# SQL Managed Instance Module Inputs
# The values below feed module "sqlmi_basic" in main.tf.
# Keep the module block commented until you have a delegated subnet.
# -------------------------------------------------------------------
# Optional override: leave commented to use sqlmi-${workload}-${app_env}-${suffix}.
# sqlmi_name = "sqlmi-iactest-prod-001"
# Optional override: leave commented to use app_rg and that resource group's location.
# sqlmi_resource_group_name = "rg-ba-cc-prd-shared-management"
# sqlmi_location            = "canadacentral"
# Required when you enable module "sqlmi_basic": use a delegated subnet resource ID for SQL Managed Instance.
# sqlmi_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<delegated-sqlmi-subnet>"

# Optional override: leave commented to use the sqladminuser-password secret from the IAC Key Vault.
# sqlmi_administrator_login_password = "<sqlmi-admin-password>"
sqlmi_administrator_login = "sqladminuser"

# Common SQL MI options:
# sqlmi_sku_name:
# - "GP_Gen5" for General Purpose
# - "BC_Gen5" for Business Critical
sqlmi_sku_name            = "GP_Gen5"
sqlmi_license_type        = "BasePrice"
sqlmi_vcores              = 8
sqlmi_storage_size_in_gb  = 512
sqlmi_collation           = "SQL_Latin1_General_CP1_CI_AS"
sqlmi_minimum_tls_version = "1.2"
sqlmi_timezone_id         = "UTC"

sqlmi_public_data_endpoint_enabled = false

# Connection mode options for sqlmi_proxy_override:
# - "Proxy"
# - "Redirect"
# - "Default"
sqlmi_proxy_override = "Proxy"

# Storage redundancy options for sqlmi_storage_account_type:
# - "GRS"
# - "LRS"
# - "ZRS"
sqlmi_storage_account_type   = "GRS"
sqlmi_zone_redundant_enabled = false
# sqlmi_maintenance_configuration_name = "<maintenance-configuration-name>"
# sqlmi_dns_zone_partner_id            = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Sql/managedInstances/<partner-sqlmi-name>"

# Identity options for sqlmi_identity_type:
# - "SystemAssigned"
# - "UserAssigned"
# - "SystemAssigned, UserAssigned"
sqlmi_identity_type = "SystemAssigned"
# sqlmi_identity_ids = [
#   "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity-name>"
# ]

# Optional Entra administrator block:
# sqlmi_azure_active_directory_administrator = {
#   login_username                      = "BA-G-Azure-Owner-F"
#   object_id                           = "962b2502-5355-48bd-a33e-9280db2ac892"
#   principal_type                      = "Group"
#   tenant_id                           = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
#   azuread_authentication_only_enabled = false
# }

sqlmi_enable_diagnostics = false
# Optional override: leave commented to use data.azurerm_log_analytics_workspace.this.id.
# sqlmi_log_analytics_workspace_id = "<log-analytics-workspace-resource-id>"
sqlmi_diagnostic_log_categories    = ["ResourceUsageStats", "SQLSecurityAuditEvents", "DevOpsOperationsAudit"]
sqlmi_diagnostic_metric_categories = ["AllMetrics"]
sqlmi_app_admin_group              = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
sqlmi_app_user_group               = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

sqlmi_tags = {
  "resourceType" = "SQLMI"
}
# -------------------------------------------------------------------
# End of SQL Managed Instance Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# SQL Managed Instance Database Module Inputs
# The values below feed module "sqlmi_db" in main.tf.
# -------------------------------------------------------------------
app_sqlmi    = "sqlmi-gen-cc-001"
app_sqlmi_rg = "rg-sharedservice-cc-prod"
app_sqlmi_db = "sqlmidb-iactest-cc-001"
# Optional override: leave commented to keep the current SQL AD admin group.
# sql_ad_group = "BA-G-CCOE-Admin-F"
sqlmi_db_enable_diagnostics = false
# Optional override: leave commented to use data.azurerm_log_analytics_workspace.this.id.
# sqlmi_db_log_analytics_workspace_id = "<log-analytics-workspace-resource-id>"
sqlmi_db_diagnostic_log_categories    = ["SQLSecurityAuditEvents"]
sqlmi_db_diagnostic_metric_categories = ["AllMetrics"]
sqlmi_db_app_admin_group              = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
sqlmi_db_app_user_group               = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

# The module also merges the SQL MI resource group tags and adds module = "sqlmi_db".
sqlmidb_tags = {
  "ResourceType"                            = "SQLMIDB"
  "Tier2:Application Name"                  = "CCOE INFRA IAC"
  "Tier2:Application Owner"                 = "CCOE"
  "Tier2:AppSupport Team"                   = "CCOE"
  "Tier2:Approval Group"                    = "CCOE"
  "Tier2:Business Owner"                    = "CCOE"
  "Tier2:Environment"                       = "Prod"
  "Tier2:InfraSupport Team"                 = "CCOE"
  "Tier2:Maintenance Window"                = "CCOE"
  "Tier2:Project Name"                      = "CCOE INFRA IAC"
  "Tier2:Project Number"                    = "N/A"
  "Tier2:RPO-RTO"                           = "48H/24H"
  "Tier2:Run Cost(Approved Run Budget)-USD" = "100"
  "Tier2:workload"                          = "iactest"
  "Tier2:Requested By"                      = "CCOE"
  "Tier2:Provisioned By"                    = "admin@2join.us"
  "Tier2:Technical contact"                 = "admin@2join.us"
  "Tier2:Business contact"                  = "admin@2join.us"
  "Tier2:ADO Project"                       = "CCoE-Infra-IaC"
  "Tier2:ADO Repo"                          = "adf-lab"
  "Tier2:ADO Link"                          = "https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/adf-lab"
}
# -------------------------------------------------------------------
# End of SQL Managed Instance Database Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Storage Account Module Inputs
# The values below feed module "storage_account_basic" in main.tf.
# -------------------------------------------------------------------
storage_account_resource_group_name = "rg-ba-cc-prd-shared-management"
storage_account_location            = "canadacentral"
storage_account_name                = "stiactestprod001"

# Optional storage-account RBAC groups.
# Leave as [] to skip group-based Contributor/Reader assignments.
# If a display name is duplicated in Entra ID, use the group's object ID instead.
storage_account_system_managed_identity_enabled = false
# BA-G-CCOE-Admin-F has 2 matching groups in the AAD, one from AD and another one from AAD. We can use objectID to fix this
storage_account_app_admin_group                   = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
storage_account_app_user_group                    = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
storage_account_managed_identity_role_assignments = {}

# storage_account_account_tier             = "Standard"
# storage_account_account_replication_type = "LRS"
# storage_account_account_kind             = "StorageV2"
# storage_account_access_tier              = "Hot"
# storage_account_min_tls_version          = "TLS1_2"

# storage_account_https_traffic_only_enabled        = true
# storage_account_public_network_access_enabled     = false
# storage_account_allow_nested_items_to_be_public   = false
# storage_account_shared_access_key_enabled         = true
# storage_account_cross_tenant_replication_enabled  = false
# storage_account_infrastructure_encryption_enabled = false

# storage_account_is_hns_enabled     = false
# storage_account_nfsv3_enabled      = false
# storage_account_sftp_enabled       = false
# storage_account_local_user_enabled = false

# storage_account_enable_network_rules                     = false
# storage_account_network_rules_default_action             = "Deny"
# storage_account_network_rules_bypass                     = ["AzureServices"]
# storage_account_network_rules_ip_rules                   = []
# storage_account_network_rules_virtual_network_subnet_ids = []

# storage_account_private_endpoint_subnet_id                   = "/subscriptions/ef8ff35a-8548-485c-be32-204db0340dd1/resourceGroups/rg-ba-cc-prod-app-network/providers/Microsoft.Network/virtualNetworks/vnet-ba-cc-prod-app/subnets/snet-ba-cc-prod-app-frontend"
storage_account_private_endpoint_subnet_name                 = "snet-ba-cc-prod-app-frontend"
storage_account_private_endpoint_vnet_name                   = "vnet-ba-cc-prod-app"
storage_account_private_endpoint_network_resource_group_name = "rg-ba-cc-prod-app-network"
storage_account_private_endpoint_subresource_names           = ["blob"]
storage_account_private_dns_zone_ids                         = {}
storage_account_private_dns_zone_names = {
  blob = "privatelink.blob.core.windows.net"
}
storage_account_private_dns_zone_resource_group_name = "rg-ba-cc-prod-app-network"

# storage_account_enable_diagnostics           = false
# Optional override: leave commented to use data.azurerm_log_analytics_workspace.this.id.
# storage_account_log_analytics_workspace_id   = "<log-analytics-workspace-resource-id>"
# storage_account_diagnostic_log_categories    = ["StorageRead", "StorageWrite", "StorageDelete"]
# storage_account_diagnostic_metric_categories = ["Transaction"]

storage_account_tags = {
  "Environment" = "Production"
  "Owner"       = "CCOE"
  "IaC"         = "Terraform"
}

# -------------------------------------------------------------------
# End of Storage Account Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Subscription Vending Module Inputs
# The values below feed module "subscription_vending_basic" in main.tf.
# -------------------------------------------------------------------
subscription_vending_subscription_alias_enabled = false
subscription_vending_subscription_alias_name    = ""
subscription_vending_subscription_name          = "platform-iactest-prod"
subscription_vending_billing_scope_id           = ""
subscription_vending_existing_subscription_id   = "/subscriptions/<subscription-id>"
subscription_vending_management_group_id        = "/providers/Microsoft.Management/managementGroups/<management-group-id>"

subscription_vending_resource_provider_registrations = [
  "Microsoft.Network",
  "Microsoft.KeyVault"
]

subscription_vending_bootstrap_resource_groups = {}

subscription_vending_tags = {
  "resourceType" = "SubscriptionVending"
}
# -------------------------------------------------------------------
# End of Subscription Vending Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Virtual Network Module Inputs
# The values below feed module "vnet_basic" in main.tf.
# -------------------------------------------------------------------
vnet_resource_group_name = "rg-ba-cc-prd-shared-management"
vnet_location            = "canadacentral"
vnet_name                = "vnet-ba-cc-prd-shared-management-01"

vnet_address_space           = ["10.250.0.0/16"]
vnet_dns_servers             = []
vnet_bgp_community           = null
vnet_edge_zone               = null
vnet_flow_timeout_in_minutes = null
vnet_ddos_protection_plan_id = ""

# Optional virtual-network subnet definitions.
vnet_subnets = {
  app = {
    address_prefixes                              = ["10.250.1.0/24"]
    service_endpoints                             = ["Microsoft.Storage", "Microsoft.KeyVault"]
    service_endpoint_policy_ids                   = []
    private_endpoint_network_policies             = "Enabled"
    private_link_service_network_policies_enabled = true
    delegations                                   = {}
  }
  private_endpoint = {
    address_prefixes                              = ["10.250.10.0/24"]
    service_endpoints                             = []
    service_endpoint_policy_ids                   = []
    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = true
    delegations                                   = {}
  }
}

# Optional virtual-network RBAC groups.
# Leave as [] to skip group-based role assignments.
vnet_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
vnet_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

vnet_enable_diagnostics = false
# Optional override: leave commented to use data.azurerm_log_analytics_workspace.this.id.
# vnet_log_analytics_workspace_id   = "<log-analytics-workspace-resource-id>"
vnet_diagnostic_log_categories    = []
vnet_diagnostic_metric_categories = ["AllMetrics"]

vnet_tags = {
  "Environment" = "Production"
  "Owner"       = "CCOE"
  "IaC"         = "Terraform"
}

# -------------------------------------------------------------------
# End of Virtual Network Module Inputs
# -------------------------------------------------------------------

# Windows VM Module Inputs
# The values below feed module "winvm_basic" in main.tf.
# -------------------------------------------------------------------
app_env     = "prod"
app_vnet    = "vnet-ba-cc-prod-hub"
app_vnet_rg = "rg-ba-cc-prod-hub-network"
app_snet    = "snet-ba-cc-prod-hub-sysmgmt"
#db_snet     = "snet-ba-cc-prod-app-datatier"

app_rg        = "rg-ba-cc-prd-shared-management"
app_vm        = "azuwiiactest"
app_vm_number = 1
#app_vm_size   = "Standard_D4s_v3"
app_vm_size            = "Standard_B1s"
disksize               = 100
public_network_enabled = false

iac_rg           = "rg-ccoe-iac-cc-prod"
iac_kv           = "kv-ccoe-cc-prod"
iac_st           = "stccoeiacprod"
app_remote_group = ["BA-G-CCOE-Admin-F", "BA-G-Azure-Owner-F", "2JOINUS-AzureDevOps-Admin"]
app_admin_group  = ["BA-G-CCOE-Admin-F", "BA-G-Azure-Owner-F"]
app_user_group   = ["BA-G-CCOE-Admin-F", "BA-G-Azure-Owner-F"]
app_ad_group     = "BA-G-CCOE-Admin-F"
app_ad_group_id  = "7a958d36-a182-451e-8012-4e8fe9386dc7"
vm_remote_group  = "7a958d36-a182-451e-8012-4e8fe9386dc7"
vm_admin_group   = "BA-G-Azure-Owner-F"

enable_domain_join = false
# Leave false to skip the Windows bootstrap CustomScriptExtension entirely.
# Set true only when you want init/script bootstrap to run on the VM.
enable_custom_script_extension = false
AADLoginForWindows             = true
enable_shir                    = false
# adf_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.DataFactory/factories/<adf-name>"

enable_diagnostics = false
# Optional override: leave commented to use data.azurerm_log_analytics_workspace.this.id.
# log_analytics_workspace_id = "<log-analytics-workspace-resource-id>"

winvm_tags = {
  "resourceType" = "WINVM"
}
# -------------------------------------------------------------------

# End of Windows VM Module Inputs
# -------------------------------------------------------------------
