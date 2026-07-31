# Module Usage and Dependencies

This document summarizes the modules under `modules/`, what each module is for, how to use it correctly, which examples to start from, and what upstream dependencies must already exist.

## How to Use Modules Properly

1. Create shared foundation resources first: resource groups, virtual networks/subnets, private DNS zones, storage, and key vaults.
2. Create hosting or platform resources next: App Service Plans, SQL Managed Instances, Automation Accounts, ACR, and AKS.
3. Create dependent workloads after their platform is ready: App Services, Function Apps, SQL MI databases, VMs, and ADF private integrations.
4. Prefer wiring modules together through outputs instead of copying resource IDs into `terraform.tfvars`.
5. Use the module `examples/` folder as the starting point; modules awaiting migration may still provide `EXAMPLES.md`.
6. For quick syntax and provider checks, run `terraform init -backend=false` and `terraform validate` in the module directory.
7. For the safest CI-like validation, enable the module through the repo root harness and run a root `terraform plan` so aliased providers and caller wiring are exercised.
8. Check the test filename and provider declarations before running `terraform test`. `unit.tftest.hcl` uses mocks; `integration.tftest.hcl` uses real providers. Review every legacy `live.tftest.hcl` because its impact is ambiguous.

Root-wired modules, including `availabilityset`, `fortigate`, and `loadbalancer`, can be enabled through `features.enable_<module>` for high-level runs or `module_plan_enabled.<module>` for focused one-module plans. Their live settings are configured through module-specific root variables in `variables.tf` and `terraform.tfvars`.

## Dependency Matrix

