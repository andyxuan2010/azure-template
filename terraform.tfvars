# -------------------------------------------------------------------
# Feature Enabler Block
# -------------------------------------------------------------------
# These high-level switches mirror the landingzone repo. Unspecified
# module harness toggles stay disabled unless module_plan_enabled
# enables them explicitly.
# -------------------------------------------------------------------
features = {
  enable_management_group                = false
  enable_subscription_bootstrap          = false
  enable_private_dns                     = false
  enable_adf                             = false
  enable_azure_ai_search                 = false
  enable_azure_ai_service                = false
  enable_openai                          = false
  enable_acr                             = false
  enable_app_services                    = false
  enable_app_registration_for_appservice = false
  enable_automation_accounts             = false
  enable_automation_ari_workloads        = false
  enable_linux_vm                        = false
  enable_aks                             = false
  enable_sqldb                           = false
}

# -------------------------------------------------------------------
# Shared Sample Inputs
# -------------------------------------------------------------------
subscription_id                 = ""
tenant_id                       = ""
location                        = "canadacentral"
environment                     = "dev"
workload                        = "template"
shared_resource_group_name      = "rg-platform-dev"
network_resource_group_name     = "rg-platform-dev"
private_dns_resource_group_name = "rg-platform-dev"
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

app_admin_group = ["85052ddf-9641-48d9-a0a9-faf8d322f573"]
app_user_group  = []
