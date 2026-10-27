# Complete Event Grid System Topic Example

Creates an Event Grid System Topic for an existing Azure resource with an explicit topic type, system-assigned managed identity, normalized tags, and explicit naming. The source resource and event subscriptions remain outside this example.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-platform-dev" -var="source_resource_id=/subscriptions/<subscription-id>/resourceGroups/rg-platform-dev/providers/Microsoft.Storage/storageAccounts/stplatformdev001"
```

The managed identity receives no permissions from this module. Grant only the downstream permissions required by the chosen event delivery design in the owning composition.

## Cost and risk

The system topic has no standing charge. Event Grid bills per operation on event subscriptions, and this example creates none. The system-assigned managed identity is free. The source resource is billed separately and is not managed here.

- `topic_type` and `source_resource_id` are replacement-sensitive. Changing either recreates the topic, and a new identity gets a new principal ID, so any role assignments granted to the old identity stop working.
- Azure allows one system topic per source and topic type, so the apply fails if one already exists for that source.
- The identity has no permissions until the owning composition grants them. Keep those grants scoped to the delivery destination only.
