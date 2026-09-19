# Basic Static Web App Example

Creates an Azure Static Web App using the Free plan defaults (`sku_tier = "Free"` and `sku_size = "Free"`) in an existing resource group. Repository deployment integration, managed identity, and basic authentication remain disabled unless explicitly configured.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-platform-dev"
```

Applying this example creates a billable Azure resource even when the Static Web App SKU is Free. Confirm the resource group and region before applying.
