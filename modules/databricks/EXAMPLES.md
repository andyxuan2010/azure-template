# Databricks Examples

## Basic Workspace

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "dbw-example-prod-001"
  sku                 = "premium"

  tags = {
    Environment = "Production"
    Owner       = "DataPlatform"
  }
}
```

## VNet-Injected Workspace

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name                   = "rg-example-prod"
  location                              = "eastus"
  name                                  = "dbw-example-prod-001"
  sku                                   = "premium"
  public_network_access_enabled         = false
  network_security_group_rules_required = "NoAzureDatabricksRules"

  custom_parameters = {
    no_public_ip                                         = true
    virtual_network_id                                   = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>"
    public_subnet_name                                   = "snet-databricks-public"
    private_subnet_name                                  = "snet-databricks-private"
    public_subnet_network_security_group_association_id  = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<public-subnet>/providers/Microsoft.Network/networkSecurityGroupAssociations/default"
    private_subnet_network_security_group_association_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<private-subnet>/providers/Microsoft.Network/networkSecurityGroupAssociations/default"
  }
}
```

## Workspace With Diagnostics and RBAC

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "dbw-example-prod-001"
  sku                 = "premium"

  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group  = ["11111111-1111-1111-1111-111111111111"]

  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<law>"
  diagnostic_metric_categories = ["AllMetrics"]
}
```
