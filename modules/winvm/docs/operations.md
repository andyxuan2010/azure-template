# Windows VM Bootstrap Operations

## Script Inventory

Local module path: `modules/winvm/scripts`

| File | Purpose |
|---|---|
| `init2.ps1` | Active bootstrap script used by Custom Script Extension and Run Command. |
| `domain-join.ps1` | Manual domain join repair/testing helper using managed-identity REST. |
| `validation.ps1` | VM-side validation helper staged by bootstrap when available in storage. |
| `scheduled.ps1` | Idle scheduled task script downloaded and registered by bootstrap. |
| `default.bgi` | BGInfo configuration file. Also expected in the storage `scripts` container. |
| `background.png` | Background wallpaper. Also expected in the storage `scripts` container. |
| `init.ps1` | Older/full bootstrap script retained for reference/storage compatibility. |
| `script.ps1` | Older/full bootstrap script retained for reference/storage compatibility. |
| `install-powershell.ps1` | Microsoft PowerShell install helper retained for reference; it is not called by the active module bootstrap. |

## Active Script Sequence

The active module flow is a two-stage bootstrap. `init2.ps1` runs first through Custom Script Extension or Run Command. It installs only the baseline tools needed early in provisioning, stages the follow-up script, and registers the `post-cloud-init` scheduled task. `scheduled.ps1` runs later as SYSTEM when the VM is idle and no users are logged on.

| Order | Script or asset | Trigger | Package responsibility |
|---:|---|---|---|
| 1 | `init2.ps1` | Terraform Custom Script Extension or VM Run Command | Baseline packages: PowerShell 7, Azure CLI, 7-Zip, and standalone BGInfo. Optional SHIR package when SHIR is enabled. |
| 2 | `scheduled.ps1` | `post-cloud-init` scheduled task, boot delayed 5 minutes plus idle condition | Deferred packages: Az modules, AWS CLI, Git, Terraform, Sysinternals Suite, Postman, MobaXterm, and AzCopy. |
| 3 | Localization scripts | Called by `scheduled.ps1` near the end | Consumer-owned customization scripts from `localization_container_name`; no module package installs. |
| 4 | `validation.ps1` | Manually run after bootstrap when staged | Validation only; it does not install packages. |

`domain-join.ps1`, `init.ps1`, `script.ps1`, and `install-powershell.ps1` are not part of the normal active sequence. `domain-join.ps1` is a manual repair helper. `init.ps1` and `script.ps1` are retained older/full bootstrap references and include historical GUI package install logic that is not used by the active `init2.ps1` and `scheduled.ps1` path. The active `init2.ps1` has an opt-in domain join path controlled by `init2_enable_domain_join`; it is ignored when `enable_domain_join` enables `JsonADDomainExtension`, and otherwise requires all four `init2_*` domain-join inputs.

## Storage Layout

`init2.ps1` expects the shared IaC storage account from `iac_st`.

Scripts container for module/bootstrap-owned assets:

- `scripts/default.bgi`
- `scripts/background.png`
- `scripts/scheduled.ps1`
- `scripts/validation.ps1`
- `scripts/azureadmin-pubkey`

Packages container:

Baseline packages consumed by active `init2.ps1`:

- `PowerShell-*-win-x64.msi`
- `azure-cli-*.msi`
- `7z*-x64.msi`
- `Bginfo*.exe`, `BGInfo*.exe`, or `BGInfo64*.exe`
- `IntegrationRuntime_*.msi` when SHIR is enabled

Deferred packages consumed by active `scheduled.ps1`:

- `az-modules.zip`, installed by `scheduled.ps1`
- `AWSCLIV2*.msi`, installed by `scheduled.ps1`
- `Git-*-64-bit.exe` or `Git-*.exe`, installed by `scheduled.ps1`
- `terraform*.zip`, installed by `scheduled.ps1`
- `SysinternalsSuite*.zip`, installed by `scheduled.ps1`
- `Postman-win64-Setup*.exe`, installed by `scheduled.ps1`
- `MobaXterm_Installer_v*.zip`, installed by `scheduled.ps1`
- `azcopy_windows_amd64*.zip`, installed by `scheduled.ps1`

`init2.ps1` keeps larger packages out of the initial bootstrap path to reduce initial provisioning time. `scheduled.ps1` installs those packages from the same managed-identity storage flow when the VM is idle and no users are logged on.

## Package Install Ownership

