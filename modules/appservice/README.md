# App Service Module

Provision Azure App Service with authentication, networking, private endpoints, RBAC, and deployment-center options.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.61.0`
- Inputs: 78
- Outputs: 18
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_app_service_certificate_binding`, `azurerm_app_service_custom_hostname_binding`, `azurerm_app_service_managed_certificate`, `azurerm_app_service_source_control`, `azurerm_linux_web_app`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports private endpoint configuration using either direct IDs or lookup inputs where exposed.
- Supports optional diagnostic settings to Log Analytics.
- Supports optional workspace-based Application Insights creation with automatic telemetry app settings.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "appservice" {
  source = "./modules/appservice"

  app_name = "app-example-001"
  app_service_plan_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  location = "eastus"
  resource_group_name = "rg-example-prod"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Key Inputs

- `app_name`: The name of this Web App. `string` (required)
- `app_service_plan_id`: The ID of the App Service plan to host this Web App on. `string` (required)
- `app_command_line`: Optional startup command for Linux Web Apps, for example `gunicorn --bind=0.0.0.0 --timeout 600 app:app`. `string` (default: `null`)
- `location`: The location to create the resources in. `string` (required)
- `resource_group_name`: The name of the resource group to create the resources in. `string` (required)
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive Contributor access to the Web App. `list(string)` (default: [])
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access to the Web App. `list(string)` (default: [])
- `enable_application_insights`: Whether to create an Application Insights resource for this Web App and inject the standard telemetry app settings. `bool` (default: false)
- `application_insights_workspace_id`: Optional Log Analytics workspace resource ID for the Application Insights resource. When empty, the module falls back to `log_analytics_workspace_id`. `string` (default: "")
- `enable_private_endpoint`: Whether to create a private endpoint for the Web App (sites). Requires PremiumV2/PremiumV3 or higher. When enabled, consider setting public_network_access_enabled = false for isolation. `bool` (default: false)
- `log_analytics_workspace_id`: The ID of the Log Analytics workspace to send diagnostics to. `string` (default: "")
- `tags`: A map of tags to assign to the resources. `map(string)` (default: {})

## Runtime Notes

- For Windows App Service Node runtimes, Terraform `application_stack.node_version` is currently limited to `~14`, `~16`, `~18`, `~20`, and `~22`.
- If you need Node 24, use Linux App Service and set the runtime with the Linux stack value such as `24-lts`.
- If you also set `WEBSITE_NODE_DEFAULT_VERSION` in app settings, keep it aligned with the runtime version configured in `application_stack`.
- For Linux Python apps that need an explicit startup command, set `app_command_line`, for example `gunicorn --bind=0.0.0.0 --timeout 600 app:app`.

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group principal ID.
- `app_id`: The ID of this Web App.
- `app_name`: The name of this Web App.
- `application_insights_id`: Resource ID of the Application Insights resource created for this Web App, if enabled.
- `application_insights_name`: Name of the Application Insights resource created for this Web App, if enabled.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group principal ID.
- `custom_domain_verification_id`: The identifier used by App Service to perform domain ownership verification via DNS TXT record.
- `default_hostname`: The default hostname of this Web App.
- `diagnostics_enabled`: Whether any diagnostic log or metric categories were enabled for the app service
- `identity_principal_id`: The principal ID of the system-assigned identity of this Web App. This value will be null if the system-assigned identity is disabled.
- `identity_tenant_id`: The tenant ID of the system-assigned identity of this Web App. This value will be null if the system-assigned identity is disabled.
- `merged_tags`: Final merged tags applied to resources

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
