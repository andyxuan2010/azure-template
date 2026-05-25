# Validation Report

- `terraform init -backend=false`: passed
- `terraform validate`: passed
- `terraform test`: passed
- Notes: live test now uses a generated fixture name so repeated runs do not depend on a fixed NSG name.