| Module | Primary use case | Required dependencies | Common optional dependencies | Example entry point |
| --- | --- | --- | --- | --- |
| `acr` | Private or public Azure Container Registry | Existing resource group | Private endpoint subnet, private DNS zone, Log Analytics workspace | `modules/acr/examples/` |
| `adf` | Azure Data Factory with managed or self-hosted integration runtime patterns | Existing resource group; shared IaC resource group, key vault, and storage account | Virtual network/subnet, jump VM for SHIR, private DNS zone, repo integration | `modules/adf/examples/` |
| `aks` | AKS cluster for container workloads | Existing resource group | Subnet for node pool, private DNS zone for private cluster, Log Analytics workspace | `modules/aks/examples/` |
| `appregistration` | Microsoft Entra application and optional service principal | None beyond provider access | Key Vault to store client secret | `modules/appregistration/examples/` |
| `appservice` | Linux or Windows Web App | Existing resource group; existing App Service Plan | Subnet for VNet integration, private endpoint subnet, private DNS zone, Entra app registration for auth, Log Analytics workspace | `modules/appservice/examples/` |
| `appserviceplan` | Shared hosting plan for Web Apps and Function Apps | Existing resource group | Log Analytics workspace, autoscale consumers | `modules/appserviceplan/examples/` |
| `applicationgateway` | Azure Application Gateway v2 with public frontend, listeners, backend pools, and optional WAF | Existing resource group; dedicated Application Gateway subnet | Backend application targets, TLS certificates, WAF policy, user-assigned identity | `modules/applicationgateway/examples/` |
| `automationaccount` | Azure Automation Account with RBAC and optional private access | Existing resource group | Private endpoint subnet, private DNS zone, encryption identity and key, monitoring destinations, role assignment target scopes | `modules/automationaccount/examples/` |
| `availabilityset` | Azure Availability Set for VM fault-domain and update-domain placement | Existing resource group | Proximity placement group, VM modules or VM resources that consume the Availability Set ID | `modules/availabilityset/examples/` |
| `azure_ai_service` | Azure AI Services account for multi-service AI workloads and optional model deployments | Existing resource group; regional service availability and quota | Private endpoint subnet, private DNS zone, Key Vault key and identity, monitoring destination, model quota, RBAC principals | `modules/azure_ai_service/examples/` |
| `azure_ai_search` | Azure AI Search service for indexing, retrieval, semantic ranking, and RAG backends | Existing resource group; supported regional Search SKU | Private endpoint subnet, `privatelink.search.windows.net` zone, shared-private-link targets and approval, monitoring destination, RBAC principals | `modules/azure_ai_search/examples/` |
| `containerapp` | Azure Container App deployed to an existing Container Apps managed environment | Existing resource group; existing Container Apps managed environment | Registry and pull identity, Key Vault secrets, user-assigned identity, environment networking and logging, KEDA dependencies | `modules/containerapp/examples/` |
| `cosmosdb` | Azure Cosmos DB account with optional SQL API databases and containers | Existing resource group; supported regional capacity | Private endpoint subnet, `privatelink.documents.azure.com` zone, Key Vault key and identity, monitoring destination, SQL data-plane RBAC principals | `modules/cosmosdb/examples/` |
| `databricks` | Azure Databricks workspace for lakehouse and analytics workloads | Existing resource group; regional workspace entitlement and capacity | VNet-injection subnets and NSG associations, private endpoint subnet and DNS, access connector, Key Vault keys, monitoring destinations, RBAC principals | `modules/databricks/examples/` |
| `enterpriseapplication` | Microsoft Entra Enterprise Application service principal, assignments, and optional Application Proxy publishing | Existing app registration client ID; tenant provider permissions | App-role assignment principals, Application Proxy connectors and URLs, Microsoft Graph beta configuration | `modules/enterpriseapplication/examples/` |
| `eventhub` | Event Hubs namespace, hubs, consumer groups, Capture, schema groups, private access, and Geo-DR | Existing resource group; supported namespace capacity | Capture storage, identity, private endpoint subnet and DNS, Key Vault keys, monitoring destinations, secondary namespace, RBAC principals | `modules/eventhub/examples/` |
| `firewall` | Azure Firewall with policy, rules, VNet or Virtual WAN deployment, and diagnostics | Existing resource group; `AzureFirewallSubnet` or Virtual Hub | Public IPs, `AzureFirewallManagementSubnet`, route tables, policy identity and certificate, monitoring destinations, RBAC principals | `modules/firewall/examples/` |
| `fortigate` | Single or active-passive FortiGate-VM deployment | Existing resource group; interface subnets or approved VNet address space; Marketplace license/terms | Internal/external load balancers, HA and management subnets, Key Vault credentials, FortiManager, FortiAnalyzer, UDRs | `modules/fortigate/examples/` |
| `managedidentity` | User-assigned managed identity with optional workload federation | Existing resource group | Federated credentials, RBAC target scopes | `modules/managedidentity/examples/` |
| `managementgroups` | Management group hierarchy for enterprise governance | Tenant-level permissions | Subscription placement | `modules/managementgroups/examples/` |
| `nsg` | Network Security Group and associations | Existing resource group | VNet subnets, NICs | `modules/nsg/examples/` |
| `loganalytics` | Log Analytics workspace for central platform monitoring | Existing resource group | Data Collection Rules, private-link infrastructure, diagnostics-enabled modules, Sentinel, monitoring solutions | `modules/loganalytics/examples/` |
| `openai` | Azure OpenAI account with optional model deployments | Existing resource group | Private endpoint subnet, private DNS zone, Key Vault, managed identity, Log Analytics workspace, RBAC groups | `modules/openai/examples/` |
| `policy` | Custom policy definition and optional assignment | Optional management group scope | Subscription or resource group assignment scopes | `modules/policy/examples/` |
| `private_dns` | Private DNS zones, VNet links, and records | Existing resource group | VNet IDs, private endpoint-enabled services | `modules/private_dns/examples/` |
| `private_endpoint` | Reusable Private Endpoint with optional Private DNS zone group | Existing resource group; subnet; target resource ID; default and `azurerm.prod` provider configurations | Private DNS zone IDs or lookup names | `modules/private_endpoint/examples/` |
| `roleassignments` | Generic RBAC assignments across Azure scopes | Scope IDs and target principals | Management groups, subscriptions, resource groups, identities | `modules/roleassignments/examples/` |
| `route_table` | User-defined routes and subnet associations | Existing resource group | VNet subnets, Azure Firewall | `modules/route_table/EXAMPLES.md` |
| `servicebus` | Service Bus namespace with queues, topics, and subscriptions | Existing resource group | Private endpoint subnet, private DNS zone, network rules, Log Analytics workspace, RBAC groups | `modules/servicebus/EXAMPLES.md` |
| `subscription_vending` | Subscription bootstrap with MG placement and provider registration | Existing or newly created subscription context | Management groups, bootstrap resource groups, provider registration list | `modules/subscription_vending/EXAMPLES.md` |
| `functionapp` | Linux or Windows Function App | Existing resource group; App Service Plan; Function storage account, key, or Key Vault secret | VNet integration subnet, private endpoint subnet, private DNS zone, Log Analytics workspace, identities and downstream RBAC | `modules/functionapp/examples/` |
| `keyvault` | Key Vault with RBAC, hardened network controls, and private endpoint options | Existing resource group; default and `azurerm.prod` provider configurations | Private endpoint subnet, private DNS zone, Log Analytics workspace, RBAC principals | `modules/keyvault/examples/` |
| `loadbalancer` | Azure Load Balancer with frontend IP configurations, backend pools, probes, rules, and outbound rules | Existing resource group; public IP or subnet for frontend configuration | Caller-managed backend pool membership, NSG and guest firewall rules, explicit egress design | `modules/loadbalancer/examples/` |
| `linuxvm` | Linux VMs built against the shared IaC foundation | Existing application resource group, subnet, shared IaC Key Vault, shared IaC storage account | Bastion/private administration, Entra SSH login, domain services, bootstrap dependencies | `modules/linuxvm/examples/` |
| `logicapp` | Logic App Standard on App Service infrastructure | Existing resource group; existing App Service Plan; existing Storage Account | Subnet for VNet integration, private endpoint subnet, private DNS zone, Log Analytics workspace, user-assigned identity | `modules/logicapp/examples/` |
| `rg` | Resource group with optional lock and RBAC | None | None | `modules/rg/examples/` |
| `sqldb` | Azure SQL logical server and single database | Existing application resource group; shared IaC resource group, key vault, and storage account inputs used by current pattern | Private endpoint subnet, diagnostics | `modules/sqldb/EXAMPLES.md` |
| `sqlmi` | Azure SQL Managed Instance | Existing resource group; dedicated delegated subnet | Diagnostics workspace, DNS zone partner instance, user-assigned identities | `modules/sqlmi/EXAMPLES.md` |
| `sqlmi_db` | Database on an existing SQL Managed Instance | Existing SQL Managed Instance | Diagnostics workspace | `modules/sqlmi_db/EXAMPLES.md` |
| `sqlvm` | SQL Server on Azure Windows VMs with SQL IaaS registration | Existing application resource group and database subnet | Availability Set or zones, domain join services, SQL VM group and listener composition for Always On | `modules/sqlvm/EXAMPLES.md` |
| `storageaccount` | General-purpose storage account with networking and RBAC | Existing resource group | Virtual network subnet rules, private endpoint subnet, private DNS zones, Log Analytics workspace | `modules/storageaccount/EXAMPLES.md` |
| `vnet` | Virtual network and subnets | Existing resource group | DDoS protection plan, Log Analytics workspace | `modules/vnet/EXAMPLES.md` |
| `winvm` | Windows VM built against the shared IaC foundation | Existing application resource group, VNet/subnet, shared IaC key vault, shared IaC storage account | Domain join services, ADF SHIR integration, diagnostics workspace | `modules/winvm/EXAMPLES.md` |

