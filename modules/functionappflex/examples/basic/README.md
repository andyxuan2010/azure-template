# Basic Flex Consumption Function App Example

Creates an Azure Function App using the Flex Consumption resource with an existing Linux `FC1` App Service Plan, an existing blob deployment container, and Python 3.11. The plan, storage account, blob container, and package deployment are not created by this example.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-functions-dev" -var="service_plan_id=/subscriptions/<subscription-id>/resourceGroups/rg-functions-dev/providers/Microsoft.Web/serverFarms/asp-functions-flex-dev" -var="storage_container_endpoint=https://stfunctionsdev.blob.core.windows.net/function-packages" -var="storage_access_key=<secret>"
```

The storage key is sensitive. Supply it through a protected variable or secret store and do not commit it to source control.
