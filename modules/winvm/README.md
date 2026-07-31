# Windows VM Module

Provision Azure Windows virtual machines with managed identity, RBAC, optional domain join, optional AAD login, bootstrap execution, shared storage/script access, local Windows group membership, optional data disks, restricted public networking, optional SHIR bootstrap, and per-VM diagnostics.

## Table Of Contents

- [Architecture](#architecture)
- [Backend](#backend)
- [Bootstrap Execution](#bootstrap-execution)
- [Domain Join](#domain-join)
- [Scripts And Logs](#scripts-and-logs)
- [Pipeline](#pipeline)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Validation](#validation)
- [Related Docs](#related-docs)

## Architecture

The module creates one or more Windows VMs in an existing resource group, VNet, and subnet. It creates NICs, optional public IP and NSG resources, optional managed data disks, a system-assigned managed identity, VM extensions, RBAC assignments, and a bootstrap execution path.

Key files:

- `main.tf`: VM, NIC, extension, run command, RBAC, public IP, NSG, and disk resources.
- `locals.tf`: environment suffixing, credential resolution, group resolution, zone spread, and tags.
- `data.tf`: existing Azure resources, Key Vault secret lookups, and Entra group lookups.
- `variables.tf`: module interface and consistency checks.
- `output.tf`: module outputs.
- `scripts/init2.ps1`: active Windows bootstrap script.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full design.

## Backend

The module itself does not declare a backend. Backend configuration is at the repository root in `backend.tf`.

Current root backend:

```hcl
backend "azurerm" {
  subscription_id      = "ef8ff35a-8548-485c-be32-204db0340dd1"
  tenant_id            = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
  resource_group_name  = "rg-ccoe-iac-cc-prod"
  storage_account_name = "stccoeiacccprod"
  container_name       = "terraform"
  key                  = "template/terraform.tfstate"
}
```

The Azure DevOps pipeline passes the same backend values to `terraform init -backend-config=...` during plan and module harness validation.

## Bootstrap Execution

The bootstrap script is `scripts/init2.ps1`.

There are two mutually exclusive ways to run it:

- `enable_custom_script_extension = true`: creates the `CustomScriptInit` extension. Azure stages VM `custom_data` as `C:\AzureData\CustomData.bin`; the extension copies it to `C:\AzureData\script.ps1` and executes it.
- `enable_virtual_machine_run_command = true`: creates `azurerm_virtual_machine_run_command.Init`. The Run Command wrapper writes `init2.ps1` from a base64 payload and passes arguments through a JSON array. Keep this base64 wrapper; it avoids nested PowerShell here-string parsing failures.

The VM resource ignores `custom_data` changes so editing `init2.ps1` does not force VM replacement.

The module automatically replaces the Run Command resource when bootstrap arguments, resolved Windows access groups, or bundled bootstrap script content changes, so group updates rerun bootstrap without replacing the VM. Consumers that store additional VM-specific localization scripts outside this module can also pass a content hash to `run_command_replace_trigger`; when that value changes, Terraform replaces the Run Command resource and reruns the bootstrap without replacing the VM.

When `enable_shir = true`, one bootstrap execution method must be enabled and `adf_id` must be set.

Current bootstrap behavior:

- Sets Windows time zone to `Eastern Standard Time`.
- Initializes RAW data disks.
- Enables ICMP and OpenSSH firewall/service configuration.
- Installs PowerShell 7, Azure CLI, 7-Zip, and standalone BGInfo.
- Defers Az Modules, Git, Terraform, Sysinternals Suite, AWS CLI, Postman, MobaXterm, and AzCopy to `scheduled.ps1` after the VM is idle and no users are logged on.
- Runs optional localization from `scheduled.ps1` near the end, after successful scheduled package installs and PATH updates.
- Downloads `default.bgi` and `background.png`, applies the background wallpaper, and runs BGInfo through a logon helper.
- Stages `validation.ps1` when present.
- Cleans Azure Arc surfacing.
- Configures WinRM securely by default.
- Adds local Administrators and Remote Desktop Users memberships when Windows can resolve the supplied values.
- Optionally installs/registers SHIR.

Consumer repo contract for localization:

- Upload consumer scripts to the shared storage account passed as `iac_st`.
- Use the `localization_container_name` container, which defaults to `localization`.
- Use `localization.ps1` for shared Windows customization; `windows-localization.ps1` remains supported.
- Use `<COMPUTERNAME>.ps1` or `<VM_NAME>.ps1` for individual VM customization.
- Keep module/bootstrap-owned assets such as BGInfo files, `scheduled.ps1`, and `validation.ps1` in the `scripts` container.
- Prefer `enable_virtual_machine_run_command = true` for current consumers; Custom Script Extension is retained for compatibility but is less stable for this bootstrap pattern.

## Domain Join

Domain join is performed by `azurerm_virtual_machine_extension.domain_join_ext` using `JsonADDomainExtension`.

Domain join is enabled only when:

- `enable_domain_join = true`
- `app_env != "sbx"`

Domain join is mutually exclusive with `AADLoginForWindows`.

Credential resolution:

- `domain_join_user` and `domain_join_password` are used directly when non-empty.
- Otherwise the module reads `domain_join_username_secret_name` and `domain_join_password_secret_name` from the effective Key Vault.
- The effective Key Vault is `admin_credentials_key_vault_id` when supplied, otherwise the shared IaC Key Vault derived from `iac_rg` and `iac_kv`.

The bootstrap script itself does not join the domain. It can add domain groups to local Windows groups only after the VM can resolve those principals. Terraform currently orders bootstrap after the domain join extension when domain join is enabled.

Manual repair/testing helper:

- `scripts/domain-join.ps1`: standalone managed-identity REST based domain join helper. It does not require Az PowerShell modules.

## Scripts And Logs

See [SCRIPTS.md](SCRIPTS.md) for script locations, expected storage blobs, local paths, logs, and execution sequence.

Important VM paths:

- Main bootstrap log: `C:\ProgramData\Logs\Init\InitLog.txt`
- Bootstrap workspace: `C:\ProgramData\Bootstrap`
- Downloads: `C:\ProgramData\Bootstrap\dl`
- Work files: `C:\ProgramData\Bootstrap\work`
- Validation script: `C:\ProgramData\Bootstrap\validation.ps1`
- BGInfo user log: `C:\ProgramData\Bootstrap\BGInfoUser.log`
- Run Command staged script: `C:\ProgramData\Bootstrap\run-command-init2.ps1`

## Pipeline

The root `azure-pipelines.yml` performs validation, plan, module target detection, and selected module harness planning. See [PIPELINE.md](PIPELINE.md).

High-level stages:

- `Validate`: installs Terraform, runs repo fmt/validate.
- `Plan`: initializes with AzureRM backend and publishes binary/text plan artifacts.
- `DetectModuleTargets`: detects changed module paths.
- `ValidateModules`: plans selected module harness targets with generated overrides.

## Inputs

| Name | Type | Default | Description |
|---|---:|---|---|
| `location` | string | `canadacentral` | Azure region for resources. |
| `app_env` | string | `dev` | Environment. Allowed: `prod`, `staging`, `dev`, `qa`, `sbx`, `poc`, `test`. |
| `workload` | string | `project` | Workload tag value. |
| `inherit_resource_group_tags` | bool | `true` | Merge existing application RG tags into resources. |
| `azure-user` | string | `""` | Local admin username override. Falls back to Key Vault secret. |
| `azure-password` | sensitive string | `""` | Local admin password override. Falls back to Key Vault secret. |
| `admin_credentials_key_vault_id` | string | `""` | Optional Key Vault resource ID for admin and domain join secrets. |
| `admin_username_secret_name` | string | `azure-user` | Admin username secret name. |
| `admin_password_secret_name` | sensitive string | `azure-password` | Admin password secret name. |
| `AADLoginForWindows` | bool | `true` | Enable AADLoginForWindows extension. Mutually exclusive with domain join. |
| `windows_image_publisher` | string | `MicrosoftWindowsServer` | VM image publisher. |
| `windows_image_offer` | string | `WindowsServer` | VM image offer. |
| `windows_image_sku` | string | `2025-Datacenter` | VM image SKU. |
| `windows_image_version` | string | `latest` | VM image version. |
| `disksize` | number | `0` | Optional data disk size in GB. `0` disables data disk. |
| `app_vm_number` | number | `1` | Number of VMs to create. |
| `private_ip_addresses` | list(string) | `[]` | Optional static private IP addresses. Leave empty for dynamic allocation; when set, provide exactly one IPv4 address per VM in `app_vm_number` order. |
| `enable_zone_spread` | bool | `true` | Spread multi-VM deployments across availability zones. |
| `availability_zones` | list(string) | `["1","2","3"]` | Round-robin zones when zone spread is enabled. |
| `app_vm_size` | string | `Standard_D2s_v3` | VM size. |
| `iac_rg` | string | required | Shared IaC resource group. |
| `iac_kv` | string | `kvplatformccdev` | Shared IaC Key Vault name. |
| `iac_st` | string | `stplatformccdev` | Shared IaC storage account name. |
| `localization_container_name` | string | `localization` | Blob container containing consumer-owned Windows localization scripts. |
| `app_rg` | string | required | Existing application resource group. |
| `app_snet` | string | required | Existing subnet name. |
| `app_vnet_rg` | string | required | Existing VNet resource group. |
| `app_vnet` | string | required | Existing VNet name. |
| `app_vm` | string | required | VM base name. Environment suffixes are appended. |
| `domain` | string | `2join.us` | AD domain name for JsonADDomainExtension. |
| `enable_domain_join` | bool | `false` | Enable domain join outside `sbx`. |
| `enable_custom_script_extension` | bool | `false` | Run bootstrap through Custom Script Extension. |
| `enable_virtual_machine_run_command` | bool | `false` | Run bootstrap through `azurerm_virtual_machine_run_command`. |
| `run_command_replace_trigger` | string | `""` | Optional external trigger value that forces the Run Command bootstrap resource to be replaced when changed, in addition to the module's built-in bootstrap argument and script-content trigger. |
| `enable_defender_performance_mode` | bool | `false` | Temporarily adjust Defender settings during heavy installs. |
| `domain_join_user` | string | `""` | Domain join username override in `domain\user` format. |
| `domain_join_password` | sensitive string | `""` | Domain join password override. |
| `domain_join_username_secret_name` | string | `domain-join-user` | Domain join username secret name. |
| `domain_join_password_secret_name` | sensitive string | `domain-join-password` | Domain join password secret name. |
| `app_admin_group` | list(string) | `["7a958d36-a182-451e-8012-4e8fe9386dc7","BA-G-Azure-Owner-F"]` | Groups for VM/NIC Contributor, VM admin login, and local Administrators membership when resolvable. |
| `app_user_group` | list(string) | `[]` | Groups for VM Reader, VM user login, and local Remote Desktop Users membership when resolvable. |
| `windows_group_domain_prefix` | string | `""` | Optional domain/NetBIOS prefix applied to bare Windows group names. |
| `vm_remote_group` | string | `null` | Extra group for VM User Login role. |
| `vm_admin_group` | string | `null` | Extra group for VM Administrator Login role. |
| `public_network_enabled` | bool | `false` | Create public IP, NSG, and restricted RDP rule. |
| `rdp_source_address_prefixes` | list(string) | `[]` | Trusted IPv4 addresses/CIDRs required when public networking is enabled. |
| `enable_shir` | bool | `false` | Enable Self-hosted Integration Runtime bootstrap and ADF RBAC. |
| `tags` | map(string) | `{}` | Additional tags. Overrides inherited tags. |
| `enable_diagnostics` | bool | `false` | Create one VM diagnostic setting per VM. |
| `log_analytics_workspace_id` | string | `""` | Workspace ID required when diagnostics flag is true. |
| `adf_id` | string | `null` | Azure Data Factory resource ID for SHIR RBAC. |
| `patch_mode` | string | `AutomaticByPlatform` | Windows guest patch mode. |

## Outputs

| Name | Description |
|---|---|
| `privateips` | Private IP addresses from created NICs. |
| `public_ip` | First public IP for backward compatibility, otherwise `null`. |
| `public_ips` | Public IP addresses for all VMs. |
| `vm_ids` | Windows VM resource IDs. |
| `principal_ids` | System-assigned managed identity principal IDs. |
| `merged_tags` | Final merged tags applied to resources. |
| `diagnostics_enabled` | Whether diagnostics are enabled. |
| `diagnostic_setting_ids` | Diagnostic setting IDs keyed by VM index. |
| `role_assignment_ids` | IDs for VM login, VM/NIC RBAC, storage, Key Vault, and optional ADF role assignments. |

## Validation

Common local checks:

```powershell
terraform fmt modules\winvm
terraform validate
terraform test -filter='modules\winvm\tests\live.tftest.hcl'
```

PowerShell parse check:

```powershell
$tokens=$null; $errors=$null
[System.Management.Automation.Language.Parser]::ParseFile('modules\winvm\scripts\init2.ps1',[ref]$tokens,[ref]$errors) | Out-Null
$errors
```

## Related Docs

- [ARCHITECTURE.md](ARCHITECTURE.md)
- [PIPELINE.md](PIPELINE.md)
- [SCRIPTS.md](SCRIPTS.md)
- [EXAMPLES.md](EXAMPLES.md)
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
