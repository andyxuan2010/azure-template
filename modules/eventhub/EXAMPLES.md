# Event Hub Examples

## Namespace With One Event Hub

```hcl
module "eventhub" {
  source = "../eventhub"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
  name                = "evh-platform-prod-001"

  eventhubs = {
    telemetry = {
      partition_count   = 2
      message_retention = 1
    }
  }
}
```
