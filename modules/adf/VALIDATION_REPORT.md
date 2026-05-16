# Validation Report

## Checks Performed

- `terraform init -backend=false`
- `terraform fmt -recursive`
- `terraform validate`
- `terraform test`
- `terraform-docs markdown table --output-file readme.md --output-mode inject modules/adf`

## Result

Validation completed successfully after standardizing the `adf` module. Terraform tests cover the baseline factory plan, direct-ID private endpoint plan, and managed virtual network with managed private endpoint plan.

## Notes

- SHIR dependency lookups now run only when SHIR is enabled.
- Key Vault lookup and Data Factory Key Vault Secrets User assignment now run only when SHIR is enabled or `enable_key_vault_secret_user_role_assignment = true`.
- Diagnostics remain backward compatible: a non-empty `log_analytics_workspace` map enables diagnostic settings even when `enable_diagnostics` is false.
