# Linux VM Module Complete

The `linuxvm` module has been updated to align more closely with the newer module pattern used by `storageaccount`, `keyvault`, `vnet`, and `rg`, while keeping the Linux-specific bootstrap flow.

Included artifacts:

- `terraform.tf`
- `locals.tf`
- `data.tf`
- `main.tf`
- `outputs.tf`
- `README.md`
- `EXAMPLES.md`
- `INDEX.md`
- `QUICK_REFERENCE.md`
- `VALIDATION_REPORT.md`

Current highlights:

- zero-padded multi-instance naming such as `001`, `002`, `003`
- configurable Linux image via `image_publisher`, `image_offer`, `image_sku`, `image_version`
- optional system-assigned managed identity, enabled by default
- optional Entra SSH login extension
- Entra SSH login now adds `Virtual Machine Administrator Login` for `app_admin_group` and `Virtual Machine User Login` for `app_user_group`
- optional `post_init_script` layered after the base `scripts/init.sh` in the same `custom_data` first-boot flow
- optional Linux VM extension localization flow kept separate from `init.sh` / `post_init_script` for later post-bootstrap customization from Azure Storage
- VM resource RBAC plus guest OS access driven by `app_admin_group` and `app_user_group`
- use `app_user_group` and `app_admin_group` as the active access-group inputs
