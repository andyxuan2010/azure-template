# Service Bus Examples

## Namespace With Queue And Topic

```hcl
module "servicebus" {
  source = "../servicebus"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
  name                = "sb-platform-prod-001"

  queues = {
    orders = {}
  }

  topics = {
    events = {}
  }

  subscriptions = {
    events_processor = {
      topic_name = "events"
    }
  }
}
```
