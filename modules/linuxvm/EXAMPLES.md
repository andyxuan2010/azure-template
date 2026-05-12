# Linux VM Examples

Examples below were regenerated from the current `linuxvm` module interface.

## Example 1: Minimal

```hcl
module "linuxvm" {
  source = "./modules/linuxvm"

  resource_group_name = "<resource_group_name>"
  subnet_name = "<subnet_name>"
  vm_name = "<vm_name>"
  vnet_name = "<vnet_name>"
  vnet_resource_group_name = "<vnet_resource_group_name>"
  iac_kv = "<iac_kv>"
  iac_rg = "<iac_rg>"
  iac_st = "<iac_st>"
  admin_username     = "azureadmin"
  admin_password = var.linux_vm_admin_password
  admin_ssh_key  = var.linux_vm_admin_ssh_public_key
}
```

## Example 2: Common Pattern

```hcl
module "linuxvm" {
  source = "./modules/linuxvm"

  resource_group_name = "<resource_group_name>"
  subnet_name = "<subnet_name>"
  vm_name = "<vm_name>"
  vnet_name = "<vnet_name>"
  vnet_resource_group_name = "<vnet_resource_group_name>"
  iac_kv = "<iac_kv>"
  iac_rg = "<iac_rg>"
  iac_st = "<iac_st>"
  admin_username      = "azureadmin"
  admin_password  = var.linux_vm_admin_password
  admin_ssh_key   = var.linux_vm_admin_ssh_public_key
  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group = ["00000000-0000-0000-0000-000000000000"]
}
```

## Example 3: Entra SSH Login

```hcl
module "linuxvm" {
  source = "./modules/linuxvm"

  resource_group_name      = "<resource_group_name>"
  subnet_name    = "<subnet_name>"
  vm_name      = "<vm_name>"
  vnet_name    = "<vnet_name>"
  vnet_resource_group_name = "<vnet_resource_group_name>"
  iac_kv      = "<iac_kv>"
  iac_rg      = "<iac_rg>"
  iac_st      = "<iac_st>"
  admin_username     = "azureadmin"
  admin_password = var.linux_vm_admin_password
  admin_ssh_key  = var.linux_vm_admin_ssh_public_key

  enable_entra_ssh_login = true

  # These groups keep the VM resource Reader/Contributor roles.
  # When Entra SSH is enabled, they also get the VM login roles:
  # - app_admin_group -> Virtual Machine Administrator Login
  # - app_user_group  -> Virtual Machine User Login
  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group  = ["00000000-0000-0000-0000-000000000000"]
}
```

## Example 4: Storage-Backed Localization

```hcl
module "linuxvm" {
  source = "./modules/linuxvm"

  resource_group_name      = "<resource_group_name>"
  subnet_name    = "<subnet_name>"
  vm_name      = "<vm_name>"
  vnet_name    = "<vnet_name>"
  vnet_resource_group_name = "<vnet_resource_group_name>"
  iac_kv      = "<iac_kv>"
  iac_rg      = "<iac_rg>"
  iac_st      = "<iac_st>"
  admin_username     = "azureadmin"
  admin_password = var.linux_vm_admin_password
  admin_ssh_key  = var.linux_vm_admin_ssh_public_key

  # Required for the storage-backed CustomScript extension authentication path.
  enable_system_assigned_identity = true
  enable_linux_vm_extension       = true

  # The extension tries the OS script first, then <vm-hostname>.sh.
  # Missing or empty localization blobs are skipped cleanly.
  localization_container_name = "localization"
  localization_os_script_name = "ubuntu.sh"
}
```

## Example 5: Spot Instance

```hcl
module "linuxvm" {
  source = "./modules/linuxvm"

  resource_group_name      = "<resource_group_name>"
  subnet_name    = "<subnet_name>"
  vm_name      = "<vm_name>"
  vnet_name    = "<vnet_name>"
  vnet_resource_group_name = "<vnet_resource_group_name>"
  iac_kv      = "<iac_kv>"
  iac_rg      = "<iac_rg>"
  iac_st      = "<iac_st>"
  admin_username     = "azureadmin"
  admin_password = var.linux_vm_admin_password
  admin_ssh_key  = var.linux_vm_admin_ssh_public_key

  enable_spot_instance = true
  spot_eviction_policy = "Deallocate"
  spot_max_bid_price   = -1
}
```