### `init2.ps1`

Active package sequence:

1. PowerShell 7: `PowerShell-*-win-x64.msi`
2. Azure CLI: `azure-cli-*.msi`
3. 7-Zip: `7z*-x64.msi`
4. Standalone BGInfo: `Bginfo*.exe`, `BGInfo*.exe`, or `BGInfo64*.exe`
5. SHIR, only when `enable_shir = true`: `IntegrationRuntime_*.msi`

Explicitly deferred or disabled in `init2.ps1`:

- Az modules for Windows PowerShell 5.1 and the PowerShell 7 copy are deferred to `scheduled.ps1`.
- AWS CLI, Git, Terraform, Sysinternals Suite, Postman, MobaXterm, and AzCopy are deferred to `scheduled.ps1`.
- VS Code, Azure Storage Explorer, and Azure Data Studio are disabled in the active path and are not installed by `scheduled.ps1`.

### `scheduled.ps1`

Active package sequence:

1. Az modules for Windows PowerShell 5.1: `az-modules.zip`
2. Copy Az modules to PowerShell 7 module path
3. AWS CLI: `AWSCLIV2*.msi`
4. Git: `Git-*-64-bit.exe` or `Git-*.exe`
5. Terraform: `terraform*.zip`
6. Sysinternals Suite: `SysinternalsSuite*.zip`
7. Postman: `Postman-win64-Setup*.exe`
8. MobaXterm: `MobaXterm_Installer_v*.zip`
9. AzCopy: `azcopy_windows_amd64*.zip`

After the scheduled package block succeeds, `scheduled.ps1` updates PATH, runs optional localization scripts, and disables `post-cloud-init`.

### Reference Scripts

`init.ps1` and `script.ps1` are retained for reference/storage compatibility and are not the active bootstrap path. Their historical package lists include Az modules, PowerShell 7, Azure CLI, AWS CLI, 7-Zip, Sysinternals, VS Code, Storage Explorer, Azure Data Studio, Postman, MobaXterm, AzCopy, and SHIR. Do not use those historical lists to infer the active package sequence.

`install-powershell.ps1` is a standalone Microsoft helper that can install PowerShell from online release metadata when invoked directly. The active module path does not call it; `init2.ps1` installs PowerShell 7 from the storage package `PowerShell-*-win-x64.msi`.

## Consumer Repo Contract

A consumer repo that wants this module to run localization scripts must upload blobs to the same storage location that `init2.ps1` reads.

Required alignment:

| Contract item | Expected value |
|---|---|
| Storage account | The module input `iac_st` |
| Localization container | The module input `localization_container_name`; default `localization` |
| Shared Windows localization blob | `localization/localization.ps1` preferred; `localization/windows-localization.ps1` also supported |
| Individual VM script blob | `localization/<COMPUTERNAME>.ps1` or `localization/<VM_NAME>.ps1` |
| Scheduled task script blob | `scripts/scheduled.ps1` |

The module/bootstrap-owned files stay in the `scripts` container. Consumer-owned localization files are read from `localization_container_name`.

Consumer-side recommendations:

- Prefer `enable_virtual_machine_run_command = true`.
- Keep `enable_custom_script_extension = false` unless legacy compatibility is required.
- Upload per-VM scripts with the final Windows computer name, for example `azuwipkijump601.ps1`.
- Use `localization.ps1` for common primary Windows VM customization.
- Use `<COMPUTERNAME>.ps1` or `<VM_NAME>.ps1` for host-specific customization.
- Use a separate consumer-owned scheduled task for recurring workload actions; the module-owned `scheduled.ps1` task is for one-time idle post-bootstrap behavior.

## Execution Paths

The module has two bootstrap execution switches. They are mutually exclusive.

| Area | `enable_custom_script_extension` | `enable_virtual_machine_run_command` |
|---|---|---|
| Terraform resource | `azurerm_virtual_machine_extension.CustomScriptInit` | `azurerm_virtual_machine_run_command.Init` |
| Script source | VM `custom_data` staged by Azure as `C:\AzureData\CustomData.bin` | Terraform Run Command source wrapper containing base64 encoded `init2.ps1` |
| Staged script path | `C:\AzureData\script.ps1` | `C:\ProgramData\Bootstrap\run-command-init2.ps1` |
| Argument handling | Command string | JSON argument array splatted into PowerShell |
| Script update behavior | VM `custom_data` drift is ignored to avoid VM rebuilds, so existing VMs may not rerun when `init2.ps1` changes | Run Command source changes when `init2.ps1` changes and can update/rerun independently of VM replacement; consumers can also pass `run_command_replace_trigger` for external script hashes |
| Operational stability | Less preferred. Custom Script Extension has been less stable in this module's usage and can be sensitive to extension state/retry behavior | Preferred. More explicit execution resource, safer payload staging, and easier update/rerun behavior |
| Best use | Legacy compatibility or environments where Run Command is unavailable | Standard/bootstrap path for current module usage |

