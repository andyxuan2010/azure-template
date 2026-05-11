# Linux VM Localization Extension

This document explains the optional storage-backed Linux VM localization flow used by the `linuxvm` module when `enable_linux_vm_extension = true`.

## Purpose

The localization extension is a post-bootstrap customization phase that runs after the VM has already processed `custom_data` / cloud-init.

It is intended for:

- OS-family customization stored outside the Terraform repo, for example `ubuntu.sh` or `rhel.sh`
- VM-specific customization stored as a blob named after the VM hostname, for example `myvm001.sh`
- operational ownership of customization scripts in Azure Storage instead of inline Terraform content
- optional Terraform-managed upload of hostname-specific localization blobs when the consumer passes `localization_vm_script_content`

It is not a replacement for `init.sh`. The two phases have different responsibilities.

The full module bootstrap model has three places where guest configuration can run:

1. `custom_data` / cloud-init through `scripts/init.sh`
2. `post_init_script` appended after `init.sh`
3. the merged localization script assembled from storage-backed localization blobs

## Scripts Involved

The Linux VM build can involve up to four layers of scripting:

1. `scripts/init.sh`
   Base first-boot bootstrap rendered by Terraform into `custom_data`
2. `post_init_script`
   Optional inline customization appended after `init.sh` in the same first-boot path
3. OS localization script in Blob Storage
   Example: `ubuntu.sh`
4. VM-specific localization script in Blob Storage
   Example: `<vm-hostname>.sh`

When the localization extension is enabled, the OS script is treated as the preferred base localization layer and the VM-specific script is treated as an optional append-on-top layer. Either script may be skipped if the blob is missing, unreachable, or empty.

This means the merged localization script is the third bootstrap location, not a replacement for the first two.

## Time Sequence

The execution sequence is:

1. Terraform renders `scripts/init.sh`
2. Terraform appends `post_init_script` if provided
3. Terraform sends the combined payload to the VM as `custom_data`
4. On first boot, cloud-init consumes `custom_data`
5. `init.sh` runs
6. `post_init_script` runs next if provided
7. The VM finishes the first-boot path
8. If `enable_linux_vm_extension = true`, the `CustomScript` extension runs later as a separate phase
9. The extension runs a guest-side localization runner
10. The localization runner authenticates to Azure Storage using the VM's system-assigned managed identity
11. The localization runner tries to download the OS localization script from the IaC storage account container
12. The localization runner tries to download a VM-specific script named `<vm-hostname>.sh`
13. The localization runner merges whichever scripts were downloaded successfully into one combined script
14. If at least one script produced content, the merged localization script executes
15. If neither script is available, the runner exits successfully and skips localization

Terraform may also order the localization extension after optional resources such as the extra disk attachment or the Entra SSH extension when those features are enabled. That ordering is useful for keeping localization later in the module graph, but it is still a separate post-bootstrap phase inside the guest.

When `localization_vm_script_content` is used, Terraform also orders the managed VM-specific blob uploads before the localization extension resource. If no VM-specific blobs are passed, that dependency remains valid and the extension still runs normally.

Managed VM-specific blob-content changes are also reflected into the extension `timestamp` setting, so a later `terraform apply` can cause the localization extension to rerun with the updated VM-specific script content.

The module uses the Azure-supported `timestamp` setting for this rerun behavior instead of introducing custom public settings on the `CustomScript` extension.

When `disksize > 0`, Terraform also orders the localization extension after the VM data-disk attachment resource. If no extra data disk is requested, that dependency still remains valid because the attachment resource simply has zero instances.

Operational caveat:

- even when Terraform creates the localization extension late in the resource graph, guest-side timing can still make it appear slow
- long-running `init.sh` work, VM agent delays, storage RBAC propagation, or package-manager contention inside the guest can all delay localization completion
- keep localization scripts focused on post-bootstrap customization rather than heavy first-boot package baselines when possible

## Authentication

The localization extension requires:

- `enable_linux_vm_extension = true`
- `enable_system_assigned_identity = true`
- access to the shared IaC storage account

