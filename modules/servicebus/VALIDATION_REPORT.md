# Validation Report

- `terraform init -backend=false`: passed
- `terraform validate`: passed
- Provider-mocked, plan-only tests replace the former live Azure apply and cover entities, Premium features, RBAC, diagnostics, and invalid SKU/reference/permission combinations.
