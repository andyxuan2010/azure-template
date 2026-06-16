# Azure AI Service Quick Reference

Purpose: Provision a secure, standardized Azure AI Services account with optional private networking, diagnostics, identity, RBAC, Responsible AI policies, and deployments.

## Required Inputs

- `resource_group_name`: target resource group name.

## Common Inputs

- `location`: Azure region. Leave empty to read the resource group location.
- `name`: explicit account name. Leave empty for generated naming.
- `workload_name`, `app_env`, `location_code`, `instance`, `use_random_suffix`: generated naming controls.
- `kind`, `sku_name`: Cognitive account kind and SKU.
- `public_network_access_enabled`: defaults to `false`.
- `local_auth_enabled`: defaults to `false`.
- `system_managed_identity_enabled`, `identity_ids`, `identity`: managed identity controls.
- `customer_managed_key`, `storage`, `network_acls`, `network_injection`: enterprise integration controls.
- `enable_private_endpoint`, `private_endpoint_subnet_id`, `private_dns_zone_ids`: inbound private endpoint configuration.
- `project_management_enabled`: AI Foundry project management support.
- `rai_policies`, `deployments`: Responsible AI and model deployment resources.
- `app_admin_group`, `app_user_group`, `role_assignments`: RBAC controls.
- `enable_diagnostics`, `log_analytics_workspace_id`, `diagnostic_storage_account_id`, `diagnostic_eventhub_authorization_rule_id`: diagnostic settings.

## Primary Outputs

- `id`, `name`, `resource_group_name`, `location`, `endpoint`
- `kind`, `sku_name`, `custom_subdomain_name`
- `identity`, `identity_type`, `principal_id`, `tenant_id`
- `private_endpoint_id`, `private_endpoint_name`
- `rai_policy_ids`, `deployment_ids`
- `diagnostics_enabled`, `diagnostic_setting_id`
- `role_assignment_ids`, `role_assignment_count`
- `tags`

## Validation Commands

```powershell
terraform fmt -check -recursive
terraform validate
terraform test
```
