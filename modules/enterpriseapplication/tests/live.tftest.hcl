provider "azuread" {}

provider "msgraph" {}

variables {
  application_id               = "11111111-1111-1111-1111-111111111111"
  account_enabled              = true
  app_role_assignment_required = false
  add_current_caller_as_owner  = true
  use_existing                 = true
}

run "plan" {
  command = plan

  assert {
    condition     = output.application_id == var.application_id
    error_message = "Enterprise Application application_id output did not match input."
  }

  assert {
    condition     = output.application_proxy_enabled == false
    error_message = "Application Proxy should be disabled by default."
  }
}

run "plan_application_proxy" {
  command = plan

  variables {
    application_id              = "22222222-2222-2222-2222-222222222222"
    add_current_caller_as_owner = true
    use_existing                = true
    create_application_proxy    = true

    application_proxy = {
      internal_url                 = "https://intranet.contoso.local/"
      external_url                 = "https://intranet-contoso.msappproxy.net/"
      external_authentication_type = "aadPreAuthentication"
    }
  }

  assert {
    condition     = output.application_proxy_enabled == true
    error_message = "Application Proxy should be enabled when create_application_proxy is true."
  }
}

run "plan_assignments_and_saml" {
  command = plan

  variables {
    application_id                = "33333333-3333-3333-3333-333333333333"
    add_current_caller_as_owner   = true
    use_existing                  = true
    app_role_assignment_required  = true
    preferred_single_sign_on_mode = "saml"
    saml_relay_state              = "https://app.contoso.com/saml"

    app_role_assignments = {
      default_access = {
        principal_object_id = "44444444-4444-4444-4444-444444444444"
      }
    }
  }

  assert {
    condition     = contains(keys(output.app_role_assignment_ids), "default_access")
    error_message = "App role assignment output should be keyed by input name."
  }
}