## Common Dependency Chains

- `rg` -> `vnet` -> `storageaccount` / `keyvault` -> `linuxvm` or `winvm`
- `managementgroups` -> `policy`
- `managementgroups` -> `subscription_vending`
- `subscription_vending` -> `rg` -> `loganalytics`
- `rg` -> `private_dns`
- `rg` -> `availabilityset` -> `linuxvm` or `winvm`
- `rg` -> dedicated `vnet` subnet -> `applicationgateway` -> backend application targets
- `rg` -> `vnet` -> `firewall` -> `route_table`
- `rg` -> `vnet` -> `fortigate` -> `route_table`
- `managedidentity` / `managementgroups` / `subscriptions` -> `roleassignments`
- `rg` -> `azure_ai_service`
- `rg` -> `azure_ai_search`
- `rg` -> Container Apps managed environment -> `containerapp`
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
- `rg` -> `subnet` -> optional `availabilityset` -> `sqlvm`
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

Use this module to standardize Entra app creation for application authentication. Prefer workload identity federation or managed identity over client secrets. If a client secret is unavoidable, store it in Key Vault, protect Terraform state, and establish rotation ownership.

### `appservice`

Use this module for web workloads that run on an existing App Service Plan. The correct pattern is `module.appservice.app_service_plan_id = module.appserviceplan.id`; avoid hard-coded plan IDs in workload compositions. Treat VNet integration as outbound connectivity and private endpoints as inbound connectivity, with separate subnet requirements.

