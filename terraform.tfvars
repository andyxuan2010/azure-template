# -------------------------------------------------------------------
# Feature Enabler Block
# -------------------------------------------------------------------
# These high-level switches mirror the landingzone repo. Unspecified
# module harness toggles stay disabled unless module_plan_enabled
# enables them explicitly.
# -------------------------------------------------------------------
features = {
  enable_acr                             = false
  enable_adf                             = false
  enable_aks                             = false
  enable_application_gateway             = false
  enable_app_registration_for_appservice = false
  enable_app_services                    = false
  enable_automation_accounts             = false
  enable_automation_ari_workloads        = false
  enable_azure_ai_search                 = false
  enable_azure_ai_service                = false
  enable_cosmosdb                        = false
  enable_databricks                      = false
  enable_enterprise_application          = false
  enable_eventhub                        = false
  enable_firewall                        = false
  enable_fortigate                       = false
  enable_functionapp                     = false
  enable_keyvault                        = false
  enable_loganalytics                    = false
  enable_logicapp                        = false
  enable_managed_identity                = false
  enable_management_group                = false
  enable_nsg                             = false
  enable_openai                          = false
  enable_policy                          = false
  enable_private_dns                     = false
  enable_resource_group                  = false
  enable_roleassignments                 = false
  enable_route_table                     = false
  enable_servicebus                      = false
  enable_sqldb                           = false
  enable_sqlmi                           = false
  enable_sqlmi_db                        = false
  enable_storageaccount                  = false
  enable_subscription_bootstrap          = false
  enable_vnet                            = false
  enable_winvm                           = false
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
linuxvm_private_ip_addresses = []
shared_management_group_name = "mg-platform-dev"
#sample_principal_object_id          = "00000000-0000-0000-0000-000000000001"

app_admin_group = ["85052ddf-9641-48d9-a0a9-faf8d322f573"]
app_user_group  = []

# -------------------------------------------------------------------
# Root Module Pass-through Inputs
# -------------------------------------------------------------------
applicationgateway_name      = ""
applicationgateway_subnet_id = ""
applicationgateway_backend_address_pools = {
  app = {
    ip_addresses = ["10.42.1.4"]
  }
}
applicationgateway_backend_http_settings = {
  app = {
    port     = 80
    protocol = "Http"
  }
}
applicationgateway_http_listeners = {
  public = {
    frontend_port_name = "http"
    protocol           = "Http"
  }
}
applicationgateway_request_routing_rules = {
  public = {
    rule_type                  = "Basic"
    http_listener_name         = "public"
    backend_address_pool_name  = "app"
    backend_http_settings_name = "app"
    priority                   = 100
  }
}

cosmosdb_name = ""
cosmosdb_sql_databases = {
  app = {
    autoscale_max_ru = 4000
  }
}
cosmosdb_sql_containers = {
  items = {
    database_name       = "app"
    partition_key_paths = ["/tenantId"]
    autoscale_max_ru    = 4000
  }
}

databricks_name = ""

# -------------------------------------------------------------------
# Enterprise Application Module Inputs
# -------------------------------------------------------------------
enterprise_application_application_id                = ""
enterprise_application_account_enabled               = true
enterprise_application_app_role_assignment_required  = false
enterprise_application_description                   = null
enterprise_application_notes                         = null
enterprise_application_login_url                     = "https://app.contoso.com"
enterprise_application_preferred_single_sign_on_mode = "oidc"
enterprise_application_saml_relay_state              = null
enterprise_application_owners                        = []
enterprise_application_add_current_caller_as_owner   = true
enterprise_application_notification_email_addresses  = []
enterprise_application_feature_tags = {
  enterprise = true
}
enterprise_application_use_existing             = true
enterprise_application_app_role_assignments     = {}
enterprise_application_create_application_proxy = false
enterprise_application_application_proxy = {
  internal_url                 = "https://intranet.contoso.local/"
  external_url                 = "https://intranet-contoso.msappproxy.net/"
  external_authentication_type = "aadPreAuthentication"
  application_server_timeout   = "Default"
}

eventhub_name = ""
eventhub_eventhubs = {
  telemetry = {
    partition_count   = 2
    message_retention = 1
  }
}

firewall_name      = ""
firewall_subnet_id = ""

fortigate_architecture                        = "single"
fortigate_name_prefix                         = ""
fortigate_license_type                        = "byol"
fortigate_vm_size                             = "Standard_F4s_v2"
fortigate_availability_zones                  = { a = "1", b = "2" }
fortigate_single_zone                         = ""
fortigate_load_balancer_frontend_zones        = []
fortigate_admin_username                      = "azureuser"
fortigate_admin_password                      = ""
fortigate_admin_ssh_public_key                = ""
fortigate_management_access_model             = "private"
fortigate_create_subnets                      = false
fortigate_virtual_network_name                = ""
fortigate_virtual_network_resource_group_name = ""
fortigate_interfaces = {
  external = {
    role      = "external"
    subnet_id = ""
    primary   = true
    private_ip_addresses = {
      a = "10.42.10.4"
      b = "10.42.10.5"
    }
  }
  internal = {
    role      = "internal"
    subnet_id = ""
    private_ip_addresses = {
      a = "10.42.11.4"
      b = "10.42.11.5"
    }
  }
}
fortigate_create_network_security_group = true
fortigate_network_security_group_name   = ""
fortigate_network_security_rules        = {}
fortigate_internal_load_balancer        = {}
fortigate_external_load_balancer        = {}

functionapp_name                                = ""
functionapp_service_plan_id                     = ""
functionapp_storage_account_name                = ""
functionapp_storage_account_resource_group_name = ""

keyvault_name = ""

loganalytics_name = ""

logicapp_name                                = ""
logicapp_service_plan_id                     = ""
logicapp_storage_account_name                = ""
logicapp_storage_account_resource_group_name = ""

managedidentity_name = ""

nsg_name                  = ""
nsg_security_rules        = {}
nsg_subnet_ids            = []
nsg_network_interface_ids = []

policy_name                = ""
policy_display_name        = ""
policy_management_group_id = ""
policy_rule                = ""

rg_name = ""

roleassignments_assignments = {}

route_table_name       = ""
route_table_routes     = {}
route_table_subnet_ids = []

servicebus_name          = ""
servicebus_queues        = {}
servicebus_topics        = {}
servicebus_subscriptions = {}

sqlmi_name                         = ""
sqlmi_administrator_login          = "sqladminuser"
sqlmi_administrator_login_password = "ChangeMeSqlMi12345!"
sqlmi_sku_name                     = "GP_Gen5"
sqlmi_vcores                       = 4
sqlmi_storage_size_in_gb           = 64

sqlmi_db_name = ""

storageaccount_name        = ""
storageaccount_containers  = {}
storageaccount_file_shares = {}
storageaccount_queues      = {}
storageaccount_tables      = {}

vnet_name          = ""
vnet_address_space = ["10.42.0.0/16"]
vnet_subnets       = {}

winvm_enable_domain_join               = false
winvm_domain_join_user                 = ""
winvm_domain_join_password             = ""
winvm_domain_join_username_secret_name = "domain-join-user"
winvm_domain_join_password_secret_name = "domain-join-password"
winvm_vm_remote_group                  = null
winvm_vm_admin_group                   = null
winvm_public_network_enabled           = false
winvm_private_ip_addresses             = []
winvm_enable_shir                      = false