## Example 6: Optional VM-Specific Script Upload

```hcl
module "linuxvm" {
  source = "./modules/linuxvm"

  resource_group_name      = "<resource_group_name>"
  subnet_name    = "<subnet_name>"
  vm_name      = "myvm"
  vnet_name    = "<vnet_name>"
  vnet_resource_group_name = "<vnet_resource_group_name>"
  iac_kv      = "<iac_kv>"
  iac_rg      = "<iac_rg>"
  iac_st      = "<iac_st>"
  admin_username     = "azureadmin"
  admin_password = var.linux_vm_admin_password
  admin_ssh_key  = var.linux_vm_admin_ssh_public_key

  enable_system_assigned_identity = true
  enable_linux_vm_extension       = true
  localization_container_name     = "localization"
  localization_os_script_name     = "ubuntu.sh"

  # This only uploads VM-specific blobs such as myvm001.sh.
  # It does not manage the shared OS script blob such as ubuntu.sh.
  localization_vm_script_content = {
    "myvm001.sh" = file("${path.module}/scripts/myvm001.sh")
    "myvm002.sh" = file("${path.module}/scripts/myvm002.sh")
  }
}
```

## Example 7: Install First, Migrate Later

```hcl
module "linuxvm" {
  source = "./modules/linuxvm"

  resource_group_name      = "<resource_group_name>"
  subnet_name    = "<subnet_name>"
  vm_name      = "myvm"
  vnet_name    = "<vnet_name>"
  vnet_resource_group_name = "<vnet_resource_group_name>"
  iac_kv      = "<iac_kv>"
  iac_rg      = "<iac_rg>"
  iac_st      = "<iac_st>"
  admin_username     = "azureadmin"
  admin_password = var.linux_vm_admin_password
  admin_ssh_key  = var.linux_vm_admin_ssh_public_key

  data_disk_size_gb                        = 100
  enable_system_assigned_identity = true
  enable_linux_vm_extension       = true
  post_init_script                = file("${path.module}/scripts/post_init_script.sh")

  localization_vm_script_content = {
    "myvm001.sh" = file("${path.module}/scripts/myvm001.sh")
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Pass `admin_username`, `admin_password`, and `admin_ssh_key` directly; the module does not read these values from Key Vault.
- You can replace `vnet_name` plus `vnet_resource_group_name` with `vnet_id` when you already know the full VNet resource ID.
- Pass Entra group principal IDs for `app_admin_group` and `app_user_group`; use `[]` or `[""]` to skip group RBAC.
- Both `app_admin_group` and `app_user_group` get `Reader` on the VM resource group.
- When `bastion_resource_name` is set, both `app_admin_group` and `app_user_group` also get `Reader` on the Bastion resource group.
- When `bastion_resource_name` is set, both `app_admin_group` and `app_user_group` also get `Network Contributor` on that Bastion host.
- If the VM resource group or Bastion resource group already has the same direct `Reader` assignment for one of those principals at that exact scope, import it from the root module or with `terraform import` before apply.
- If that shared Bastion host already has the same `Network Contributor` assignment for one of those principals at the Bastion host scope, import it from the root module or with `terraform import` before apply.
- `enable_linux_vm_extension = true` requires `enable_system_assigned_identity = true`.
- `enable_spot_instance = true` sets the VM priority to `Spot` and applies `spot_eviction_policy` plus `spot_max_bid_price`.
- The localization extension looks for an OS script first, then an optional VM-specific script named `<vm-hostname>.sh`.
- `localization_vm_script_content` is optional and only manages the hostname-specific blobs you pass in.
- The keys in `localization_vm_script_content` must match the expected blob names such as `myvm001.sh` and `myvm002.sh`.
- The map values are treated as sensitive script content, while the keys remain visible as Terraform resource instance names.
- If either localization blob is missing, unreachable, or empty, the extension skips that script instead of failing the deployment.
- A practical consumer pattern is to install the workload in `post_init_script` and use the VM-specific localization script later for managed-disk mount or application-data migration logic.
- For private endpoint and diagnostics options, supply the full dependent inputs together.

## Related Terraform Tests

- `tests/live.tftest.hcl`