### `appserviceplan`

Use this module to provide shared hosting capacity for multiple web apps or function apps. Create the plan first, choose an OS/SKU that matches the downstream workload, and pass `module.appserviceplan.id` to consumers. Select either Azure Monitor autoscale or Premium platform-managed automatic scaling, not both.

### `applicationgateway`

Use this module when the landing zone needs an L7 load balancer or WAF entry point in front of web workloads. Create a dedicated subnet first, then wire backend pool targets, settings, listeners, and rules from downstream outputs. The module always creates a public frontend; use WAF_v2, TLS, probes, and diagnostics for reviewed production internet ingress.

### `automationaccount`

Use this module for runbooks, schedules, and worker scenarios that need a managed automation control plane. Only enable private endpoints after subnet, private DNS, routing, and worker-access requirements are satisfied. Keep secrets out of Automation variables because their values remain in Terraform state.

### `availabilityset`

Use this module when a VM workload should use Azure Availability Sets rather than Availability Zones. From the root harness, set `features.enable_availabilityset` or `module_plan_enabled.availabilityset` and add one entry per set in the `availabilitysets` map. Pass the module output `id` to VM resources or VM modules that should join the set.

Start with `examples/basic`; use `examples/complete` only when an existing proximity placement group is part of the placement design. Confirm the region's supported fault-domain count before deployment.

### `azure_ai_service`

Use this module when the platform needs a shared Azure AI Services endpoint for multi-service AI capabilities or managed model deployments. Public access and local authentication are disabled by default. Establish private DNS, endpoint subnets, monitoring destinations, identities, regional model availability, and quota before using `examples/complete`; see the module architecture page for ownership boundaries.

### `azure_ai_search`

Use this module when the platform needs a dedicated Azure AI Search service for indexing, retrieval APIs, semantic ranking, or vector-backed RAG patterns. Prefer the private pattern in `examples/complete`. The public-firewall scenario is explicitly non-production, and shared private links normally require approval on their target resources.

### `containerapp`

Use this module when a workload should run on Azure Container Apps inside an existing managed environment. Create or identify the managed environment first, then pass `container_app_environment_id`. Choose the HTTP application examples or the ingress-free background-worker scenario, pin images, and grant registry, Key Vault, and scaler permissions outside this module.

### `cosmosdb`

Use this module when the workload needs an Azure Cosmos DB account with SQL API databases and containers. Public access and key-based local authentication are disabled by default. Prefer the private multi-region pattern for production and use the separate serverless example only for a single-region workload without provisioned throughput.

### `databricks`

Use this module when the platform needs a reusable Azure Databricks workspace for data engineering, lakehouse, notebook, or ML workloads. Public access is disabled by default. Prefer the VNet-injected private pattern in `examples/complete`, and use the access-connector scenario only with a separate Databricks data-plane configuration for Unity Catalog.

### `enterpriseapplication`

Use this module when an app registration needs an owned service principal, assignments, or Application Proxy publishing. Prefer passing `application_id` from the `appregistration` output. The complete example demonstrates single ownership of the service principal; the Application Proxy scenario is isolated because it uses Microsoft Graph beta and has separate connector and security prerequisites.

### `eventhub`

Use this module when the workload needs a central event-streaming namespace with hubs, consumer groups, Capture, schemas, or Geo-DR. Public access and SAS authentication are disabled by default. Create Capture storage, private DNS, identities, monitoring destinations, and the secondary namespace before enabling their dependent features.

### `firewall`

Use this module when the landing zone needs centralized north-south or east-west traffic control. Create the hub VNet and `AzureFirewallSubnet` first, then pass the firewall private IP to `route_table` modules. Use the Virtual Hub example only for an existing Virtual WAN topology, and treat every policy change as a shared-network production change.

### `fortigate`

Use this module for a private single FortiGate-VM or a zone-aware active-passive pair. Prepare interface subnets and static addresses first, keep management private, and treat FortiOS clustering, routing, policy, licensing, and probe responses as separate appliance configuration. The dedicated-network example is intended for isolated ownership, not shared landing-zone networking.

### `managedidentity`

Use this module when workloads need a reusable user-assigned identity. Create it before attaching it to app, function, AKS, or automation modules. Federated credentials require an exact issuer, subject, and audience match; use the focused GitHub OIDC example for deployment workflows and the complete example for AKS workload identity. Each role assignment must identify exactly one role by name or definition ID.

