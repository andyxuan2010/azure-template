# Databricks Examples

## Minimal Premium Workspace

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  workload_name       = "lakehouse"
  app_env             = "prod"
  sku                 = "premium"
}
```

## Deterministic Naming

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name         = "rg-example-prod"
  location                    = "canadacentral"
  name                        = ""
  name_prefix                 = "dbw"
  workload_name               = "shared"
  app_env                     = "poc"
  include_environment_in_name = true
  location_code               = "cc"
  instance                    = "001"
  use_random_suffix           = false
}
```

## VNet Injection And Enhanced Security

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name           = "rg-example-prod"
  location                      = "canadacentral"
  name                          = "dbw-lakehouse-prod-cc-001"
  sku                           = "premium"
  public_network_access_enabled = false

  custom_parameters = {
    virtual_network_id                                   = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/virtualNetworks/<vnet>"
    public_subnet_name                                   = "snet-databricks-public"
    private_subnet_name                                  = "snet-databricks-private"
    public_subnet_network_security_group_association_id  = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/networkSecurityGroups/<nsg-public>/subnets/snet-databricks-public"
    private_subnet_network_security_group_association_id = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/networkSecurityGroups/<nsg-private>/subnets/snet-databricks-private"
    no_public_ip                                         = true
    storage_account_name                                 = "stdbxlakehouseprod001"
    storage_account_sku_name                             = "Standard_ZRS"
  }

  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group  = ["11111111-1111-1111-1111-111111111111"]
  assign_app_groups_to_managed_storage_account = true

  enhanced_security_compliance = {
    automatic_cluster_update_enabled      = true
    enhanced_security_monitoring_enabled  = true
    compliance_security_profile_enabled   = true
    compliance_security_profile_standards = ["HIPAA"]
  }
}
```

When `assign_app_groups_to_managed_storage_account = true`, the module also attempts storage-account scoped RBAC for the app groups:

- `app_admin_group`: Contributor and Storage Blob Data Contributor.
- `app_user_group`: Reader and Storage Blob Data Reader.

This is opt-in because managed resource-group deny assignments may block these assignments. Prefer external storage plus `access_connector_role_assignments` for Unity Catalog data access.

## Access Connector And Storage Firewall

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  name                = "dbw-lakehouse-prod-cc-001"

  create_access_connector          = true
  default_storage_firewall_enabled = true

  access_connector_role_assignments = {
    lake_storage = {
      scope                = "/subscriptions/<sub>/resourceGroups/<data-rg>/providers/Microsoft.Storage/storageAccounts/<lake-storage>"
      role_definition_name = "Storage Blob Data Contributor"
    }
  }
}
```

## Customer-Managed Keys And Private Endpoint

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name              = "rg-example-prod"
  location                         = "canadacentral"
  name                             = "dbw-lakehouse-prod-cc-001"
  sku                              = "premium"
  customer_managed_key_enabled     = true
  infrastructure_encryption_enabled = true

  managed_disk_cmk_key_vault_id     = "/subscriptions/<sub>/resourceGroups/<security-rg>/providers/Microsoft.KeyVault/vaults/<vault>"
  managed_disk_cmk_key_vault_key_id = "https://<vault>.vault.azure.net/keys/databricks-disk/<version>"
  managed_services_cmk_key_vault_id = "/subscriptions/<sub>/resourceGroups/<security-rg>/providers/Microsoft.KeyVault/vaults/<vault>"
  managed_services_cmk_key_vault_key_id = "https://<vault>.vault.azure.net/keys/databricks-services/<version>"

  root_dbfs_customer_managed_key = {
    key_vault_key_id = "https://<vault>.vault.azure.net/keys/databricks-root-dbfs/<version>"
    key_vault_id     = "/subscriptions/<sub>/resourceGroups/<security-rg>/providers/Microsoft.KeyVault/vaults/<vault>"
  }

  private_endpoint_subresource_names = ["databricks_ui_api"]
  private_endpoint_subnet_id         = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<pep-subnet>"
  private_dns_zone_ids = [
    "/subscriptions/<sub>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.azuredatabricks.net"
  ]
}
```

## Test Coverage

- `tests/live.tftest.hcl` validates named resources, deterministic generated names, standardized tags, VNet injection, enhanced security, RBAC, diagnostics, access connector creation, storage firewall, CMK, root DBFS CMK, and private endpoints.
