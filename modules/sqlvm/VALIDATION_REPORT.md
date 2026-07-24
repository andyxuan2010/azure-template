# SQL VM Validation Report

## Scope

Reusable SQL Server on Azure VM module.

## Checks

| Check | Result |
| --- | --- |
| Terraform format | Passed |
| Terraform init without backend | Passed |
| Terraform validate | Passed |
| Terraform test | Passed, 5 tests |

## Notes

The module uses mocked provider tests for plan-time validation. Live deployment validation should be performed from a workload root module with real subnet, credentials, SQL licensing inputs, and any availability group/listener composition required by the workload.
