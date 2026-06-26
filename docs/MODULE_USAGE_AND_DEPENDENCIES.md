# Module Usage and Dependencies

This document summarizes the modules under `modules/`, what each module is for, how to use it correctly, which examples to start from, and what upstream dependencies must already exist.

## How to Use Modules Properly

1. Create shared foundation resources first: resource groups, virtual networks/subnets, private DNS zones, storage, and key vaults.
2. Create hosting or platform resources next: App Service Plans, SQL Managed Instances, Automation Accounts, ACR, and AKS.
3. Create dependent workloads after their platform is ready: App Services, Function Apps, SQL MI databases, VMs, and ADF private integrations.
4. Prefer wiring modules together through outputs instead of copying resource IDs into `terraform.tfvars`.
5. Use the module `examples/` folders or each module `EXAMPLES.md` as the starting point for new deployments.
6. For quick syntax and provider checks, run `terraform init -backend=false` and `terraform validate` in the module directory.
7. For the safest CI-like validation, enable the module through the repo root harness and run a root `terraform plan` so aliased providers and caller wiring are exercised.
8. Check each `tests/live.tftest.hcl` before running `terraform test`. The App Service Plan, App Service, Function App, and Logic App tests use mock providers and plan-only runs; older fixture-style tests can create billable Azure resources if reintroduced.

Root-wired modules, including `fortigate`, can be enabled through `features.enable_<module>` for high-level runs or `module_plan_enabled.<module>` for focused one-module plans. Their live settings are configured through module-specific root variables in `variables.tf` and `terraform.tfvars`. `loadbalancer` remains a standalone child module without root-harness enablement.

## Dependency Matrix

