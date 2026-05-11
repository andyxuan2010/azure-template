# Validation Report

- `terraform init -backend=false`: passed
- `terraform validate`: passed
- `terraform test`: passed
- Notes: test is `plan`-based to avoid mutating tenant hierarchy during routine validation.
