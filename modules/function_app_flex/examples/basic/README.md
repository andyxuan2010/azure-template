# Basic Flex Consumption Function App Example

Creates an Azure Function App using the Flex Consumption resource with an existing Linux `FC1` App Service Plan, an existing blob deployment container, and Python 3.11. The plan, storage account, blob container, and package deployment are not created by this example.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-functions-dev" -var="service_plan_id=/subscriptions/<subscription-id>/resourceGroups/rg-functions-dev/providers/Microsoft.Web/serverFarms/asp-functions-flex-dev" -var="storage_container_endpoint=https://stfunctionsdev.blob.core.windows.net/function-packages" -var="storage_access_key=<secret>"
```

The storage key is sensitive. Supply it through a protected variable or secret store and do not commit it to source control.

## Cost and risk

- The Function App (Flex Consumption) is billed by execution: per GB-second of instance memory (default `instance_memory_in_mb` of 2048) while running, and per million executions. With no `always_ready` entries nothing is billed while idle. The App Service plan it attaches to (FC1) has no standing charge of its own for Flex Consumption.
- The storage account and container you pass in are billed separately, per GB stored and per operation, and every deployment package read and write counts. Application Insights, if configured through app settings, bills per GB ingested.
- Risk: `public_network_access_enabled` defaults to `false`, so the app is not reachable from the internet and deployments or tests from outside the network will fail until private connectivity exists. The storage access key is passed as a connection string and kept in state, so protect the state. Changing the runtime name, storage container, or plan can force replacement of the app.
