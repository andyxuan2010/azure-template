# Linux VM `init.sh`

This document explains what [init.sh](init.sh) does in the `linuxvm` module and how it is used during provisioning.

## Purpose

`init.sh` is the base Linux bootstrap script for the module. Terraform renders it through `templatefile(...)` and sends it to Azure as the VM `custom_data` payload.

The script is responsible for baseline guest OS preparation, package installation, optional AD join, and guest OS access configuration.

It now also mirrors its output into a dedicated log at `/var/log/localization/init.log` while still allowing the normal cloud-init logs to capture the same run.

## How It Is Used

The module builds the final cloud-init payload in:

- [locals.tf](../locals.tf)

The VM consumes it here:

- [main.tf](../main.tf)

If `post_init_script` is provided, it is appended after the base `init.sh` content and executed at the end of the same bootstrap flow. It is not a separate VM extension phase.

## `post_init_script` Purpose

`post_init_script` exists for small VM-specific customization that should happen after the module's standard Linux baseline has already run.

Use it when you want to:

- add a few extra packages or configuration changes after the shared baseline
- place small app-team customization in the same first-boot path
- keep the core `init.sh` generic while still allowing per-deployment tweaks

Do not think of `post_init_script` as a separate delivery mechanism. It is just extra shell content appended to the end of the rendered `custom_data` payload.

For larger or externally managed scripts, the better fit is the optional Linux VM extension path rather than `post_init_script`.

For the storage-backed extension flow, see:

- [LOCALIZATION.md](LOCALIZATION.md)

For AD domain join versus Entra SSH login behavior, see:

- [Authentication guide](../docs/authentication.md)

## Execution Sequence

The time sequence behind the scenes is:

1. Terraform renders `scripts/init.sh`.
2. If `post_init_script` is set, Terraform appends it after `init.sh` inside the same generated payload.
3. Terraform sends that combined payload to the VM as `custom_data`.
4. On first boot, cloud-init consumes `custom_data`.
5. The base `init.sh` logic runs first.
6. The appended `post_init_script` content runs next, if provided.
7. If the optional Linux VM extension is enabled, that is a later and separate phase after the `custom_data` path.
8. The localization extension can then download and run externally managed post-bootstrap scripts from Azure Storage.

## High-Level Flow

1. Detect the OS and select `apt-get`, `dnf`, or `yum`.
2. Prepare the `azureadmin` shell environment and SSH folders.
3. Apply SSH, shell, and sysctl baseline hardening.
4. Append built-in public keys to `authorized_keys`.
5. Install distro-native packages for DevOps, networking, monitoring, troubleshooting, packaging, and security.
6. Enable supporting services when available.
7. Install additional tools such as Docker Compose, Terraform CLI, AzCopy, `yq`, and ARM TTK.
8. Install and configure Azure CLI extras such as Azure DevOps CLI and Bicep.
9. Authenticate to Azure using the VM managed identity.
10. Retrieve the domain join username and password from Key Vault when `enable_domain_join = true` and the username is not supplied directly.
11. Join AD when `enable_domain_join = true` and the required tools and values are available.
12. Configure guest OS access for admin and user groups.
13. Perform a final package refresh and reboot.

## Current Features

- OS detection for Ubuntu and RHEL-family images
- package manager abstraction for `apt-get`, `dnf`, and `yum`
- dedicated bootstrap log at `/var/log/localization/init.log`
- UTC timestamp prefixing for bootstrap output and `set -x` command tracing
- baseline SSH tuning and hardening
- shell/session defaults such as `umask` and timeout
- selected sysctl hardening
- package installation for common admin, DevOps, platform, packaging/build, networking, and troubleshooting tools
- container tooling with Docker and Podman
- Azure CLI, Azure DevOps CLI extension, AzCopy, Bicep, AWS CLI, `kubectl`, `helm`, `eksctl`, and `oc`
- Terraform CLI, Ansible, Git, GitHub CLI, PowerShell, .NET SDK/runtime, `jq`, and `yq`
- Docker Compose best-effort installation from GitHub releases
- shell aliases for common tools such as Docker, AWS, `kubectl`, `helm`, `oc`, and `eksctl`
- Optional AD join via managed identity plus Key Vault secret lookup
- guest OS group-based SSH and sudo access
- final package refresh plus automatic reboot
- modern Microsoft apt keyring/repository setup for Ubuntu Azure CLI, PowerShell, and .NET installation
- dynamic Ubuntu codename/version detection so Microsoft apt repo entries match the selected Ubuntu image family
- architecture-aware downloads for AWS CLI, `kubectl`, and `eksctl`

## Packages and Tooling

The script installs a practical baseline of tools. The exact package names vary by distro.

Examples include:

- IaC and DevOps:
  `terraform`, `ansible`, `git`, `git-lfs`, `gh`, `az`, Azure DevOps CLI, `bicep`, `azcopy`, `jq`, `yq`
- PowerShell and .NET:
  `powershell`, `.NET SDK`, `.NET runtime`, `aspnetcore-runtime`, `nuget`
- container and platform tooling:
  `docker`, `podman`, `kubectl`, `helm`, `eksctl`, `oc`
- packaging and build utilities:
  `build-essential` or `gcc`/`make`, `rpm`, `rpm-build`, `dpkg-dev`, `alien`, `debhelper`, `createrepo_c`
- scripting and package support:
  `python3`, `python3-pip`, `curl`, `wget`
- monitoring and troubleshooting:
  `htop`, `btop`, `iotop`, `iftop`, `ncdu`, `strace`, `lsof`, `sysstat`, `vmstat`, `iostat`
- networking and diagnostics:
  `nmap`, `tcpdump`, `mtr`, `dig`, `nslookup`, `curl`, `httpie`, `net-tools`, `iproute2` or `iproute`