| Module | Primary use case | Required dependencies | Common optional dependencies | Example entry point |
| --- | --- | --- | --- | --- |
| `acr` | Private or public Azure Container Registry | Existing resource group | Private endpoint subnet, private DNS zone, Log Analytics workspace | `modules/acr/EXAMPLES.md` |
| `adf` | Azure Data Factory with managed or self-hosted integration runtime patterns | Existing resource group; shared IaC resource group, key vault, and storage account | Virtual network/subnet, jump VM for SHIR, private DNS zone, repo integration | `modules/adf/EXAMPLES.md` |
| `aks` | AKS cluster for container workloads | Existing resource group | Subnet for node pool, private DNS zone for private cluster, Log Analytics workspace | `modules/aks/EXAMPLES.md` |
| `appregistration` | Microsoft Entra application and optional service principal | None beyond provider access | Key Vault to store client secret | `modules/appregistration/EXAMPLES.md` |
| `appservice` | Linux or Windows Web App | Existing resource group; existing App Service Plan | Subnet for VNet integration, private endpoint subnet, private DNS zone, Entra app registration for auth, Log Analytics workspace | `modules/appservice/examples/` |
| `appserviceplan` | Shared hosting plan for Web Apps and Function Apps | Existing resource group | Log Analytics workspace, autoscale consumers | `modules/appserviceplan/EXAMPLES.md` |
| `applicationgateway` | Azure Application Gateway v2 with public frontend, listeners, backend pools, and optional WAF | Existing resource group; dedicated Application Gateway subnet | Backend application targets, TLS certificates, WAF policy, user-assigned identity | `modules/applicationgateway/EXAMPLES.md` |
| `automationaccount` | Azure Automation Account with RBAC and optional private access | Existing resource group | Private endpoint subnet, private DNS zone, role assignment target scopes | `modules/automationaccount/EXAMPLES.md` |
| `azure_ai_service` | Azure AI Services account for multi-service AI workloads | Existing resource group | Private endpoint subnet, private DNS zone, Key Vault, managed identity, Log Analytics workspace, RBAC groups | `modules/azure_ai_service/EXAMPLES.md` |
| `azure_ai_search` | Azure AI Search service for indexing, retrieval, vector search, and RAG backends | Existing resource group | Private endpoint subnet, private DNS zone, managed identity, Log Analytics workspace, RBAC groups | `modules/azure_ai_search/EXAMPLES.md` |
| `cosmosdb` | Azure Cosmos DB account with SQL API databases and containers | Existing resource group | Private endpoint subnet, private DNS zone, Key Vault, managed identity, Log Analytics workspace, RBAC groups | `modules/cosmosdb/EXAMPLES.md` |
| `databricks` | Azure Databricks workspace for lakehouse and analytics workloads | Existing resource group | VNet injection subnets and NSG associations, Log Analytics workspace, managed identity or access connector, RBAC groups | `modules/databricks/EXAMPLES.md` |
| `enterpriseapplication` | Microsoft Entra Enterprise Application service principal, assignments, and optional Application Proxy publishing | Existing app registration client ID | App role assignment targets, Graph beta Application Proxy inputs | `modules/enterpriseapplication/EXAMPLES.md` |
| `eventhub` | Event Hubs namespace with optional hubs and auth rules | Existing resource group | Private endpoint subnet, private DNS zone, Log Analytics workspace, RBAC groups | `modules/eventhub/EXAMPLES.md` |
| `firewall` | Azure Firewall with policy and optional rule collections | Existing resource group; existing `AzureFirewallSubnet` | Route tables, hub VNet, monitoring workspace | `modules/firewall/EXAMPLES.md` |
| `fortigate` | Single or active-passive FortiGate-VM deployment | Existing resource group and interface subnets, or an existing VNet when module-created subnets are enabled | Standard Load Balancers, HA/management subnets, FortiManager, FortiAnalyzer, route tables | `modules/fortigate/EXAMPLES.md` |
| `managedidentity` | User-assigned managed identity with optional workload federation | Existing resource group | Federated credentials, RBAC target scopes | `modules/managedidentity/EXAMPLES.md` |
| `managementgroups` | Management group hierarchy for enterprise governance | Tenant-level permissions | Subscription placement | `modules/managementgroups/EXAMPLES.md` |
| `nsg` | Network Security Group and associations | Existing resource group | VNet subnets, NICs | `modules/nsg/EXAMPLES.md` |
| `loganalytics` | Log Analytics workspace for central platform monitoring | Existing resource group | Diagnostics-enabled modules, Sentinel, monitoring solutions | `modules/loganalytics/EXAMPLES.md` |
| `openai` | Azure OpenAI account with optional model deployments | Existing resource group | Private endpoint subnet, private DNS zone, Key Vault, managed identity, Log Analytics workspace, RBAC groups | `modules/openai/EXAMPLES.md` |
| `policy` | Custom policy definition and optional assignment | Optional management group scope | Subscription or resource group assignment scopes | `modules/policy/EXAMPLES.md` |
| `private_dns` | Private DNS zones, VNet links, and records | Existing resource group | VNet IDs, private endpoint-enabled services | `modules/private_dns/EXAMPLES.md` |
| `roleassignments` | Generic RBAC assignments across Azure scopes | Scope IDs and target principals | Management groups, subscriptions, resource groups, identities | `modules/roleassignments/EXAMPLES.md` |
| `route_table` | User-defined routes and subnet associations | Existing resource group | VNet subnets, Azure Firewall | `modules/route_table/EXAMPLES.md` |
| `servicebus` | Service Bus namespace with queues, topics, and subscriptions | Existing resource group | Private endpoint subnet, private DNS zone, network rules, Log Analytics workspace, RBAC groups | `modules/servicebus/EXAMPLES.md` |
| `subscription_vending` | Subscription bootstrap with MG placement and provider registration | Existing or newly created subscription context | Management groups, bootstrap resource groups, provider registration list | `modules/subscription_vending/EXAMPLES.md` |
| `functionapp` | Linux or Windows Function App | Existing resource group; existing App Service Plan; existing Storage Account | Subnet for VNet integration, private endpoint subnet, private DNS zone, Log Analytics workspace, user-assigned identity | `modules/functionapp/EXAMPLES.md` |
| `keyvault` | Key Vault with RBAC, firewall, and private endpoint options | Existing resource group; tenant ID | Subnets for network ACLs or private endpoint, private DNS zone, Log Analytics workspace | `modules/keyvault/EXAMPLES.md` |
| `loadbalancer` | Azure Load Balancer with frontend IP configurations, backend pools, probes, and rules | Existing resource group; public IP or subnet for frontend configuration | Backend pool members, health probes, NSG rules | `modules/loadbalancer/README.md` |
| `linuxvm` | Linux VM built against the shared IaC foundation | Existing application resource group, VNet/subnet, shared IaC key vault, shared IaC storage account | Domain join services, Entra SSH login, diagnostics workspace | `modules/linuxvm/EXAMPLES.md` |
| `logicapp` | Logic App Standard on App Service infrastructure | Existing resource group; existing App Service Plan; existing Storage Account | Subnet for VNet integration, private endpoint subnet, private DNS zone, Log Analytics workspace, user-assigned identity | `modules/logicapp/EXAMPLES.md` |
| `rg` | Resource group with optional lock and RBAC | None | None | `modules/rg/EXAMPLES.md` |
| `sqldb` | Azure SQL logical server and single database | Existing application resource group; shared IaC resource group, key vault, and storage account inputs used by current pattern | Private endpoint subnet, diagnostics | `modules/sqldb/EXAMPLES.md` |
| `sqlmi` | Azure SQL Managed Instance | Existing resource group; dedicated delegated subnet | Diagnostics workspace, DNS zone partner instance, user-assigned identities | `modules/sqlmi/EXAMPLES.md` |
| `sqlmi_db` | Database on an existing SQL Managed Instance | Existing SQL Managed Instance | Diagnostics workspace | `modules/sqlmi_db/EXAMPLES.md` |
| `storageaccount` | General-purpose storage account with networking and RBAC | Existing resource group | Virtual network subnet rules, private endpoint subnet, private DNS zones, Log Analytics workspace | `modules/storageaccount/EXAMPLES.md` |
| `vnet` | Virtual network and subnets | Existing resource group | DDoS protection plan, Log Analytics workspace | `modules/vnet/EXAMPLES.md` |
| `winvm` | Windows VM built against the shared IaC foundation | Existing application resource group, VNet/subnet, shared IaC key vault, shared IaC storage account | Domain join services, ADF SHIR integration, diagnostics workspace | `modules/winvm/EXAMPLES.md` |