The module enforces the managed identity prerequisite with a Terraform precondition on the extension resource.

For storage authorization:

- the module enables the VM system-assigned managed identity
- the module grants `Storage Blob Data Reader` on the shared IaC storage account when the localization extension is enabled
- the `CustomScript` extension uses `managedIdentity = {}` to authenticate inside the guest
- the localization runner uses `azcopy login --identity` to fetch both the OS localization script and the VM-specific script

## Storage Layout

The shared IaC storage account is:

- `iac_st`

The blob container is controlled by:

- `localization_container_name`
- default: `localization`

The OS script blob is controlled by:

- `localization_os_script_name`
- example: `ubuntu.sh`

The VM-specific script name is derived automatically from the VM hostname:

- `<vm-hostname>.sh`

The module can optionally upload VM-specific blobs during `terraform apply` through:

- `localization_vm_script_content`

This input is a map keyed by blob name, for example:

- `"appvm601.sh" = file("${path.module}/scripts/appvm601.sh")`
- `"appvm602.sh" = file("${path.module}/scripts/appvm602.sh")`

Behavior note:

- the blob names are used as Terraform resource instance keys
- the script contents remain sensitive values inside Terraform
- use stable keys that exactly match the expected VM-specific blob names

The module does not manage the shared OS-level blob such as `ubuntu.sh`; that remains an external consumer-owned artifact.

The localization container lookup is also conditional:

- it is required when `enable_linux_vm_extension = true`
- it is required when at least one VM-specific blob upload is requested through `localization_vm_script_content`
- it is not required when neither of those features is used

Examples:

- `localization/ubuntu.sh`
- `localization/appvm601.sh`

## Merge Behavior

The extension builds a merged script locally on the VM:

- first the OS script content
- then the VM-specific script content if that blob exists

If the VM-specific script does not exist, the extension logs that condition and continues with the OS script only.

If the OS script does not exist, the extension logs that condition and continues with the VM-specific script only.

If neither script exists, or if both download as empty files, the extension exits successfully and skips localization.

## Logging And Troubleshooting

The first-boot `init.sh` path writes logs to:

- `/var/log/localization/init.log`
- `/var/log/cloud-init-output.log`
- `/var/log/cloud-init.log`

The localization runner writes logs to:

- `/var/log/localization/localization-<vm-hostname>.log`

Artifacts created by the extension include:

- downloaded OS script under `/opt/localization/`
- optional VM-specific script under `/opt/localization/`
- merged execution script at `/opt/localization/merged-localization.sh`

Useful troubleshooting checks:

- review `/var/log/localization/init.log` for timestamped bootstrap output from `init.sh`
- confirm the VM has a system-assigned managed identity
- confirm the VM has `Storage Blob Data Reader` on the IaC storage account
- confirm the container and blob names are correct
- confirm the OS script exists when OS-level localization is expected
- confirm the VM-specific script name matches the VM hostname plus `.sh`

## Recommended Usage

Use:

- `init.sh` for shared baseline build steps
- `post_init_script` for small first-boot tweaks that belong with the Terraform deployment
- localization extension for larger, externally managed post-bootstrap customization

Avoid:

- package installation in the merged localization script
- `apt-get`, `dnf`, `yum`, or similar package-manager operations in the merged localization script unless there is a carefully controlled reason

Reason:

- `init.sh` and `post_init_script` are the first two bootstrap paths and are the recommended places for package installation
- the merged localization script is a later third phase and can conflict with package-manager work started in the earlier bootstrap paths
- if package installation is unavoidable in localization scripts, add explicit wait/retry handling for package-manager locks and long-running bootstrap overlap

Consumer pattern note:

- A valid pattern is to install a workload earlier in `post_init_script` and reserve the later localization phase for storage-specific work such as preparing a managed disk, migrating existing application data, and activating the final mount path.
- In that pattern, the VM-specific localization script should stop the service if it is running, copy the existing application data to the managed disk, mount the managed disk at the final data path, and restart the service only if it was active before migration.
