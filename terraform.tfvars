# -------------------------------------------------------------------
# Plan Toggle Block
# -------------------------------------------------------------------
# Keep all module toggles false for a clean plan-validation harness.
# Turn on one module at a time when you want to run a live plan with
# real backing infrastructure already present in Azure.
# -------------------------------------------------------------------
module_plan_enabled = {
  acr                  = true
  adf                  = true
  aks                  = true
  appregistration      = true
  appservice           = true
  appserviceplan       = true
  applicationgateway   = true
  automationaccount    = true
  azure_ai_service     = true
  azure_ai_search      = true
  databricks           = true
  eventhub             = true
  firewall             = true
  functionapp          = false
  keyvault             = true
  linuxvm              = true
  loganalytics         = true
  logicapp             = true
  managedidentity      = true
  managementgroups     = true
  nsg                  = true
  openai               = true
  policy               = true
  private_dns          = true
  rg                   = true
  roleassignments      = true
  route_table          = true
  servicebus           = true
  sqldb                = true
  sqlmi                = true
  sqlmi_db             = false
  storageaccount       = true
  subscription_vending = true
  vnet                 = true
  winvm                = true
}

# -------------------------------------------------------------------
# Shared Sample Inputs
# -------------------------------------------------------------------
subscription_id                 = ""
tenant_id                       = ""
location                        = "eastus"
environment                     = "dev"
workload                        = "platform"
shared_resource_group_name      = "rg-platform-dev"
network_resource_group_name     = "rg-platform-dev"
private_dns_resource_group_name = "rg-platform-dev-dns"
shared_vnet_name                = "vnet-spoke-platform-dev"
app_subnet_name                 = "snet-app"
private_endpoint_subnet_name    = "snet-private-endpoints"
firewall_subnet_name            = "AzureFirewallSubnet"
shared_storage_account_name     = ""
shared_storage_blob_properties = {
  versioning_enabled                     = true
  change_feed_enabled                    = true
  last_access_time_enabled               = true
  delete_retention_policy_days           = 7
  container_delete_retention_policy_days = 7
  restore_policy_days                    = 6
}
shared_key_vault_name        = ""
shared_log_analytics_name    = ""
shared_app_service_plan_name = ""
shared_vm_name               = ""
azure-password               = "ChangeMeLinuxVm123!"
azure-user                   = "azureadmin"
azure-ssh-key                = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjoftGI4Wgwc6YHGgbbUfAkMm2k4JQIkMXmlHrs24bnSa+CxNeC4eL7cFWZHgLxn6pBfqRCijsCbLpzUhlIJKMMxv2WB0TtHpezD9oUX1/9K7rC3RB4EcKmZ3vDWSsR4UBn9aVCZkQBnr+hfk39lj+Hk2qAMGloVFD0bM10j1Hhv5uMaT8lcClWK/TCcgKH8NQF3hZDqX8YADCYczvZ7B3hA+xpAZwOOZKChOv5Y2ABduD8KPcV6Uc1VLO6+xMlkDZc0MB6HkYlGZSbeMkstgPo+275SKHWVJ7B2nWMvOAyOtjU5OqHwYoNrsCX1TP380DUhQqqAqjzqDP8C0z76Gj"
linux_vm_datadog_api_key     = ""
shared_management_group_name = "mg-platform-dev"
#sample_principal_object_id          = "00000000-0000-0000-0000-000000000001"

app_admin_group = []
app_user_group  = []

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Purpose     = "module-plan-harness"
  Workload    = "platform"
}
