# Resource Naming Convention

This document records the current naming patterns used by the root harness and modules, then defines the recommended convention for new module work. The repository does not yet use one universal convention everywhere, so treat the "Current Module Patterns" section as an inventory and the "Target Convention" section as the direction for new changes.

## Target Convention

Use lowercase, deterministic names unless the Azure resource type requires a different character set. Prefer hyphens for Azure resource names that allow them, and avoid whitespace, underscores, trailing hyphens, and consecutive hyphens.

Default shape for most Azure resources:

```text
<resource-type>-<workload>-<region-code>-<environment>-<instance>
```

Examples:

```text
rg-platform-cc-dev-001
vnet-platform-cc-dev-001
snet-app-cc-dev-001
lb-platform-cc-dev-001
rt-platform-cc-dev-001
nsg-platform-cc-dev-001
```

Use this order unless the Azure resource is global, region is not available at the point where the name is generated, or the resource type has a stricter naming constraint. For global or non-regional resources, omit the region segment rather than inserting a placeholder:

```text
<resource-type>-<workload>-<environment>-<instance>
```

Examples:

```text
mg-platform-dev-001
policy-allowed-location-dev-001
appreg-platform-dev-001
```

Use compact names for resources with stricter Azure limits:

```text
st<workload><region-code><environment><instance>
kv<workload><region-code><environment><instance>
```

Examples:

```text
stplatformccdev001
kvplatformccdev001
```

For Windows and Linux VMs, keep the Azure VM name and `computer_name` Windows-safe. Windows computer names are limited to 15 characters, and both VM modules currently use the same value for resource name and computer name.

Recommended VM shape:

```text
<os><workload><region-code><env-code><instance>
```

Examples:

```text
wplatccd001
lplatccd001
```

Where:

| Segment | Meaning | Example |
| --- | --- | --- |
| `resource-type` | Azure resource abbreviation | `rg`, `vnet`, `lb`, `nsg` |
| `os` | VM operating system marker | `w`, `l` |
| `workload` | Short workload/application code | `platform`, `plat`, `app` |
| `environment` | Full environment | `dev`, `test`, `qa`, `prod`, `sbx` |
| `env-code` | Short VM-safe environment code | `d`, `t`, `q`, `p`, `s` |
| `region-code` | Short Azure region code | `cc`, `ce`, `eus`, `eus2` |
| `instance` | Three-digit sequence | `001`, `002`, `003` |

## Current Root Harness Patterns

The root harness defines `local.name_suffix = "<workload>-<environment>"` and uses it for many root-wired modules.

| Pattern | Example |
| --- | --- |
| `<rtype>-<workload>-<environment>` | `aks-template-dev`, `agw-template-dev`, `aa-template-dev` |
| `<rtype><workload><environment>001` | `acrtemplatedev001` |
| `<rtype><workload><region-code><environment>` | `sttemplateccdev`, `kvtemplateccdev` |
| `vm<workload><environment>` truncated to 12 chars, then module appends an environment suffix | `vmtemplatede601` |
| Explicit or map-driven names | `lb-001` |

Root shared values currently include:

| Local | Current expression | Example |
| --- | --- | --- |
| `name_suffix` | `<workload>-<environment>` | `template-dev` |
| `storage_account_name` | `st<workload><region-code><environment>` | `sttemplateccdev` |
| `key_vault_name` | `kv<workload><region-code><environment>` | `kvtemplateccdev` |
| `log_analytics_name` | `law-<workload>-<environment>` | `law-template-dev` |
| `app_service_plan_name` | `asp-<workload>-<environment>` | `asp-template-dev` |
| `vm_name` | `vm<workload><environment>`, max 12 chars | `vmtemplatede` |

## Current Module Patterns

