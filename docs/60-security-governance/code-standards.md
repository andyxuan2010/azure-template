# Azure Terraform Code Standards

These standards apply to the root composition harness, reusable modules, examples, scripts, and CI workflows. Use the [module documentation standard](../20-repository/module-documentation-standard.md) for the canonical README structure.

## Versions and reproducibility

- Use Terraform 1.7 or later within major version 1; mocked provider tests require 1.7.
- Bound provider versions to supported major versions in reusable modules. The root harness additionally constrains preview providers to a tested release range.
- Commit the root `.terraform.lock.hcl` with verified provider checksums. Review intentional upgrades with `terraform init -upgrade`; do not regenerate the lock on every CI run. Module and example lock files remain local.
- Pin GitHub Actions to immutable commit SHAs. Verify downloaded Terraform archives against the vendor's SHA-256 checksums before extracting or executing them.

## File layout and formatting

Use `main.tf`, `variables.tf`, `outputs.tf`, and `terraform.tf` inside modules. Split large implementations into descriptive files such as `monitoring.tf` when it improves readability. The root uses `versions.tf` for its Terraform and provider requirements.

Follow `.editorconfig` and `.gitattributes`: UTF-8, LF line endings for Terraform, shell, Python, YAML, and JSON, two-space Terraform indentation, and four-space Python indentation. Run `terraform fmt -recursive` before committing. Use stable `for_each` keys and avoid unnecessary changes to resource addresses or generated names.

## Inputs, outputs, and dependencies

Every variable has an explicit type and description; outputs describe their meaning. Validate supported values and fail early on incompatible settings. Document nullable inputs and distinguish missing values from empty strings. Keep provider configurations in calling roots and declare any configuration aliases in modules.

Pass resource IDs through module outputs and inputs where possible. Use data-source lookups only when the caller deliberately selects an existing resource. Keep naming and tags consistent with the [naming](naming-convention.md) and [tagging](tagging-standard.md) standards. Do not invent implicit ownership tags.

## Credentials and network controls

- Never supply shared fallback passwords in module code. SQL authentication requires a caller password or a Key Vault secret; Microsoft Entra-only authentication is an alternative.
- Mark credential inputs and outputs as sensitive and preserve sensitivity through locals. Declassify only presence checks needed for Terraform resource selection, never password contents.
- Require TLS 1.2 or newer. The affected module input validations reject TLS 1.0 and 1.1.
- Prefer private networking, managed identities, Microsoft Entra authorization, and narrowly scoped RBAC. Document any deliberate public endpoint or password-authentication opt-in.
- FortiGate defaults to SSH key authentication. Explicit password opt-in remains supported; changes to VM authentication can force replacement and require plan review.
- Keep `.env`, local credentials, state, saved plans, generated plan output, and automatic variable files out of Git. A sensitive Terraform value can still be present in state and binary plans; use protected state storage and restricted artifacts.

## Validation and tests

Run from the repository root:

```powershell
terraform fmt -check -recursive
terraform init -backend=false -input=false
terraform validate -no-color
python scripts/check_module_standards.py --mode fail
python -m unittest discover -s tests -p 'test_*.py'
.\scripts\Test-TerraformModules.ps1 -NoColor
```

The module runner selects `tests/unit.tftest.hcl` using the host path separator and fails when no modules or no passing test runs are selected. Unit tests use mocked providers and plan commands. Review `integration.tftest.hcl` separately before executing it; real-provider tests can interact with Azure and incur charges.

Run the root mocked harness with `terraform test -filter=tests/root-plan.tftest.hcl` on Linux, or `terraform test -filter='tests\root-plan.tftest.hcl'` on Windows. Require a non-empty passing summary. GitHub static validation runs this harness without Azure credentials; live plans remain gated by credentials and backend readiness.

## Documentation and publishing

Update the module README, relevant examples, and operational guidance when behavior changes. Regenerate affected reference tables with `terraform-docs -c .terraform-docs.yml modules/<name>` and stage new documentation in Git before refreshing the portal manifest with `./scripts/generate-docs-manifest.ps1`.

GitHub Pages packages only the public documentation and assets staged by `scripts/stage-docs.py`. Never publish the full working checkout. Keep deployment operations separate from checks and apply only a reviewed saved plan.

## References

- [Terraform dependency lock file](https://developer.hashicorp.com/terraform/language/files/dependency-lock)
- [Terraform download verification](https://developer.hashicorp.com/terraform/install)
- [Azure Event Hubs minimum TLS](https://learn.microsoft.com/en-us/azure/event-hubs/transport-layer-security-enforce-minimum-version)
