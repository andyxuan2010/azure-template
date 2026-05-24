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

  create_web_block = (
    length(local.effective_web_redirect_uris) > 0 ||
    try(trimspace(var.web_homepage_url), "") != "" ||
    try(trimspace(var.web_logout_url), "") != ""
  )

  optional_claims = var.optional_claims == null ? {
    access_token = []
    id_token     = []
    saml2_token  = []
    } : {
    access_token = try(var.optional_claims.access_token, [])
    id_token     = try(var.optional_claims.id_token, [])
    saml2_token  = try(var.optional_claims.saml2_token, [])
  }

  optional_claims_enabled = (
    length(local.optional_claims.access_token) > 0 ||
    length(local.optional_claims.id_token) > 0 ||
    length(local.optional_claims.saml2_token) > 0
  )

  app_roles_by_value = {
    for role in var.app_roles : role.value => role
  }

  oauth2_permission_scopes_by_value = {
    for scope in var.oauth2_permission_scopes : scope.value => scope
  }

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

  federated_identity_credentials = {
    for key, credential in var.federated_identity_credentials : key => merge(credential, {
      audiences = try(credential.audiences, ["api://AzureADTokenExchange"])
    })
  }
}
