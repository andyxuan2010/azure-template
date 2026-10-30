# Complete Flex Consumption Function App Example

Creates a Flex Consumption Function App with an existing Linux `FC1` plan and blob deployment container, a system-assigned identity, instance scaling limits, 4,096 MB instances, HTTP concurrency, runtime scale monitoring, and one always-ready function.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-functions-dev" -var="service_plan_id=/subscriptions/<subscription-id>/resourceGroups/rg-functions-dev/providers/Microsoft.Web/serverFarms/asp-functions-flex-dev" -var="storage_container_endpoint=https://stfunctionsdev.blob.core.windows.net/function-packages" -var="storage_access_key=<secret>"
```

The example demonstrates Function App configuration only. It does not create the FC1 plan, storage account, blob container, function package, VNet, private connectivity, or downstream role assignments.

## Cost and risk

- Billing is per execution and per GB-second of instance memory (4096 MB here, so each instance costs about twice the 2048 MB default per second), up to `maximum_instance_count = 20`.
- `always_ready = { "orders-http" = 1 }` keeps one pre-provisioned instance warm for that trigger group. Always-ready instances are billed continuously for their baseline memory, and a separate execution charge applies on top when they run code, so this is the main standing cost.
- The storage account, blob container, Application Insights (per GB ingested) and any VNet or private endpoints are billed separately and are not created here. The system-assigned identity and the scale-monitoring setting are free.
- Risk: raising `http_concurrency` and `maximum_instance_count` raises both peak cost and downstream load, so cap them to what back ends can take. Public network access defaults to `false`, so the app is unreachable from outside the network unless you open it. The storage key is stored in state. The identity has no role assignments, so it cannot reach other resources until you grant access. Changing the plan, runtime or storage container can replace the app.
