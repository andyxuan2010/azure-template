resource "azuread_service_principal" "this" {
  account_enabled               = var.account_enabled
  app_role_assignment_required  = var.app_role_assignment_required
  client_id                     = var.application_id
  description                   = var.description
  login_url                     = var.login_url
  notes                         = var.notes
  notification_email_addresses  = var.notification_email_addresses
  owners                        = local.owners
  preferred_single_sign_on_mode = var.preferred_single_sign_on_mode
  use_existing                  = var.use_existing

  dynamic "feature_tags" {
    for_each = var.feature_tags == null ? [] : [var.feature_tags]

    content {
      custom_single_sign_on = try(feature_tags.value.custom_single_sign_on, false)
      enterprise            = try(feature_tags.value.enterprise, true)
      gallery               = try(feature_tags.value.gallery, false)
      hide                  = try(feature_tags.value.hide, false)
    }
  }

  dynamic "saml_single_sign_on" {
    for_each = var.saml_relay_state == null ? [] : [var.saml_relay_state]

    content {
      relay_state = saml_single_sign_on.value
    }
  }
}

resource "azuread_app_role_assignment" "this" {
  for_each = var.app_role_assignments

  app_role_id         = each.value.app_role_id
  principal_object_id = each.value.principal_object_id
  resource_object_id  = azuread_service_principal.this.object_id
}

resource "msgraph_update_resource" "application_proxy" {
  count = var.create_application_proxy ? 1 : 0

  url                     = "applications/${data.azuread_application.this[0].object_id}"
  api_version             = "beta"
  body                    = local.application_proxy_body
  ignore_missing_property = true

  read_query_parameters = {
    "$select" = ["id,appId,onPremisesPublishing"]
  }

  response_export_values = {
    external_url = "onPremisesPublishing.externalUrl"
    internal_url = "onPremisesPublishing.internalUrl"
  }

  depends_on = [azuread_service_principal.this]
}
