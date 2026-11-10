# Modules Index

This index reflects the current contents of `modules/` and points to the root and module assets used for documentation, examples, and Terraform tests.

## Root Docs

- [README.md](../../README.md)
- [Module Usage and Dependencies](module-usage-and-dependencies.md)
- [NAMING_CONVENTION.md](../60-security-governance/naming-convention.md)
- [Terraform Module Documentation Standard](module-documentation-standard.md)
- [ROOT_LEVEL_MODULES_GUIDE.md](root-level-modules-guide.md)
- [TAGGING_STANDARD.md](../60-security-governance/tagging-standard.md)
- [Validation Summary](../70-validation/validation-summary.md)
- [DevSecOps and GitOps Controls](../60-security-governance/devsecops-gitops.md)
- [Shared Runner Hygiene](../40-pipelines/shared-runner-hygiene.md)
- [GitHub Actions Terraform Pipeline](../40-pipelines/github-actions-pipeline.md)
- [PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md](../10-architecture/private-endpoint-private-dns.md)
- [AKS_AUTHENTICATION_KUBELOGIN.md](../30-deployment/aks-authentication-kubelogin.md)

## Module Docs, Examples, And Tests

| Module | README | Examples | Tests |
|---|---|---|---|
| `ado_service_connection_acr` | [README.md](../../modules/ado_service_connection_acr/README.md) | [examples/](../../modules/ado_service_connection_acr/examples/) | [tests/unit.tftest.hcl](../../modules/ado_service_connection_acr/tests/unit.tftest.hcl), [federation](../../modules/ado_service_connection_acr/tests/federation.tftest.hcl) |
| `ado_service_connection_azurerm` | [README.md](../../modules/ado_service_connection_azurerm/README.md) | [examples/](../../modules/ado_service_connection_azurerm/examples/) | [tests/unit.tftest.hcl](../../modules/ado_service_connection_azurerm/tests/unit.tftest.hcl), [federation](../../modules/ado_service_connection_azurerm/tests/federation.tftest.hcl) |
| `acr` | [README.md](../../modules/acr/README.md) | [examples/](../../modules/acr/examples/) | [unit](../../modules/acr/tests/unit.tftest.hcl), [integration](../../modules/acr/tests/integration.tftest.hcl) |
| `adf` | [README.md](../../modules/adf/README.md) | [examples/](../../modules/adf/examples/) | [unit](../../modules/adf/tests/unit.tftest.hcl), [integration](../../modules/adf/tests/integration.tftest.hcl) |
| `aks` | [README.md](../../modules/aks/README.md) | [examples/](../../modules/aks/examples/) | [tests/unit.tftest.hcl](../../modules/aks/tests/unit.tftest.hcl) |
| `applicationgateway` | [README.md](../../modules/application_gateway/README.md) | [examples/](../../modules/application_gateway/examples/) | [tests/unit.tftest.hcl](../../modules/application_gateway/tests/unit.tftest.hcl) |
| `appregistration` | [README.md](../../modules/app_registration/README.md) | [examples/](../../modules/app_registration/examples/) | [tests/unit.tftest.hcl](../../modules/app_registration/tests/unit.tftest.hcl) |
| `appservice` | [README.md](../../modules/app_service/README.md) | [examples/](../../modules/app_service/examples/) | [tests/unit.tftest.hcl](../../modules/app_service/tests/unit.tftest.hcl) |
| `appserviceplan` | [README.md](../../modules/app_service_plan/README.md) | [examples/](../../modules/app_service_plan/examples/) | [tests/unit.tftest.hcl](../../modules/app_service_plan/tests/unit.tftest.hcl) |
| `automationaccount` | [README.md](../../modules/automation_account/README.md) | [examples/](../../modules/automation_account/examples/) | [tests/unit.tftest.hcl](../../modules/automation_account/tests/unit.tftest.hcl) |
| `availabilityset` | [README.md](../../modules/availability_set/README.md) | [examples/](../../modules/availability_set/examples/) | [tests/unit.tftest.hcl](../../modules/availability_set/tests/unit.tftest.hcl) |
| `bastion` | [README.md](../../modules/bastion/README.md) | [examples/](../../modules/bastion/examples/) | [tests/unit.tftest.hcl](../../modules/bastion/tests/unit.tftest.hcl) |
| `azure_ai_service` | [README.md](../../modules/azure_ai_service/README.md) | [examples/](../../modules/azure_ai_service/examples/) | [tests/unit.tftest.hcl](../../modules/azure_ai_service/tests/unit.tftest.hcl) |
| `azure_ai_search` | [README.md](../../modules/azure_ai_search/README.md) | [examples/](../../modules/azure_ai_search/examples/) | [tests/unit.tftest.hcl](../../modules/azure_ai_search/tests/unit.tftest.hcl) |
| `containerapp` | [README.md](../../modules/container_app/README.md) | [examples/](../../modules/container_app/examples/) | [tests/unit.tftest.hcl](../../modules/container_app/tests/unit.tftest.hcl) |
| `cosmosdb` | [README.md](../../modules/cosmos_db/README.md) | [examples/](../../modules/cosmos_db/examples/) | [tests/unit.tftest.hcl](../../modules/cosmos_db/tests/unit.tftest.hcl) |
| `customrole` | [README.md](../../modules/custom_role/README.md) | [examples/](../../modules/custom_role/examples/) | [tests/unit.tftest.hcl](../../modules/custom_role/tests/unit.tftest.hcl) |
| `databricks` | [README.md](../../modules/databricks/README.md) | [examples/](../../modules/databricks/examples/) | [tests/unit.tftest.hcl](../../modules/databricks/tests/unit.tftest.hcl) |
| `enterpriseapplication` | [README.md](../../modules/enterprise_application/README.md) | [examples/](../../modules/enterprise_application/examples/) | [tests/unit.tftest.hcl](../../modules/enterprise_application/tests/unit.tftest.hcl) |
| `eventgridsystemtopic` | [README.md](../../modules/event_grid_system_topic/README.md) | [examples/](../../modules/event_grid_system_topic/examples/) | [tests/unit.tftest.hcl](../../modules/event_grid_system_topic/tests/unit.tftest.hcl) |
| `eventhub` | [README.md](../../modules/event_hub/README.md) | [examples/](../../modules/event_hub/examples/) | [tests/unit.tftest.hcl](../../modules/event_hub/tests/unit.tftest.hcl) |
| `firewall` | [README.md](../../modules/firewall/README.md) | [examples/](../../modules/firewall/examples/) | [tests/unit.tftest.hcl](../../modules/firewall/tests/unit.tftest.hcl) |
| `fortigate` | [README.md](../../modules/fortigate/README.md) | [examples/](../../modules/fortigate/examples/) | [tests/unit.tftest.hcl](../../modules/fortigate/tests/unit.tftest.hcl) |
| `frontdoor` | [README.md](../../modules/front_door/README.md) | [examples/](../../modules/front_door/examples/) | [tests/unit.tftest.hcl](../../modules/front_door/tests/unit.tftest.hcl) |
| `functionapp` | [README.md](../../modules/function_app/README.md) | [examples/](../../modules/function_app/examples/) | [tests/unit.tftest.hcl](../../modules/function_app/tests/unit.tftest.hcl) |
| `functionappflex` | [README.md](../../modules/function_app_flex/README.md) | [examples/](../../modules/function_app_flex/examples/) | [tests/unit.tftest.hcl](../../modules/function_app_flex/tests/unit.tftest.hcl) |
| `keyvault` | [README.md](../../modules/key_vault/README.md) | [examples/](../../modules/key_vault/examples/) | [tests/unit.tftest.hcl](../../modules/key_vault/tests/unit.tftest.hcl) |
| `linuxvm` | [README.md](../../modules/linux_vm/README.md) | [examples/](../../modules/linux_vm/examples/) | [tests/unit.tftest.hcl](../../modules/linux_vm/tests/unit.tftest.hcl) |
| `loadbalancer` | [README.md](../../modules/load_balancer/README.md) | [examples/](../../modules/load_balancer/examples/) | [tests/unit.tftest.hcl](../../modules/load_balancer/tests/unit.tftest.hcl) |
| `loganalytics` | [README.md](../../modules/log_analytics/README.md) | [examples/](../../modules/log_analytics/examples/) | [tests/unit.tftest.hcl](../../modules/log_analytics/tests/unit.tftest.hcl) |
| `logicapp` | [README.md](../../modules/logic_app/README.md) | [examples/](../../modules/logic_app/examples/) | [tests/unit.tftest.hcl](../../modules/logic_app/tests/unit.tftest.hcl) |
| `managedidentity` | [README.md](../../modules/managed_identity/README.md) | [examples/](../../modules/managed_identity/examples/) | [tests/unit.tftest.hcl](../../modules/managed_identity/tests/unit.tftest.hcl) |
| `managementgroups` | [README.md](../../modules/management_groups/README.md) | [examples/](../../modules/management_groups/examples/) | [tests/unit.tftest.hcl](../../modules/management_groups/tests/unit.tftest.hcl) |
| `nat_gateway` | [README.md](../../modules/nat_gateway/README.md) | [examples/](../../modules/nat_gateway/examples/) | [tests/unit.tftest.hcl](../../modules/nat_gateway/tests/unit.tftest.hcl) |
| `nsg` | [README.md](../../modules/nsg/README.md) | [examples/](../../modules/nsg/examples/) | [tests/unit.tftest.hcl](../../modules/nsg/tests/unit.tftest.hcl) |
| `openai` | [README.md](../../modules/openai/README.md) | [examples/](../../modules/openai/examples/) | [tests/unit.tftest.hcl](../../modules/openai/tests/unit.tftest.hcl) |
| `policy` | [README.md](../../modules/policy/README.md) | [examples/](../../modules/policy/examples/) | [tests/unit.tftest.hcl](../../modules/policy/tests/unit.tftest.hcl) |
| `private_dns` | [README.md](../../modules/private_dns/README.md) | [examples/](../../modules/private_dns/examples/) | [tests/unit.tftest.hcl](../../modules/private_dns/tests/unit.tftest.hcl) |
| `private_endpoint` | [README.md](../../modules/private_endpoint/README.md) | [examples/](../../modules/private_endpoint/examples/) | [tests/unit.tftest.hcl](../../modules/private_endpoint/tests/unit.tftest.hcl) |
| `recovery_services_vault` | [README.md](../../modules/recovery_services_vault/README.md) | [examples/](../../modules/recovery_services_vault/examples/) | [tests/unit.tftest.hcl](../../modules/recovery_services_vault/tests/unit.tftest.hcl) |
| `rg` | [README.md](../../modules/rg/README.md) | [examples/](../../modules/rg/examples/) | [tests/unit.tftest.hcl](../../modules/rg/tests/unit.tftest.hcl) |
| `roleassignments` | [README.md](../../modules/role_assignments/README.md) | [examples/](../../modules/role_assignments/examples/) | [tests/unit.tftest.hcl](../../modules/role_assignments/tests/unit.tftest.hcl) |
| `route_table` | [README.md](../../modules/route_table/README.md) | [examples/](../../modules/route_table/examples/) | [tests/unit.tftest.hcl](../../modules/route_table/tests/unit.tftest.hcl) |
| `servicebus` | [README.md](../../modules/service_bus/README.md) | [examples/](../../modules/service_bus/examples/) | [tests/unit.tftest.hcl](../../modules/service_bus/tests/unit.tftest.hcl) |
| `sqldb` | [README.md](../../modules/sql_db/README.md) | [examples/](../../modules/sql_db/examples/) | [tests/unit.tftest.hcl](../../modules/sql_db/tests/unit.tftest.hcl) |
| `sqlmi` | [README.md](../../modules/sql_mi/README.md) | [examples/](../../modules/sql_mi/examples/) | [tests/unit.tftest.hcl](../../modules/sql_mi/tests/unit.tftest.hcl) |
| `sqlmi_db` | [README.md](../../modules/sql_mi_db/README.md) | [examples/](../../modules/sql_mi_db/examples/) | [tests/unit.tftest.hcl](../../modules/sql_mi_db/tests/unit.tftest.hcl) |
| `sqlvm` | [README.md](../../modules/sql_vm/README.md) | [examples/](../../modules/sql_vm/examples/) | [tests/unit.tftest.hcl](../../modules/sql_vm/tests/unit.tftest.hcl) |
| `storageaccount` | [README.md](../../modules/storage_account/README.md) | [examples/](../../modules/storage_account/examples/) | [tests/unit.tftest.hcl](../../modules/storage_account/tests/unit.tftest.hcl) |
| `staticwebapp` | [README.md](../../modules/static_web_app/README.md) | [examples/](../../modules/static_web_app/examples/) | [tests/unit.tftest.hcl](../../modules/static_web_app/tests/unit.tftest.hcl) |
| `subnet` | [README.md](../../modules/subnet/README.md) | [examples/](../../modules/subnet/examples/) | [tests/unit.tftest.hcl](../../modules/subnet/tests/unit.tftest.hcl) |
| `subscription_vending` | [README.md](../../modules/subscription_vending/README.md) | [examples/](../../modules/subscription_vending/examples/) | [tests/unit.tftest.hcl](../../modules/subscription_vending/tests/unit.tftest.hcl) |
| `vnet` | [README.md](../../modules/vnet/README.md) | [examples/](../../modules/vnet/examples/) | [tests/unit.tftest.hcl](../../modules/vnet/tests/unit.tftest.hcl) |
| `winvm` | [README.md](../../modules/windows_vm/README.md) | [examples/](../../modules/windows_vm/examples/) | [tests/unit.tftest.hcl](../../modules/windows_vm/tests/unit.tftest.hcl) |

Notes:
- The module source path used throughout this repository is `./modules/<name>` when calling modules from the repo root.
- Root-wired modules have a matching root module block, `features` flag, `module_plan_enabled` toggle, root input variables, and `terraform.tfvars` sample values.
- `availabilityset`, `bastion`, `containerapp`, `fortigate`, `frontdoor`, `loadbalancer`, `nat_gateway`, `private_endpoint`, and `recovery_services_vault` are root-wired and participate in the CI module matrix.
- All 54 modules use the normalized documentation and test naming standard in the [Terraform Module Documentation Standard](module-documentation-standard.md).
- Some modules ship additional deep-dive docs beside the primary assets linked above.
- Default CI validates modules through the root harness. Review every module test to determine whether it uses mocked or real providers and whether it can create resources.

- Azure DevOps service connection modules are standalone bootstrap modules. Their examples and mocked tests run independently of the Azure workload root harness.
