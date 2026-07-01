resource "azuread_application" "this" {
  display_name                   = local.display_name
  description                    = var.description
  device_only_auth_enabled       = var.device_only_auth_enabled
  fallback_public_client_enabled = var.fallback_public_client_enabled
  group_membership_claims        = var.group_membership_claims
  identifier_uris                = var.identifier_uris
  marketing_url                  = var.marketing_url
  notes                          = var.notes
  oauth2_post_response_required  = var.oauth2_post_response_required
  owners                         = local.owners
  prevent_duplicate_names        = var.prevent_duplicate_names
  privacy_statement_url          = var.privacy_statement_url
  sign_in_audience               = var.sign_in_audience
  support_url                    = var.support_url
  terms_of_service_url           = var.terms_of_service_url

  api {
    known_client_applications      = var.known_client_applications
    mapped_claims_enabled          = var.mapped_claims_enabled
    requested_access_token_version = var.requested_access_token_version

    dynamic "oauth2_permission_scope" {
      for_each = local.oauth2_permission_scopes_by_value

      content {
        admin_consent_description  = oauth2_permission_scope.value.admin_consent_description
        admin_consent_display_name = oauth2_permission_scope.value.admin_consent_display_name
        enabled                    = oauth2_permission_scope.value.enabled
        id                         = oauth2_permission_scope.value.id
        type                       = oauth2_permission_scope.value.type
        user_consent_description   = try(oauth2_permission_scope.value.user_consent_description, null)
        user_consent_display_name  = try(oauth2_permission_scope.value.user_consent_display_name, null)
        value                      = oauth2_permission_scope.value.value
      }
    }
  }

  dynamic "app_role" {
    for_each = local.app_roles_by_value

    content {
      allowed_member_types = app_role.value.allowed_member_types
      description          = app_role.value.description
      display_name         = app_role.value.display_name
      enabled              = app_role.value.enabled
      id                   = app_role.value.id
      value                = app_role.value.value
    }
  }

  dynamic "feature_tags" {
    for_each = var.feature_tags == null ? [] : [var.feature_tags]

    content {
      custom_single_sign_on = try(feature_tags.value.custom_single_sign_on, false)
      enterprise            = try(feature_tags.value.enterprise, false)
      gallery               = try(feature_tags.value.gallery, false)
      hide                  = try(feature_tags.value.hide, false)
    }
  }

  dynamic "required_resource_access" {
    for_each = local.normalized_required_resource_access

    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = required_resource_access.value.resource_access

        content {
          id = (
            resource_access.value.id != "" ? resource_access.value.id : (
              resource_access.value.type == "Role" ?
              data.azuread_service_principal.api[required_resource_access.key].app_role_ids[resource_access.value.value] :
              data.azuread_service_principal.api[required_resource_access.key].oauth2_permission_scope_ids[resource_access.value.value]
            )
          )
          type = resource_access.value.type
        }
      }
    }
  }

  dynamic "web" {
    for_each = local.create_web_block ? [1] : []

    content {
      homepage_url  = var.web_homepage_url
      logout_url    = var.web_logout_url
      redirect_uris = local.effective_web_redirect_uris

      implicit_grant {
        access_token_issuance_enabled = var.web_implicit_grant_access_token_issuance_enabled
        id_token_issuance_enabled     = var.web_implicit_grant_id_token_issuance_enabled
      }
    }
  }

  dynamic "single_page_application" {
    for_each = length(var.spa_redirect_uris) > 0 ? [1] : []

    content {
      redirect_uris = var.spa_redirect_uris
    }
  }

  dynamic "public_client" {
    for_each = length(var.public_client_redirect_uris) > 0 ? [1] : []

    content {
      redirect_uris = var.public_client_redirect_uris
    }
  }

  dynamic "optional_claims" {
    for_each = local.optional_claims_enabled ? [1] : []

    content {
      dynamic "access_token" {
        for_each = local.optional_claims.access_token

        content {
          additional_properties = try(access_token.value.additional_properties, [])
          essential             = try(access_token.value.essential, false)
          name                  = access_token.value.name
          source                = try(access_token.value.source, null)
        }
      }

      dynamic "id_token" {
        for_each = local.optional_claims.id_token

        content {
          additional_properties = try(id_token.value.additional_properties, [])
          essential             = try(id_token.value.essential, false)
          name                  = id_token.value.name
          source                = try(id_token.value.source, null)
        }
      }

      dynamic "saml2_token" {
        for_each = local.optional_claims.saml2_token

        content {
          additional_properties = try(saml2_token.value.additional_properties, [])
          essential             = try(saml2_token.value.essential, false)
          name                  = saml2_token.value.name
          source                = try(saml2_token.value.source, null)
        }
      }
    }
  }

  tags = var.tags
}

resource "azuread_service_principal" "this" {
  count = var.create_service_principal ? 1 : 0

  account_enabled              = var.service_principal_account_enabled
  app_role_assignment_required = var.service_principal_app_role_assignment_required
  client_id                    = azuread_application.this.client_id
  notification_email_addresses = var.service_principal_notification_email_addresses
  owners                       = local.owners
}

resource "azuread_app_role_assignment" "admin_consent" {
  for_each = local.app_role_assignments

  app_role_id         = each.value.resolved_id
  principal_object_id = azuread_service_principal.this[0].object_id
  resource_object_id  = data.azuread_service_principal.api[each.value.api_key].object_id
}

resource "time_offset" "client_secret_expiry" {
  count = var.create_client_secret ? 1 : 0

  offset_hours = tonumber(replace(var.client_secret_end_date_relative, "h", ""))
}

resource "azuread_application_password" "this" {
  count = var.create_client_secret ? 1 : 0

  application_id      = azuread_application.this.id
  display_name        = var.client_secret_display_name
  end_date            = time_offset.client_secret_expiry[count.index].rfc3339
  rotate_when_changed = var.client_secret_rotate_when_changed
}

resource "azurerm_key_vault_secret" "client_secret" {
  count = var.create_client_secret && try(trimspace(var.key_vault_id), "") != "" ? 1 : 0

  name         = var.client_secret_key_vault_secret_name
  value        = azuread_application_password.this[0].value
  key_vault_id = var.key_vault_id
  content_type = "Client secret for ${azuread_application.this.client_id}"
}

resource "azuread_application_pre_authorized" "this" {
  for_each = var.pre_authorized_applications

  application_id       = azuread_application.this.id
  authorized_client_id = each.value.authorized_client_id
  permission_ids       = each.value.permission_ids
}

resource "azuread_application_federated_identity_credential" "this" {
  for_each = local.federated_identity_credentials

  application_id = azuread_application.this.id
  audiences      = each.value.audiences
  description    = try(each.value.description, null)
  display_name   = each.value.display_name
  issuer         = each.value.issuer
  subject        = each.value.subject
}