## Common Dependency Chains

- `rg` -> `vnet` -> `storageaccount` / `keyvault` -> `linuxvm` or `winvm`
- `managementgroups` -> `policy`
- `managementgroups` -> `subscription_vending`
- `subscription_vending` -> `rg` -> `loganalytics`
- `rg` -> `private_dns`
- `rg` -> dedicated `vnet` subnet -> `applicationgateway` -> backend application targets
- `rg` -> `vnet` -> `firewall` -> `route_table`
- `rg` -> `vnet` -> `fortigate` -> `route_table`
- `managedidentity` / `managementgroups` / `subscriptions` -> `roleassignments`
- `rg` -> `azure_ai_service`
- `rg` -> `azure_ai_search`
- `rg` -> `cosmosdb`
- `appregistration` -> `enterpriseapplication`
- `rg` -> public IP or `vnet` subnet -> `loadbalancer` -> backend targets
- `rg` -> `eventhub`
- `rg` -> `openai`
- `rg` -> `vnet` -> `nsg` -> `databricks`
- `rg` -> `managedidentity` -> `functionapp` / `appservice` / `aks`
- `rg` -> `appserviceplan` + `storageaccount` -> `logicapp`
- `rg` -> `vnet` -> `nsg`
- `rg` -> `vnet` -> `servicebus`
- `rg` -> `appserviceplan` -> `appservice`
- `rg` -> `appserviceplan` + `storageaccount` -> `functionapp`
- `rg` -> delegated `vnet` subnet -> `sqlmi` -> `sqlmi_db`
- `rg` -> `vnet` + `keyvault` + shared IaC storage -> `adf`

## Module-by-Module Guidance

### `acr`

Use this module when the workload needs a dedicated Azure Container Registry with optional private access. Start with a basic registry, then add network rules or a private endpoint only after the subnet and private DNS zone already exist.

### `adf`

Use this module for Data Factory deployments that follow the repository's shared-IaC pattern. Supply the shared key vault and storage inputs from existing platform modules or shared environment resources, and only enable SHIR or private endpoints when the network and host VM are already provisioned.

### `aks`

Use this module when the cluster should be managed as a reusable platform component. If you enable a private cluster, create or identify the private DNS zone and the node subnet first and pass those IDs directly rather than relying on manual lookups later.

