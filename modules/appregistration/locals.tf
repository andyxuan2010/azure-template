locals {
  owners = distinct(compact(concat(
    var.owners,
    var.add_current_caller_as_owner ? [data.azuread_client_config.current.object_id] : []
  )))

  normalized_app_service_redirect_hostnames = distinct([
    for hostname in var.app_service_redirect_hostnames :
    trimspace(hostname)
    if trimspace(hostname) != ""
  ])

  app_service_redirect_paths_by_mode = {
    none      = []
    easy_auth = ["/.auth/login/aad/callback"]
    msal      = ["/auth/callback"]
    both      = ["/auth/callback", "/.auth/login/aad/callback"]
  }

  generated_app_service_redirect_uris = distinct(flatten([
    for hostname in local.normalized_app_service_redirect_hostnames : [
      for path in local.app_service_redirect_paths_by_mode[var.app_service_auth_mode] :
      "https://${hostname}${path}"
    ]
  ]))

  effective_web_redirect_uris = distinct(concat(
    var.web_redirect_uris,
    local.generated_app_service_redirect_uris
  ))

  normalized_required_resource_access = {
    for api_key, api in var.required_resource_access : api_key => {
      resource_app_id = api.resource_app_id
      resource_access = [
        for access in api.resource_access : {
          id                  = try(trimspace(access.id), "")
          type                = try(access.type, "Role")
          value               = try(trimspace(access.value), "")
          grant_admin_consent = try(access.grant_admin_consent, false)
        }
      ]
    }
  }

  flattened_required_resource_access = merge([
    for api_key, api in local.normalized_required_resource_access : {
      for access_key, access in api.resource_access : "${api_key}:${access_key}" => merge(access, {
        api_key         = api_key
        resource_app_id = api.resource_app_id
        resolved_id = access.id != "" ? access.id : (
          access.type == "Role" ?
          data.azuread_service_principal.api[api_key].app_role_ids[access.value] :
          data.azuread_service_principal.api[api_key].oauth2_permission_scope_ids[access.value]
        )
        resolved_value = access.value != "" ? access.value : null
      })
    }
  ]...)

  app_role_assignments = {
    for key, access in local.flattened_required_resource_access : key => access
    if access.grant_admin_consent && access.type == "Role"
  }
}
