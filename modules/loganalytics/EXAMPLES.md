# Log Analytics Examples

## Capacity Reservation

```hcl
module "loganalytics" {
  source = "./modules/loganalytics"

  name                               = "law-platform-prod"
  resource_group_name                = "rg-platform-prod"
  location                           = "canadacentral"
  sku                                = "CapacityReservation"
  reservation_capacity_in_gb_per_day = 100
  retention_in_days                  = 90
}
```

## Default Data Collection Rule

```hcl
data_collection_rule_id = azurerm_monitor_data_collection_rule.platform.id
```
