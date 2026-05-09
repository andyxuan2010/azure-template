locals {
  suffix_map = {
    prod = "001"
    qa   = "301"
    dev  = "601"
    poc  = "701"
    test = "801"
    sbx  = "901"
  }

  subscription_map = {
    prod = "prod"
    qa   = "nonprod"
    dev  = "nonprod"
    poc  = "nonprod"
    test = "nonprod"
    sbx  = "sbx"
  }

  suffix       = lookup(local.suffix_map, var.app_env, "000")
  suffix_base  = tonumber(local.suffix)
  subscription = lookup(local.subscription_map, var.app_env, "sbx")

  bastion_resource_name       = try(trimspace(var.bastion_resource_name), "")
  bastion_resource_group_name = try(trimspace(var.bastion_resource_group_name), "")
  bastion_rbac_enabled        = local.bastion_resource_name != ""

  tags = merge(
    var.common_tags,
    var.rg_tags,
    {
      module   = "linuxvm"
      workload = var.workload
    }
  )

  app_admin_groups = distinct([
    for group in coalesce(var.app_admin_group, []) : trimspace(group)
    if trimspace(group) != ""
  ])
  app_user_groups = distinct([
    for group in coalesce(var.app_user_group, []) : trimspace(group)
    if trimspace(group) != ""
  ])
  app_user_group_list  = join(" ", local.app_user_groups)
  app_admin_group_list = join(" ", local.app_admin_groups)
  app_admin_group_principal_ids = {
    for group in local.app_admin_groups : group => group
  }
  app_user_group_principal_ids = {
    for group in local.app_user_groups : group => group
  }
  vm_admin_role_assignments = merge([
    for vm_index in range(var.app_vm_number) : {
      for group_key, principal_id in local.app_admin_group_principal_ids :
      "${vm_index}|${group_key}" => {
        vm_index     = vm_index
        principal_id = principal_id
      }
    }
  ]...)
  vm_user_role_assignments = merge([
    for vm_index in range(var.app_vm_number) : {
      for group_key, principal_id in local.app_user_group_principal_ids :
      "${vm_index}|${group_key}" => {
        vm_index     = vm_index
        principal_id = principal_id
      }
    }
  ]...)
  vm_names = [
    for vm_index in range(var.app_vm_number) :
    "${var.app_vm}${format("%03d", local.suffix_base + vm_index)}"
  ]
  zone_spread_enabled = var.enable_zone_spread && var.app_vm_number > 1
  vm_zones = {
    for vm_index in range(var.app_vm_number) :
    vm_index => (local.zone_spread_enabled ? var.availability_zones[vm_index % length(var.availability_zones)] : null)
  }
  localization_vm_script_blob_names = nonsensitive(toset(keys(var.localization_vm_script_content)))
  localization_vm_script_hashes = {
    for blob_name in local.localization_vm_script_blob_names :
    blob_name => nonsensitive(sha256(var.localization_vm_script_content[blob_name]))
  }
  localization_vm_script_timestamps = {
    for blob_name, blob_hash in local.localization_vm_script_hashes :
    blob_name => parseint(substr(blob_hash, 0, 7), 16)
  }
  localization_container_required        = var.enable_linux_vm_extension || length(local.localization_vm_script_blob_names) > 0
  iac_kv_id_effective                    = trimspace(var.iac_kv_id)
  iac_st_id_effective                    = trimspace(var.iac_st_id)
  iac_st_name_effective                  = trimspace(var.iac_st)
  iac_st_primary_blob_endpoint_effective = trimspace(var.iac_st_primary_blob_endpoint)
  localization_blob_base_url             = "${trimsuffix(local.iac_st_primary_blob_endpoint_effective, "/")}/${var.localization_container_name}"
  localization_os_script_url             = "${local.localization_blob_base_url}/${var.localization_os_script_name}"
  localization_vm_script_urls = {
    for vm_name in local.vm_names :
    vm_name => "${local.localization_blob_base_url}/${vm_name}.sh"
  }

  app_snet_id_effective = trimspace(var.app_snet_id)

  init_script = templatefile("${path.module}/scripts/init.sh", {
    ENV                 = local.subscription
    ADMIN_ACCESS_GROUPS = local.app_admin_group_list
    SSH_ACCESS_GROUPS   = local.app_user_group_list
    DOMAIN              = var.enable_domain_join ? var.domain : ""
    KEYVAULT_NAME       = var.iac_kv
    ADJOIN_USERNAME     = var.enable_domain_join ? replace(var.domain_join_user, "${split("\\\\", var.domain_join_user)[0]}\\\\", "") : ""
    SECRET_PASSWORD     = var.enable_domain_join ? "domain-join-password" : ""
  })

  # post_init_script is not a second bootstrap mechanism. It is appended to the end of the
  # rendered init.sh payload, so it runs in the same custom_data/cloud-init execution flow:
  # 1. Azure provisions the VM.
  # 2. custom_data starts on first boot.
  # 3. init.sh runs first.
  # 4. post_init_script runs immediately after init.sh if provided.
  # 5. The optional Linux VM extension, when enabled, is a later separate phase.
  post_init_script_block = trimspace(var.post_init_script) == "" ? "" : <<-EOT

    mkdir -p /opt/bootstrap
    cat <<'POST_INIT_EOF' >/opt/bootstrap/post-init.sh
    #!/bin/bash
    set -euo pipefail
    ${var.post_init_script}
    POST_INIT_EOF
    chmod 0700 /opt/bootstrap/post-init.sh
    /bin/bash /opt/bootstrap/post-init.sh
  EOT

  # init_script_final is the actual custom_data payload sent to the VM. It always starts with the
  # module-owned init.sh content and optionally appends post_init_script as an end-of-bootstrap hook.
  init_script_final = "${local.init_script}${local.post_init_script_block}"

  # The VM extension localization runner is intentionally separate from init.sh/post_init_script.
  # If enabled, it represents a later post-bootstrap execution phase after the custom_data path.
  vm_extension_localization_scripts = {
    for vm_name in local.vm_names :
    vm_name => templatefile("${path.module}/scripts/localization-runner.sh.tftpl", {
      localization_container_name = var.localization_container_name
      localization_os_script_name = var.localization_os_script_name
      localization_vm_script_name = "${vm_name}.sh"
      localization_vm_name        = vm_name
      localization_blob_base_url  = local.localization_blob_base_url
      localization_vm_script_url  = local.localization_vm_script_urls[vm_name]
    })
  }

  admin_username_effective = trimspace(var.azure-user)
  admin_password_effective = trimspace(var.azure-password)
  admin_ssh_key_effective  = trimspace(var.azure-ssh-key)
}
