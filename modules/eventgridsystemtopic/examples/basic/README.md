# Basic Event Grid System Topic Example

Creates an Event Grid System Topic for an existing Azure resource. The source resource is not created or managed by this example; pass its full resource ID through `source_resource_id` and select its Azure topic type.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-platform-dev" -var="source_resource_id=/subscriptions/<subscription-id>/resourceGroups/rg-platform-dev/providers/Microsoft.Storage/storageAccounts/stplatformdev001"
```

Applying this example creates the system topic but no event subscription. Create and own subscriptions separately so delivery endpoints and retry/dead-letter behavior remain explicit.