When `azure_rbac_enabled = true`, remember that Azure management-plane roles such as `Contributor` do not automatically grant `kubectl` access to the cluster. If the Terraform execution identity needs AKS data-plane access, use `terraform_execution_aks_role` in `modules/aks` to assign an AKS Kubernetes RBAC cluster role.

### `appregistration`

Use this module to standardize Entra app creation for application authentication. If you also create a client secret, store it in Key Vault and pass `key_vault_id` instead of leaving the secret unmanaged in output-only form.

### `appservice`

Use this module for web workloads that run on an existing App Service Plan. The correct pattern is `module.appservice.app_service_plan_id = module.appserviceplan.id`; avoid hard-coded plan IDs in both workload code and tests.

### `appserviceplan`

Use this module to provide shared hosting capacity for multiple web apps or function apps. Create the plan first, choose an OS/SKU that matches the downstream workload, and pass `module.appserviceplan.id` to consumers.

### `applicationgateway`

Use this module when the landing zone needs an L7 load balancer or WAF entry point in front of web workloads. Create a dedicated subnet for the gateway first, then wire backend pool targets, backend HTTP settings, listeners, and routing rules from real downstream application endpoints rather than hard-coded placeholder values.

### `automationaccount`

Use this module for runbooks, schedules, and worker scenarios that need a managed automation control plane. Only enable private endpoints after the private subnet and private DNS requirements are already satisfied.

### `azure_ai_service`

Use this module when the platform needs a shared Azure AI Services endpoint for multi-service AI capabilities such as vision, speech, or document processing. Add private networking and RBAC only after the network foundation and consumer identities already exist.

### `azure_ai_search`

Use this module when the platform needs a dedicated Azure AI Search service for indexing, retrieval APIs, semantic ranking, or vector-backed RAG patterns. Add private networking, firewall rules, and RBAC only after the network foundation and consumer identities already exist.

### `cosmosdb`

Use this module when the workload needs an Azure Cosmos DB account with SQL API databases and containers. Prefer private endpoint access, Entra ID RBAC, and autoscale throughput for production workloads unless a specific legacy client or predictable workload pattern requires otherwise.

### `databricks`

Use this module when the platform needs a reusable Azure Databricks workspace for data engineering, lakehouse, notebook, or ML workloads. If you enable VNet injection, create the target VNet, subnets, and NSG associations first and pass those values directly rather than reconstructing them later.

### `enterpriseapplication`

Use this module when an app registration needs an owned service principal, assignments, or Application Proxy publishing. Prefer passing `application_id` from the `appregistration` module output, and treat Application Proxy inputs carefully because they use Microsoft Graph beta behavior.

### `eventhub`

Use this module when the workload needs a central event-streaming namespace with one or more hubs and optional namespace authorization rules. Enable private endpoint access only after the target subnet and private DNS zone are ready.

### `firewall`

Use this module when the landing zone needs centralized north-south or east-west traffic control. Create the hub VNet and `AzureFirewallSubnet` first, then pass the firewall private IP to `route_table` modules that should force egress through the firewall.

### `fortigate`

Use this module for a private single FortiGate-VM or a zone-aware active-passive pair. Prepare interface subnets and static addresses first, keep management private, and treat FortiOS clustering, routing, policy, licensing, and probe responses as separate appliance configuration.

### `managedidentity`

Use this module when workloads need a reusable user-assigned identity. Create it before attaching it to app, function, AKS, or automation modules, and add federated credentials when CI/CD or workload identity federation is required.

### `managementgroups`

Use this module to create or extend the enterprise management group hierarchy. This should usually be applied before policy assignment and before subscription vending logic.

### `nsg`

Use this module to standardize NSG creation and optionally own subnet or NIC association lifecycle. Feed subnet IDs from the `vnet` module rather than reconstructing them manually.

### `loganalytics`

Use this module to create the shared monitoring workspace before enabling diagnostics in other modules. The normal landing zone pattern is `rg -> loganalytics -> diagnostics-enabled resources`.

### `openai`

Use this module when the workload needs an Azure OpenAI account and optionally managed model deployments. Keep deployments explicit in code and only enable model SKUs and versions that are actually available in the target region and subscription quota.

### `policy`