| Module | Current naming pattern | Example |
| --- | --- | --- |
| `acr` | Root uses `acr<workload><environment>001`; module-generated names use compact `acr<region><name><env><suffix>` with hyphens removed. | `acrtemplatedev001` |
| `adf` | Module derives `adf-<region>-<name>-<env>-<suffix>` and `shir-<name>-<env>-<suffix>`. | `adf-cc-template-dev-601` |
| `aks` | Root uses `aks-<workload>-<environment>`; module generator supports `<prefix>-<app>-<env>-<location>-<suffix>`. | `aks-template-dev` |
| `applicationgateway` | Root uses `agw-<workload>-<environment>`; nested names come from frontend/backend/listener map keys. | `agw-template-dev` |
| `appregistration` | Display name uses `appreg-<workload>-<environment>`. | `appreg-template-dev` |
| `appservice` | Root uses `app-<workload>-<environment>`; private endpoint names use `pep-<app_name>-sites`. | `app-template-dev`, `pep-app-template-dev-sites` |
| `appserviceplan` | Root/shared uses `asp-<workload>-<environment>`; diagnostics use `<name>-diagnostic-setting`. | `asp-template-dev` |
| `automationaccount` | Root uses `aa-<workload>-<environment>`; module generator supports `<prefix>-<app>-<env>-<location>-<suffix>`. | `aa-template-dev` |
| `azure_ai_search` | Root uses `srch-<workload>-<environment>`. | `srch-template-dev` |
| `azure_ai_service` | Root uses `ais-<workload>-<environment>`; module generator supports `<prefix>-<app>-<env>-<location>-<suffix>`. | `ais-template-dev` |
| `cosmosdb` | Root uses `cosmos-<workload>-<environment>`. | `cosmos-template-dev` |
| `databricks` | Root uses `dbw-<workload>-<environment>`. | `dbw-template-dev` |
| `enterpriseapplication` | No root-generated Azure resource name; it binds to an app registration/application ID. | n/a |
| `eventhub` | Root uses `evh-<workload>-<environment>`; module generator supports `<prefix>-<app>-<env>-<location>-<suffix>`. | `evh-template-dev` |
| `firewall` | Root uses `afw-<workload>-<environment>`. | `afw-template-dev` |
| `fortigate` | Root passes `fgt-<workload>-<environment>` as `name_prefix`; nested resources include `lb-<prefix>-internal`, `lb-<prefix>-external`, and `pip-<prefix>-external-lb`. | `fgt-template-dev`, `lb-fgt-template-dev-internal` |
| `functionapp` | Root uses `func-<workload>-<environment>`. | `func-template-dev` |
| `keyvault` | Root/shared uses compact `kv<workload><region-code><environment>`; private endpoint uses `pep-<kv-name>`. | `kvtemplateccdev` |
| `linuxvm` | Root passes shared `vm_name`; module creates `<vm_name><env-suffix>`, plus `nic-`, `pip-`, and `nsg-` wrappers. | `vmtemplatede601`, `nic-vmtemplatede601` |
| `loadbalancer` | Root uses explicit `loadbalancers[*].name`; fallback is `lb-<map-key>`. | `lb-001` |
| `loganalytics` | Root/shared uses `law-<workload>-<environment>`. | `law-template-dev` |
| `logicapp` | Root uses `logic-<workload>-<environment>`; private endpoint uses `pep-<name>-sites`. | `logic-template-dev` |
| `managedidentity` | Root uses `id-<workload>-<environment>`. | `id-template-dev` |
| `managementgroups` | Root uses `shared_management_group_name`; module can generate `mg-<display-name>-<random>`. | `mg-platform-dev` |
| `nsg` | Root uses `nsg-<workload>-<environment>`. | `nsg-template-dev` |
| `openai` | Root uses `oai-<workload>-<environment>`; module generator supports `<prefix>-<app>-<env>-<location>-<suffix>`. | `oai-template-dev` |
| `policy` | Root uses `allowed-location-<environment>` and display name `Allowed Location <ENV>`. | `allowed-location-dev` |
| `private_dns` | Zone names are literal DNS zone keys; links and records use provided map keys/names. | `privatelink.azurewebsites.net` |
| `private_endpoint` | Module fallback uses `pep-<workload>-<region-code>-<environment>-<instance>`; private service connection defaults to `psc-<private-endpoint-name>`. | `pep-template-cc-dev-001` |
| `rg` | Root uses `shared_resource_group_name`; module generator supports `<prefix>-<workload>-<env>-<location>-<suffix>`. | `rg-platform-dev` |
| `roleassignments` | Names are GUIDs or provided assignment names; no human-readable convention. | GUID |
| `route_table` | Root uses `rt-<workload>-<environment>`. | `rt-template-dev` |
| `servicebus` | Root uses `sb-<workload>-<environment>`; queues, topics, and subscriptions use map keys. | `sb-template-dev` |
| `sqldb` | Root uses `sql-<workload>-<environment>` for server and `sqldb-<workload>-<environment>` for database; module generator supports `<prefix>-<app>-<env>-<location>-<suffix>`. | `sql-template-dev`, `sqldb-template-dev` |
| `sqlmi` | Root uses `sqlmi-<workload>-<environment>`. | `sqlmi-template-dev` |
| `sqlmi_db` | Root uses `sqlmidb-<workload>-<environment>`. | `sqlmidb-template-dev` |
| `storageaccount` | Root/shared uses compact `st<workload><region-code><environment>`; module generator uses compact alphanumeric-only names. | `sttemplateccdev` |
| `subscription_vending` | Root uses `sub-<workload>-<environment>`. | `sub-template-dev` |
| `vnet` | Root uses `shared_vnet_name`; sample uses spoke-oriented naming. Module can generate `vnet-<app><location>-<random>`. | `vnet-spoke-platform-dev` |
| `winvm` | Root passes shared `vm_name`; module creates `<app_vm><env-suffix>`, plus `nic-`, `pip-`, and `nsg-` wrappers. | `vmtemplatede601`, `nic-vmtemplatede601` |

## Environment Suffixes Used By VM Modules

The `linuxvm` and `winvm` modules append an environment-based numeric suffix to the VM base name.

| Environment | First suffix |
| --- | --- |
| `prod` | `001` |
| `staging` | `201` |
| `qa` | `301` |
| `dev` | `601` |
| `poc` | `701` |
| `test` | `801` |
| `sbx` | `901` |

For example, a root base of `vmtemplatede` in `dev` becomes `vmtemplatede601`.

## Known Gaps

- Linux and Windows VM modules currently receive the same root `local.vm_name`, so enabling both can create name collisions.
- Some modules use the older root pattern `<rtype>-<workload>-<environment>` without region or instance.
- Some newer modules support generated names with region and instance, but the root harness often passes explicit names instead.
- Storage Account and Key Vault use compact names because of Azure resource constraints.
- Several nested resources derive names from map keys, so caller-provided key naming matters.

## Guidance For New Work

1. Use the target convention for new root-wired module names.
2. Include `region-code` and `instance` for newly added resources unless the Azure resource type cannot support the length, the resource is global, or region is not available when the name is generated.
3. Use separate VM base names for Linux and Windows.
4. Keep map keys lowercase and stable when they become Azure child resource names.
5. Prefer explicit `name` inputs when replacing a legacy resource would be disruptive.
