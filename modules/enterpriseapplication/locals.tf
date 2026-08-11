locals {
  owners = distinct(compact(concat(
    var.owners,
    var.add_current_caller_as_owner ? [data.azuread_client_config.current.object_id] : []
  )))

  application_proxy_body = var.application_proxy == null ? null : {
    onPremisesPublishing = merge({
      internalUrl                              = var.application_proxy.internal_url
      externalUrl                              = var.application_proxy.external_url
      externalAuthenticationType               = var.application_proxy.external_authentication_type
      applicationServerTimeout                 = var.application_proxy.application_server_timeout
      isBackendCertificateValidationEnabled    = var.application_proxy.is_backend_certificate_validation_enabled
      isHttpOnlyCookieEnabled                  = var.application_proxy.is_http_only_cookie_enabled
      isPersistentCookieEnabled                = var.application_proxy.is_persistent_cookie_enabled
      isSecureCookieEnabled                    = var.application_proxy.is_secure_cookie_enabled
      isStateSessionEnabled                    = var.application_proxy.is_state_session_enabled
      isTranslateHostHeaderEnabled             = var.application_proxy.is_translate_host_header_enabled
      isTranslateLinksInBodyEnabled            = var.application_proxy.is_translate_links_in_body_enabled
      isContinuousAccessEvaluationEnabled      = var.application_proxy.is_continuous_access_evaluation_enabled
      trafficRoutingMethod                     = var.application_proxy.traffic_routing_method
      useAlternateUrlForTranslationAndRedirect = var.application_proxy.use_alternate_url_for_translation_and_redirect
      }, {
      for key, value in {
        alternateUrl                           = try(var.application_proxy.alternate_url, null)
        verifiedCustomDomainKeyCredential      = try(var.application_proxy.verified_custom_domain_key_credential, null)
        verifiedCustomDomainPasswordCredential = try(var.application_proxy.verified_custom_domain_password_credential, null)
        singleSignOnSettings                   = try(var.application_proxy.single_sign_on_settings, null)
      } : key => value
      if value != null
    })
  }
}
