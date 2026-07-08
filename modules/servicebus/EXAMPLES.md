# Service Bus Examples

## Namespace With Queue And Topic

```hcl
module "servicebus" {
  source = "./modules/servicebus"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
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
