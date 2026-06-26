# Validation Report

- `terraform init -backend=false`: passed
- `terraform validate`: passed
- `terraform test`: passed, 3 mock-provider plan tests
- Notes: tests do not create Azure resources and cover federation and RBAC validation.
