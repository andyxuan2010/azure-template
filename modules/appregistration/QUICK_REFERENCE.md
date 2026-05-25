# App Registration Quick Reference

Purpose: Provision Microsoft Entra app registrations, service principals, redirect URI blocks, exposed API roles/scopes, API permissions, federated identity credentials, and optional client secrets.

## Required Inputs

- `display_name`: `string`

## Common Optional Inputs

- `owners`: `list(string)`
- `add_current_caller_as_owner`: `bool`
- `sign_in_audience`: `string`
- `identifier_uris`: `list(string)`
- `group_membership_claims`: `set(string)`
- `requested_access_token_version`: `number`
- `web_redirect_uris`: `list(string)`
- `app_service_redirect_hostnames`: `list(string)`
- `app_service_auth_mode`: `string`
- `spa_redirect_uris`: `list(string)`
- `public_client_redirect_uris`: `list(string)`
- `web_homepage_url`: `string`
- `web_logout_url`: `string`
- `app_roles`: `list(object(...))`
- `oauth2_permission_scopes`: `list(object(...))`
- `required_resource_access`: `map(object(...))`
- `pre_authorized_applications`: `map(object(...))`
- `optional_claims`: `object(...)`
- `federated_identity_credentials`: `map(object(...))`
- `create_service_principal`: `bool`
- `service_principal_account_enabled`: `bool`
- `service_principal_app_role_assignment_required`: `bool`
- `create_client_secret`: `bool`
- `key_vault_id`: `string`
- `client_secret_key_vault_secret_name`: `string`
- `tags`: `set(string)`

## Primary Outputs

- `application_id`
- `application_object_id`
- `display_name`
- `service_principal_object_id`
- `service_principal_id`
- `client_secret`
- `client_secret_key_id`
- `client_secret_key_vault_secret_id`
- `required_resource_access`
- `app_role_ids`
- `oauth2_permission_scope_ids`
- `pre_authorized_application_ids`
- `federated_identity_credential_ids`
- `web_redirect_uris`
- `spa_redirect_uris`
- `public_client_redirect_uris`

## Test Commands

```powershell
terraform validate
terraform test
terraform test -filter="tests\live.tftest.hcl"
```

Notes:
- App role IDs and OAuth2 permission scope IDs should be stable GUIDs generated outside Terraform.
- Admin consent automation is intentionally limited to application permissions (`type = "Role"`).
- Workload identity federation avoids client secrets for CI/CD and is preferred where supported.