### `managementgroups`

Use this module to create or extend the enterprise management group hierarchy. Apply it before policy assignment and subscription vending, and treat changes to the parent or subscription associations as high-impact governance changes. The module creates one management group per instance; compose a hierarchy with multiple instances. Its `tags` input is organizational metadata only because management groups do not support ARM tags.

### `nsg`

Use this module to standardize NSG creation and optionally own subnet or NIC association lifecycle. Feed subnet IDs from the `vnet` module rather than reconstructing them manually, prefer the keyed association maps for stable Terraform addresses, and make association ownership exclusive to one stack. Rules are inline on the NSG; flow logs, diagnostics, and Network Watcher remain caller responsibilities.

### `loganalytics`

Use this module to create the shared monitoring workspace before enabling diagnostics in other modules. The normal landing zone pattern is `rg -> loganalytics -> diagnostics-enabled resources`. Public ingestion/query and local authentication default to compatibility settings; production callers should decide on private-link and Entra-only access before disabling them. The module does not create Data Collection Rules, Azure Monitor Private Link Scope, agents, alerts, or diagnostic settings.

### `openai`

Use this module when the workload needs an Azure OpenAI account and optionally managed model deployments. Public network access and local authentication are disabled by default, but provider-managed account keys still enter Terraform state. Keep deployments explicit in code, confirm regional model availability and quota before apply, and prepare private DNS, encryption identity/key, diagnostics, and RBAC dependencies before enabling them.

### `policy`

Use this module for one custom governance definition and optional assignment ownership. In enterprise landing zones, the normal pattern is `managementgroups -> policy definition -> staged assignment`. Definition scope and assignment scope are independent; treat management group scope, enforcement, exclusions, and parameters as high-impact governance changes. Remediation tasks and the assignment identity's required RBAC remain separate responsibilities.

### `private_dns`

Use this module to own private DNS zones, VNet links, and centrally managed records. Create each zone once, link every required VNet, and pass zone IDs to private-endpoint-capable modules. Private endpoint zone groups should normally own endpoint A records; do not declare the same record from multiple stacks. Auto-registration is intended for private VM namespaces, not private endpoint zones.

### `private_endpoint`

Use this module when the Private Endpoint lifecycle should be managed separately from the target service module. Prefer direct subnet and DNS zone IDs from upstream outputs. Name-based shared-network lookups use `azurerm.prod`, while the default provider creates the endpoint. Use one module instance per target resource/subresource group, and remember that a Private Endpoint does not disable the target service's public endpoint by itself.

### `roleassignments`

Use this module when RBAC needs to be managed outside individual resource modules. It is the better fit for subscription, management group, and cross-resource landing zone access patterns. Prefer principal and role IDs; name lookup supports Entra groups and Azure role definitions only. Deterministic names and duplicate-input checks stabilize assignments owned by this state, but matching assignments outside state must be imported or left with their existing owner.

### `route_table`

Use this module to control subnet routing explicitly. The normal landing zone pattern is `vnet -> firewall -> route_table -> workload subnets`.

### `servicebus`

Use this module when the workload needs queues, topics, and subscriptions in a shared messaging namespace. Feed subnet-based network rules and private endpoint settings from the network foundation rather than reconstructing them inline.

### `subscription_vending`

Use this module when the platform team needs to onboard new subscriptions into the landing zone hierarchy. Create or target the subscription first, associate it to the correct management group, register required providers, and bootstrap the initial resource groups.

### `functionapp`

Use this module when the application needs a Linux or Windows Function App backed by an existing App Service Plan and Function storage. The canonical dependency chain is `appserviceplan` + `storageaccount` -> `functionapp`, and the plan OS must match the selected Function App OS. Prefer managed identity for storage and downstream access. VNet integration controls outbound traffic while a separate private endpoint and DNS path control inbound traffic.

### `keyvault`

Use this module to centralize application secrets and certificates with Azure RBAC, purge protection, deny-by-default network ACLs, and optional private connectivity. The caller must pass `azurerm.prod`; name-based subnet and private DNS lookups use that alias for shared-subscription networking. Secret, key, certificate, and rotation lifecycles remain separate from the vault infrastructure module.

### `loadbalancer`