Preferred path: `enable_virtual_machine_run_command = true`. The Run Command wrapper uses base64 to stage `init2.ps1`; keep this design because raw inline script embedding can break when `init2.ps1` contains PowerShell here-strings.

### Custom Script Extension

1. Terraform sets VM `custom_data` to base64 encoded `scripts/init2.ps1`.
2. Azure stages it as `C:\AzureData\CustomData.bin`.
3. `CustomScriptInit` copies it to `C:\AzureData\script.ps1`.
4. `CustomScriptInit` runs `script.ps1` with module-provided arguments.

Lifecycle note: `azurerm_windows_virtual_machine.this` ignores `custom_data` changes. This prevents script edits from forcing VM replacement, but it also means changing `init2.ps1` does not automatically update an already-created VM through this path.

### Run Command

1. Terraform creates `azurerm_virtual_machine_run_command.Init`.
2. The Run Command source wrapper decodes `filebase64("scripts/init2.ps1")`.
3. The wrapper writes it to `C:\ProgramData\Bootstrap\run-command-init2.ps1`.
4. Arguments are loaded from JSON and splatted into PowerShell.
5. The script runs with the same bootstrap parameters as Custom Script Extension.

Lifecycle note: the Run Command resource source includes the current base64 content of `init2.ps1`. Script changes affect the Run Command resource and can be applied without rebuilding the VM. The module replaces `azurerm_virtual_machine_run_command.Init` when bootstrap arguments, resolved Windows access groups, bundled script content, or the optional `run_command_replace_trigger` value changes. Consumers can set `run_command_replace_trigger` to a hash of storage-backed localization or VM-specific scripts. This is one reason Run Command is preferred over Custom Script Extension for this module.

## Main Bootstrap Sequence

`init2.ps1` runs as LocalSystem and performs:

1. Initialize paths and logging.
2. Acquire managed identity tokens through IMDS when storage or Key Vault access is needed.
3. Set Windows time zone to `Eastern Standard Time`.
4. Enable ICMP.
5. Initialize RAW data disks.
6. Optionally join Active Directory through the supplied domain controller after pre-checks.
7. Optional Defender performance mode.
8. Install enabled baseline tools: PowerShell 7, Azure CLI, 7-Zip, standalone BGInfo.
9. Update PATH.
10. Configure OpenSSH and `administrators_authorized_keys`.
11. Configure BGInfo and the background wallpaper.
12. Register `scheduled.ps1` idle task.
13. Stage `validation.ps1`.
14. Clean Azure Arc surfacing.
15. Configure WinRM securely.
16. Add local group memberships.
17. Optionally install/register SHIR.
18. Finalize.

## Logs And Paths

| Item | Path |
|---|---|
| Main bootstrap log | `C:\ProgramData\Logs\Init\InitLog.txt` |
| Bootstrap root | `C:\ProgramData\Bootstrap` |
| Downloads | `C:\ProgramData\Bootstrap\dl` |
| Work directory | `C:\ProgramData\Bootstrap\work` |
| Localization directory | `C:\ProgramData\Bootstrap\work\localization` |
| Validation script | `C:\ProgramData\Bootstrap\validation.ps1` |
| Run Command staged script | `C:\ProgramData\Bootstrap\run-command-init2.ps1` |
| BGInfo user log | `C:\ProgramData\Bootstrap\BGInfoUser.log` |
| BGInfo executable | `C:\Windows\System32\Bginfo.exe` |
| BGInfo config | `C:\Windows\default.bgi` |
| Background wallpaper | `C:\Windows\Web\Wallpaper\Background\background.png` |
| BGInfo generated wallpaper | `C:\Utils\BGInfo.bmp` |
| Common startup shortcut | `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\BGInfo.lnk` |
| azureadmin startup shortcut | `C:\Users\azureadmin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\BGInfo.lnk` |

