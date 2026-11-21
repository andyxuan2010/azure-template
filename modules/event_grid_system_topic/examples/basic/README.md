# Basic Event Grid System Topic Example

Creates an Event Grid System Topic for an existing Azure resource. The source resource is not created or managed by this example; pass its full resource ID through `source_resource_id` and select its Azure topic type.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-platform-dev" -var="source_resource_id=/subscriptions/<subscription-id>/resourceGroups/rg-platform-dev/providers/Microsoft.Storage/storageAccounts/stplatformdev001"
```

Applying this example creates the system topic but no event subscription. Create and own subscriptions separately so delivery endpoints and retry/dead-letter behavior remain explicit.

## Cost and risk

The system topic has no standing charge. Event Grid bills per operation on event subscriptions, and this example creates none, so it incurs no event charges until a subscription is added elsewhere. The source resource is billed separately and is not managed here.

- `topic_type` and `source_resource_id` are replacement-sensitive. Changing either recreates the topic and any event subscriptions attached to it.
- Azure allows one system topic per source and topic type, so the apply fails if one already exists for that source.
- The example sets no identity and no network controls.