- security and hardening:
  `lynis`, `fail2ban`, `gnupg`, audit/time-sync packages
- shell and terminal:
  `tmux`, `screen`, `vim`, `less`

Common Linux commands made available through installed packages include:

- `vmstat`, `iostat` from `sysstat`
- `dig` and `nslookup` from `dnsutils` or `bind-utils`
- `ip` from `iproute2` or `iproute`

The script is intentionally best-effort for some packages and third-party tools so image-specific differences do not cause an immediate hard stop.

Additional best-effort installed tools include:

- Docker Compose
- Terraform CLI
- AzCopy
- ARM TTK
- `yq`

On Ubuntu, the script also:

- removes older Microsoft apt repo/key files before the first `apt-get update`
- installs the Microsoft signing key into `/etc/apt/keyrings/microsoft.gpg`
- derives the Ubuntu codename and version from `/etc/os-release`
- uses a `.sources` file for Azure CLI plus a keyring-backed repo entry for Microsoft product packages that matches the detected Ubuntu release
- installs PowerShell and .NET from the Microsoft product repository

On RHEL-family images, the script:

- uses `dnf` or `yum` package flows when available
- configures the Microsoft Azure CLI yum repository directly
- treats more package groups as best-effort because package names and repository availability vary more between RHEL-family images

## Access Model

The script receives group values from Terraform-rendered template variables:

- `SSH_ACCESS_GROUPS`
- `ADMIN_ACCESS_GROUPS`

Current intended behavior:

- user groups get guest OS SSH access
- admin groups get guest OS SSH access plus sudo access

At the Terraform module level, those same groups are also used for Azure RBAC on the VM resource:

- `app_user_group` -> `Reader`
- `app_admin_group` -> `Contributor`

When `enable_entra_ssh_login = true`, the module also adds Azure VM login RBAC:

- `app_user_group` -> `Virtual Machine User Login`
- `app_admin_group` -> `Virtual Machine Administrator Login`

## SSH and Key Material

The script currently does all of the following:

- uses the Terraform-provided SSH public key for the VM admin account through the VM resource itself
- appends one built-in static public key into both `/root/.ssh/authorized_keys` and `/home/azureadmin/.ssh/authorized_keys`
- enables password authentication in SSH
- disables direct root login in SSH

This means the guest bootstrap currently mixes:

- Azure/Key Vault managed SSH public key injection
- a hardcoded static public key appended by `init.sh`

That is important operationally and should be reviewed if a stricter SSH posture is required.

## AD Join Behavior

The script expects:

- Azure CLI available on the guest
- VM managed identity enabled
- access to the shared Key Vault
- `realm` and related packages available

When `enable_domain_join = false`, Terraform renders empty AD join inputs into `init.sh`, and the script now logs that domain join is disabled and skips the entire AD join flow without attempting Azure login, Key Vault secret retrieval, or `realm join`.

If those requirements are not met, the script now degrades more safely and logs the failure instead of crashing at the first unsupported command.

## Logging

`init.sh` runs inside the `custom_data` / cloud-init path, so its output is still visible in the default cloud-init logs:

- `/var/log/cloud-init-output.log`
- `/var/log/cloud-init.log`

In addition, the script now writes a standalone log to:

- `/var/log/localization/init.log`

Each line is prefixed with a UTC timestamp, and `set -x` trace lines also include timestamps so long-running commands are easier to correlate during troubleshooting.

## OS Compatibility

Best supported:

- Ubuntu
- RHEL-family images such as RHEL, Rocky, AlmaLinux, Oracle Linux, and similar distributions with `dnf` or `yum`

Important note:

- compatibility has been improved for non-Ubuntu images
- Ubuntu 22.04 and Ubuntu 24.04 are both handled more safely because repository metadata is now derived from the guest image instead of hard-coded
- the script is still operationally biased toward Ubuntu and RHEL-family package ecosystems
- some tools or package names may still need image-specific adjustment for less common distributions
- some tools such as ARM TTK are installed best-effort and are more useful when PowerShell is available on the image

## Hardening Included

Current low-risk hardening includes:

- SSH keepalive settings
- root login disabled in SSH
- X11 forwarding disabled
- reduced SSH login grace and max auth tries
- restrictive shell `umask`
- session timeout
- selected sysctl protections for redirects, source routing, and syncookies
- audit and time-sync service enablement when available

Current usability/operator improvements include:

- shell aliases for common commands
- bash completion hooks where available
- command history persistence
- preinstalled operational tooling for diagnostics and DevOps work

## What This Script Does Not Do

- it does not replace distro-specific configuration management
- it does not guarantee identical behavior across every Linux distribution
- it does not manage application deployment logic beyond base OS preparation
- it does not inject SSH private keys
- it does not guarantee every requested third-party tool is available from every distro repository
- it currently appends a built-in public key, which may not fit all security baselines

## Related Inputs

Useful module inputs that affect this script or the resulting bootstrap behavior:

- `app_user_group`
- `app_admin_group`
- `app_user_group`
- `iac_kv`
- `domain`
- `domain_join_user`
- `domain_join_username_secret_name`
- `enable_domain_join`
- `post_init_script`
- image selection inputs: `image_publisher`, `image_offer`, `image_sku`, `image_version`

## Validation

Current validation performed locally:

- shell syntax check with `bash -n`
- Terraform module validation with `terraform validate`

Runtime caveat:

- this validation confirms shell syntax and Terraform template rendering
- it does not prove every package, repository, or third-party download succeeds on every Linux image at runtime
- RHEL-family behavior still depends on which repositories are enabled on the chosen image, so some optional tools may be skipped without failing the overall bootstrap
