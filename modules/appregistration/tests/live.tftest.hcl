provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  display_name                = "appreg-iactest-prod"
  sign_in_audience            = "AzureADMyOrg"
  owners                      = []
  add_current_caller_as_owner = true
  create_service_principal    = true
  create_client_secret        = false
  tags = [
    "env:prod",
    "iac:terraform",
    "module:appregistration"
  ]
}

run "plan" {
  command = plan

  assert {
    condition     = output.display_name == var.display_name
    error_message = "App registration display_name output did not match input."
  }

  assert {
    condition     = length(output.web_redirect_uris) == 0
    error_message = "App registration should not create web redirect URIs in the minimal path."
  }
}

run "plan_web_app" {
  command = plan

  variables {
    display_name                = "appreg-web-prod"
    sign_in_audience            = "AzureADMyOrg"
    owners                      = []
    add_current_caller_as_owner = true
    create_service_principal    = true
    web_redirect_uris           = ["https://example.contoso.com/signin-oidc"]
    app_service_redirect_hostnames = [
      "appreg-web-prod.azurewebsites.net"
    ]
    app_service_auth_mode = "both"
    web_homepage_url      = "https://example.contoso.com"
    web_logout_url        = "https://example.contoso.com/logout"
    optional_claims = {
      id_token = [
        {
          name = "email"
        }
      ]
    }
    tags = [
      "env:prod",
      "iac:terraform",
      "module:appregistration"
    ]
  }

  assert {
    condition     = contains(output.web_redirect_uris, "https://appreg-web-prod.azurewebsites.net/.auth/login/aad/callback")
    error_message = "App Service Easy Auth redirect URI was not generated."
  }

  assert {
    condition     = contains(output.web_redirect_uris, "https://appreg-web-prod.azurewebsites.net/auth/callback")
    error_message = "App Service MSAL redirect URI was not generated."
  }
}

run "plan_exposed_api" {
  command = plan

  variables {
    display_name                      = "appreg-api-prod"
    sign_in_audience                  = "AzureADMyOrg"
    requested_access_token_version    = 2
    owners                            = []
    add_current_caller_as_owner       = true
    create_service_principal          = true
    prevent_duplicate_names           = true
    fallback_public_client_enabled    = false
    service_principal_account_enabled = true
    identifier_uris                   = ["api://appreg-api-prod"]
    app_roles = [
      {
        id                   = "11111111-1111-1111-1111-111111111111"
        value                = "Data.Read.All"
        display_name         = "Data reader"
        description          = "Read all application data."
        allowed_member_types = ["Application"]
      }
    ]
    oauth2_permission_scopes = [
      {
        id                         = "22222222-2222-2222-2222-222222222222"
        value                      = "Data.Read"
        admin_consent_display_name = "Read data"
        admin_consent_description  = "Allows the app to read data."
        user_consent_display_name  = "Read data"
        user_consent_description   = "Allows the app to read your data."
        type                       = "User"
      }
    ]
    known_client_applications = ["33333333-3333-3333-3333-333333333333"]
    pre_authorized_applications = {
      web = {
        authorized_client_id = "33333333-3333-3333-3333-333333333333"
        permission_ids       = ["22222222-2222-2222-2222-222222222222"]
      }
    }
    federated_identity_credentials = {
      github_main = {
        display_name = "github-main"
        issuer       = "https://token.actions.githubusercontent.com"
        subject      = "repo:CCOE-Azure-Terraform/azure-template:ref:refs/heads/main"
      }
    }
    tags = [
      "env:prod",
      "iac:terraform",
      "module:appregistration"
    ]
  }

  assert {
    condition     = contains(keys(output.pre_authorized_application_ids), "web")
    error_message = "Pre-authorized application output was not keyed by input name."
  }

  assert {
    condition     = contains(keys(output.federated_identity_credential_ids), "github_main")
    error_message = "Federated identity credential output was not keyed by input name."
  }
}
