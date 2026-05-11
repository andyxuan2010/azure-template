# Validation Report

## Checks Performed

- `terraform init -backend=false`
- `terraform validate`

## Result

Validation completed successfully for the `linuxvm` module in local testing.

Validated behavior reflected in current docs/examples:

- preferred access inputs are `app_user_group` and `app_admin_group`
- `app_admin_group` maps to VM `Contributor` plus guest OS sudo access for the domain-join path
- `app_user_group` maps to VM `Reader` plus guest OS SSH access for the domain-join path
- when `enable_entra_ssh_login = true`, `app_admin_group` also maps to `Virtual Machine Administrator Login`
- when `enable_entra_ssh_login = true`, `app_user_group` also maps to `Virtual Machine User Login`
- `post_init_script` is supported as an optional layer after `scripts/init.sh`
- Linux image selection is configurable through image variables
