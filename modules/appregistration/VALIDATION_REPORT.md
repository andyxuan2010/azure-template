# Validation Report

## Checks Performed

- `terraform init -backend=false`
- `terraform fmt -recursive`
- `terraform validate`
- `terraform test`
- `terraform-docs markdown table --output-file README.md --output-mode inject modules/appregistration`

## Result

Validation completed successfully after standardizing the `appregistration` module. Terraform tests cover the minimal app registration path, App Service web redirect generation, and an exposed API with app roles, delegated scopes, pre-authorized applications, and workload identity federation.

## Notes

- Client secrets remain optional; workload identity federation is available for CI/CD scenarios that can avoid secrets.
- Key Vault storage for generated client secrets remains conditional on `create_client_secret = true` and `key_vault_id`.
- Admin consent automation is intentionally limited to application permissions (`type = "Role"`).