## BGInfo And Wallpaper

The bootstrap downloads `background.png`, sets it as the base wallpaper, and runs BGInfo. BGInfo then generates `C:\Utils\BGInfo.bmp` and sets it as the final wallpaper with system information overlaid.

The helper forces:

- `WallpaperStyle = 10`
- `TileWallpaper = 0`

Run manually in an interactive user session:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\ProgramData\Bootstrap\Run-BGInfo.ps1 `
  -WallpaperScript C:\ProgramData\Bootstrap\Set-BackgroundWallpaper.ps1 `
  -WallpaperPath C:\Windows\Web\Wallpaper\Background\background.png `
  -BgInfoExe C:\Windows\System32\Bginfo.exe `
  -BgInfoConfig C:\Windows\default.bgi `
  -LogPath C:\ProgramData\Bootstrap\BGInfoUser.log
```

Portal Bastion browser sessions may suppress desktop background rendering. Native RDP or Bastion native client is more reliable for seeing wallpaper/BGInfo.

## Optional Localization

Localization scripts are optional and run from `scheduled.ps1` after the VM has been idle for 5 minutes, no users are logged on, scheduled packages have installed, and PATH updates have completed.

`scheduled.ps1` attempts these scripts from `localization_container_name` in order:

1. `localization.ps1`
2. `windows-localization.ps1` when `localization.ps1` is not present or does not complete
3. `<COMPUTERNAME>.ps1`
4. `<VM_NAME>.ps1` when different from `<COMPUTERNAME>.ps1`

Examples:

- Base Windows localization: `localization/localization.ps1`
- VM-specific localization: `localization/azuwipkijump601.ps1`

The VM-specific script can match either the final Windows computer name or the VM name passed to `scheduled.ps1`.

Missing optional blobs fail fast and are logged as skipped. Empty files and nonzero exit codes are also logged without failing the main bootstrap. Downloaded localization scripts are staged under:

```text
C:\ProgramData\Bootstrap\work\localization
```

Use localization scripts for environment or VM-specific configuration that should not be built into the shared module bootstrap.

## Scheduled Script

`init2.ps1` downloads:

```text
scripts/scheduled.ps1
```

It stages the file locally at:

```text
C:\ProgramData\Bootstrap\work\scheduled.ps1
```

Then it registers the `post-cloud-init` scheduled task:

- Trigger: boot trigger with a 5-minute delay, plus an idle trigger.
- Idle condition: starts only when the VM has been idle for 5 minutes.
- User-session guard: `scheduled.ps1` exits without disabling the task if any user session is still logged on.
- Package sequence: Az modules for Windows PowerShell 5.1, Az module copy to PowerShell 7, AWS CLI, Git, Terraform, Sysinternals Suite, Postman, MobaXterm, and AzCopy.
- End sequence: Defender cleanup, PATH updates, optional localization, then task disable.
- Action: `powershell.exe -NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File "<staged scheduled.ps1>" -StorageAccount "<iac_st>" -PackageContainer "<package container>" -LocalizationContainer "<localization container>" -VMName "<vm name>" -LogFile "<init log>"`
- Principal: `SYSTEM`.

Use `scheduled.ps1` for larger post-bootstrap actions that should run only after the VM is idle and no user sessions remain.

## Domain Join Helper

`domain-join.ps1` is a manual helper. It:

- Uses managed identity to call Key Vault REST APIs.
- Reads `domain-join-user` and `domain-join-password` by default.
- Calls `Add-Computer`.
- Does not require Az modules.

Example:

```powershell
.\domain-join.ps1 -DomainName '2join.us' -Env dev -Restart
```

Normal Terraform provisioning can use `JsonADDomainExtension`; the active `init2.ps1` path is
intended for cases that require an explicit domain controller and reads the join password from
the configured Key Vault secret by default (`kv-ccoe-cc-nonprod` / `domain-join-password`). The
password is converted to a `SecureString` before `Add-Computer` is called.

## Validation Script

When `scripts/validation.ps1` exists in storage, `init2.ps1` stages it to:

```text
C:\ProgramData\Bootstrap\validation.ps1
```

Example:

```powershell
powershell.exe -ExecutionPolicy Bypass -File C:\ProgramData\Bootstrap\validation.ps1 `
  -AppAdminGroup '<admin-groups>' `
  -AppUserGroup '<user-groups>'
```
