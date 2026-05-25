# Root Plan Harness

This example documents how to use the root Terraform files as a plan-validation harness for the modules in `modules/`.

## Purpose

- Validate that the root wiring still matches the module interfaces
- Turn on one module at a time for focused `terraform plan` runs
- Keep the default root state safe for documentation and CI validation

## Root Files

- `main.tf`: one module block per module directory, in exact `modules/` folder order
- `data.tf`: shared data lookups used by the root harness
- `variables.tf`: shared sample inputs, the landingzone-style `features` map, and the per-module toggle map
- `terraform.tfvars`: default sample values with high-level feature switches

## Default Behavior

By default, `module_plan_enabled` is all `false`, and `terraform.tfvars` can opt into groups of modules with `features`. That means:

- `terraform validate` can run without trying to create every module
- `terraform test -filter=tests/root-plan.tftest.hcl` exercises the root harness shape
- you can use `features` for landingzone-style high-level enablement
- you can enable a single `module_plan_enabled` entry when you want to test a focused real plan path
- CI can generate a temporary override file that enables exactly one module at a time for focused root-harness plans

## Feature Example

```hcl
features = {
  enable_private_dns                     = true
  enable_adf                             = true
  enable_azure_ai_search                 = true
  enable_azure_ai_service                = true
  enable_openai                          = true
  enable_app_services                    = true
  enable_app_registration_for_appservice = true
  enable_automation_accounts             = true
  enable_sqldb                           = true
}
```

## Focused Module Example

```hcl
features = {}

module_plan_enabled = {
  acr = true
}
```

## Validation Commands

```powershell
terraform fmt -recursive
terraform validate
terraform test -filter=tests/root-plan.tftest.hcl
terraform plan
```

Use real Azure-backed values in `terraform.tfvars` before enabling a live module plan.

For CI-style single-module validation without touching the configured backend:

```powershell
terraform init -backend=false
terraform validate
```

`terraform plan` still requires the configured backend to be initialized. In GitHub Actions, the root workflow uses `TF_BACKEND_READY` to skip plan jobs while the backend is temporarily unavailable.
