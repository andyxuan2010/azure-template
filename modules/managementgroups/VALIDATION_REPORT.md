# Validation Report

- `terraform init -backend=false`: passed
- `terraform validate`: passed
- `terraform test`: passed, 2 mock-provider plan tests
- Notes: tests avoid tenant mutation and validate subscription placement inputs.