Use this module when the workload needs Layer 4 Azure Load Balancer resources rather than Layer 7 routing. From the root harness, set `features.enable_loadbalancer` or `module_plan_enabled.loadbalancer` and add one entry per LB in the `loadbalancers` map, such as `001` and `002`. Define frontends, probes, pools, rules, and egress explicitly. Backend membership, public IPs, NSG allowances, guest firewalls, and routes are managed by the surrounding stack.

### `linuxvm`

Use this module for one or more Linux VMs that rely on the repository's shared IaC storage and Key Vault conventions. The application subnet, shared storage account, and Key Vault must already exist. Private administration and SSH-key-only authentication are the recommended baseline; public SSH is an explicit exception requiring narrow trusted source prefixes. Review the module's authentication and operations guides before enabling Entra login, domain integration, localization, or broad RBAC scopes.

### `logicapp`

Use this module when the workload needs a Logic App Standard host on existing App Service infrastructure. The canonical dependency chain is `appserviceplan` + `storageaccount` -> `logicapp`; VNet integration controls outbound routing while a separate private endpoint and DNS path controls inbound traffic. The storage access key is provider-managed data in Terraform state, and workflows, API connections, and application content remain separate deployment concerns.

### `rg`

Use this module to standardize resource group creation, caller-owned tags, optional locking, and resource group-scoped RBAC. In new stacks it should usually be the first workload module applied, with its outputs passed downstream. Prefer explicit or deterministic names, use `CanNotDelete` as the general lock guard, and reserve `ReadOnly` for exceptional operating models. Existing resource groups and matching RBAC assignments must be imported before this module can own them.

### `sqldb`

Use this module for Azure SQL Database workloads where the logical server and database are managed together. Validate the admin, AAD admin, network, and diagnostics posture before turning on private access in production.

### `sqlmi`

Use this module when a workload needs SQL Managed Instance rather than a single Azure SQL Database. Provision the delegated subnet before the instance and keep the subnet reserved for SQL MI use only.

### `sqlmi_db`

Use this module to add databases to an already-provisioned SQL Managed Instance. Feed the instance name and resource group from the `sqlmi` deployment outputs or from a known shared platform instance.

### `sqlvm`

Use this module when a workload needs full SQL Server on Azure VMs instead of Azure SQL Database or SQL Managed Instance. Keep SQL VMs in a dedicated database subnet, choose either zones or an Availability Set, and compose cluster/listener resources outside the module when building Always On.

### `storageaccount`

Use this module for storage that may later be consumed by Function Apps, VM bootstrapping, diagnostics, or private workloads. If it will back a Function App, create the storage account before the function module and pass the storage account name and resource group explicitly.

### `vnet`

Use this module to build the network foundation for other modules. Define delegated or private-endpoint-ready subnets here first, then hand their IDs to downstream modules instead of repeating subnet lookups.

### `winvm`

Use this module for Windows VM patterns with optional SHIR or domain join integration. Create the network and shared IaC dependencies first, and only enable SHIR inputs when the related ADF deployment exists or is being created in the same stack.

## Test Coverage Notes

- Most modules not yet migrated currently have a `tests/live.tftest.hcl` file; standardized modules use `unit.tftest.hcl` or `integration.tftest.hcl` according to provider behavior.
- Default CI in both GitHub Actions and Azure DevOps uses the root harness plus one-module-at-a-time root plans instead of running the live tests directly.
- The `applicationgateway`, `appregistration`, `appservice`, `appserviceplan`, `automationaccount`, `availabilityset`, `azure_ai_service`, `azure_ai_search`, `containerapp`, `cosmosdb`, `databricks`, `enterpriseapplication`, `eventhub`, `firewall`, `fortigate`, `functionapp`, `keyvault`, `linuxvm`, `loadbalancer`, `loganalytics`, `logicapp`, `managedidentity`, `managementgroups`, `nsg`, `openai`, `policy`, `private_dns`, `private_endpoint`, `rg`, and `roleassignments` unit tests use mock providers and plan-only or expected-failure runs; they do not create cloud or tenant resources.
- Stale `tests/setup` fixtures for App Service and Function App were removed because they created real temporary App Service Plans and could leave billable resources behind if an apply-style test failed before cleanup.
- Several other live tests may still target shared long-lived environment resources by design. Keep those tests for integration validation, but prefer mock-provider plan tests for any new dependency coverage.
