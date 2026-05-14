resource "azuread_application" "this" {
  display_name            = var.display_name
  owners                  = local.owners
  sign_in_audience        = var.sign_in_audience
  identifier_uris         = var.identifier_uris
  group_membership_claims = var.group_membership_claims

  api {
    requested_access_token_version = var.requested_access_token_version
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
    for_each = length(local.effective_web_redirect_uris) > 0 ? [1] : []

    content {
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

  tags = var.tags
}

resource "azuread_service_principal" "this" {
  count = var.create_service_principal ? 1 : 0

  client_id = azuread_application.this.client_id
  owners    = local.owners
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

  application_id = azuread_application.this.id
  display_name   = var.client_secret_display_name
  end_date       = time_offset.client_secret_expiry[count.index].rfc3339
}

resource "azurerm_key_vault_secret" "client_secret" {
  count = var.create_client_secret && try(trimspace(var.key_vault_id), "") != "" ? 1 : 0

  name         = var.client_secret_key_vault_secret_name
  value        = azuread_application_password.this[0].value
  key_vault_id = var.key_vault_id
  content_type = "Client secret for ${azuread_application.this.client_id}"
}
