# Complete Flex Consumption Function App Example

Creates a Flex Consumption Function App with an existing Linux `FC1` plan and blob deployment container, a system-assigned identity, instance scaling limits, 4,096 MB instances, HTTP concurrency, runtime scale monitoring, and one always-ready function.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-functions-dev" -var="service_plan_id=/subscriptions/<subscription-id>/resourceGroups/rg-functions-dev/providers/Microsoft.Web/serverFarms/asp-functions-flex-dev" -var="storage_container_endpoint=https://stfunctionsdev.blob.core.windows.net/function-packages" -var="storage_access_key=<secret>"
```

The example demonstrates Function App configuration only. It does not create the FC1 plan, storage account, blob container, function package, VNet, private connectivity, or downstream role assignments.
