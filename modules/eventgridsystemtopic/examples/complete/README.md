# Complete Event Grid System Topic Example

Creates an Event Grid System Topic for an existing Azure resource with an explicit topic type, system-assigned managed identity, normalized tags, and explicit naming. The source resource and event subscriptions remain outside this example.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-platform-dev" -var="source_resource_id=/subscriptions/<subscription-id>/resourceGroups/rg-platform-dev/providers/Microsoft.Storage/storageAccounts/stplatformdev001"
```

The managed identity receives no permissions from this module. Grant only the downstream permissions required by the chosen event delivery design in the owning composition.
