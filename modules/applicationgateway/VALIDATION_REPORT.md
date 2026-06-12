# Validation Report

- `terraform validate`: passed
- `terraform test -filter='tests\live.tftest.hcl'`: passed

Notes:
- `WAF_v2` requires `waf_configuration`.
- Each routing rule must reference an existing listener and backend configuration.
