# Root Plan Harness

This example documents how to use the root Terraform files as a plan-validation harness for the modules in `modules/`.

## Purpose

- Validate that the root wiring still matches the module interfaces
- Turn on one module at a time for focused `terraform plan` runs
- Keep the default root state safe for documentation and CI validation

## Root Files

- `main.tf`: one module block per module directory, in exact `modules/` folder order
- `data.tf`: shared data lookups used by the root harness
- `variables.tf`: shared sample inputs and per-module toggle map
- `terraform.tfvars`: default sample values with all module toggles disabled

## Default Behavior

By default, all values in `module_plan_enabled` are `false`. That means:

- `terraform validate` can run without trying to create every module
- `terraform test -filter=tests/root-plan.tftest.hcl` exercises the root harness shape
- you can enable a single module when you want to test a real plan path
- CI can generate a temporary override file that enables exactly one module at a time for focused root-harness plans

## Example

```hcl
module_plan_enabled = {
  acr                  = true
  adf                  = false
  aks                  = false
  appregistration      = false
  appservice           = false
  appserviceplan       = false
  automationaccount    = false
  azure_ai_service     = false
  azure_ai_search      = false
  databricks           = false
  eventhub             = false
  firewall             = false
  functionapp          = false
  keyvault             = false
  linuxvm              = false
  loganalytics         = false
  logicapp             = false
  managedidentity      = false
  managementgroups     = false
  nsg                  = false
  openai               = false
  policy               = false
  private_dns          = false
  rg                   = false
  roleassignments      = false
  route_table          = false
  servicebus           = false
  sqldb                = false
  sqlmi                = false
  sqlmi_db             = false
  storageaccount       = false
  subscription_vending = false
  vnet                 = false
  winvm                = false
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