Use this module for custom governance controls and optional assignment ownership. In enterprise landing zones, the normal pattern is `managementgroups -> policy assignment`.

### `private_dns`

Use this module to own private DNS zones and VNet links centrally. Create the zone once, link the hub or shared VNet, and then hand the zone ID to private-endpoint-capable modules.

### `roleassignments`

Use this module when RBAC needs to be managed outside individual resource modules. It is the better fit for subscription, management group, and cross-resource landing zone access patterns.

### `route_table`

Use this module to control subnet routing explicitly. The normal landing zone pattern is `vnet -> firewall -> route_table -> workload subnets`.

### `servicebus`

Use this module when the workload needs queues, topics, and subscriptions in a shared messaging namespace. Feed subnet-based network rules and private endpoint settings from the network foundation rather than reconstructing them inline.

### `subscription_vending`

Use this module when the platform team needs to onboard new subscriptions into the landing zone hierarchy. Create or target the subscription first, associate it to the correct management group, register required providers, and bootstrap the initial resource groups.

### `functionapp`

Use this module when the application needs a Function App backed by an existing Storage Account and App Service Plan. The canonical dependency chain is `appserviceplan` + `storageaccount` -> `functionapp`, and the plan OS must match the selected function app OS.

### `keyvault`

Use this module to centralize application secrets and certificates with RBAC and network isolation. Prefer RBAC authorization over legacy access policies unless an older consumer explicitly requires access policies.

### `loadbalancer`

Use this module when the workload needs Azure Load Balancer resources rather than L7 routing. Define frontend IP configurations, probes, backend pools, and rules explicitly, and make sure any backend targets and NSG allowances are managed by the surrounding stack.

### `linuxvm`

Use this module for Linux VM patterns that rely on the repository's shared IaC storage and key vault conventions. Make sure the application subnet, shared storage account, and key vault already exist before enabling bootstrap scripts, Entra login, or domain integration.

### `logicapp`

Use this module when the workload needs Logic App Standard hosted on App Service infrastructure. The canonical dependency chain is `appserviceplan` + `storageaccount` -> `logicapp`, and private access should only be enabled after the subnet and private DNS prerequisites already exist.

### `rg`

Use this module to standardize resource group creation, locking, and RBAC. In new stacks, this module should usually be the first module applied.

### `sqldb`

Use this module for Azure SQL Database workloads where the logical server and database are managed together. Validate the admin, AAD admin, network, and diagnostics posture before turning on private access in production.

### `sqlmi`

Use this module when a workload needs SQL Managed Instance rather than a single Azure SQL Database. Provision the delegated subnet before the instance and keep the subnet reserved for SQL MI use only.

### `sqlmi_db`

Use this module to add databases to an already-provisioned SQL Managed Instance. Feed the instance name and resource group from the `sqlmi` deployment outputs or from a known shared platform instance.

### `storageaccount`

Use this module for storage that may later be consumed by Function Apps, VM bootstrapping, diagnostics, or private workloads. If it will back a Function App, create the storage account before the function module and pass the storage account name and resource group explicitly.

### `vnet`

Use this module to build the network foundation for other modules. Define delegated or private-endpoint-ready subnets here first, then hand their IDs to downstream modules instead of repeating subnet lookups.

### `winvm`

Use this module for Windows VM patterns with optional SHIR or domain join integration. Create the network and shared IaC dependencies first, and only enable SHIR inputs when the related ADF deployment exists or is being created in the same stack.

## Test Coverage Notes

- Most modules currently have a `tests/live.tftest.hcl` file; `fortigate` instead has a mocked plan test at `tests/module.tftest.hcl`, while `loadbalancer` currently ships README-generated module docs only.
- Default CI in both GitHub Actions and Azure DevOps uses the root harness plus one-module-at-a-time root plans instead of running the live tests directly.
- The `appservice`, `functionapp`, `logicapp`, and `appserviceplan` tests use Terraform mock providers and plan-only runs; they do not create App Service Plans or workload apps.
- Stale `tests/setup` fixtures for App Service and Function App were removed because they created real temporary App Service Plans and could leave billable resources behind if an apply-style test failed before cleanup.
- Several other live tests may still target shared long-lived environment resources by design. Keep those tests for integration validation, but prefer mock-provider plan tests for any new dependency coverage.
