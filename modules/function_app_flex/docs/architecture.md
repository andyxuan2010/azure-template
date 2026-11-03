# Flex Consumption Function App architecture

The module owns one `azurerm_function_app_flex_consumption` resource. It consumes an existing Linux Flex Consumption App Service Plan, an existing blob deployment container, and the caller's runtime package. It does not create the plan, storage account, blob container, package artifact, resource group, VNet, private DNS, monitoring workspace, or RBAC assignments.

## Resource boundary

```text
Existing FC1 App Service Plan + blob deployment container
                         |
                         v
       azurerm_function_app_flex_consumption.this
         |- runtime and package storage
         |- instance memory and scale controls
         |- optional managed identity and VNet integration
         `- inherited and caller-supplied tags
```

Flex Consumption is a distinct hosting model from the existing Linux/Windows Function App module. It requires Flex runtime metadata and blob-container deployment storage, and it uses Flex-specific controls such as instance memory, maximum instances, HTTP concurrency, and always-ready instances.

## Hosting and storage dependencies

The supplied `service_plan_id` must reference a Linux App Service Plan using the `FC1` SKU. The supplied `storage_container_endpoint` must identify the blob container used for deployment content. The module supports storage access-key authentication or a user-assigned managed identity. When identity-based storage authentication is used, that identity must also be assigned to the Function App.

## Networking, identity, and security

- Public network access is disabled by default; enable it only when the ingress design requires it.
- HTTPS-only traffic is enabled by default.
- Managed identity is opt-in and receives no RBAC assignments from this module.
- Regional VNet integration is supported through `virtual_network_subnet_id`; subnet, routing, DNS, and private access ownership remain outside this module.
- Storage access keys, application settings, and Application Insights credentials are sensitive inputs and should come from protected secret handling.

See the module [README](../README.md) for inputs, outputs, examples, and validation commands.
