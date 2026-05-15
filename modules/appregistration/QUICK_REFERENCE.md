# App Registration Quick Reference

Purpose: Provision Microsoft Entra application registrations, service principals, and optional client secrets.

## Required Inputs

- `display_name`: `string`

## Common Optional Inputs

- `app_service_redirect_hostnames`: `list(string)`
- `app_service_auth_mode`: `string`
- `required_resource_access`: `map(object(...))`
- `tags`: `set(string)`

## Primary Outputs

- `application_id`
- `application_object_id`
- `client_secret`
- `client_secret_key_id`
- `client_secret_key_vault_secret_id`
- `required_resource_access`
- `service_principal_object_id`
- `web_redirect_uris`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
