# Contributing

Propose changes through a branch and a pull request. Keep module interfaces stable; when an input or output changes, record it in [CHANGELOG.md](CHANGELOG.md) and explain the migration in the pull request.

## Module Standard

- Directory names are lowercase `snake_case` and match the Azure product they manage (for example `key_vault`, `app_service`). Abbreviations that are standard in the Azure Cloud Adoption Framework (`rg`, `aks`, `acr`, `adf`, `nsg`, `vnet`) are kept.
- Each module contains `README.md`, `main.tf`, `variables.tf`, `outputs.tf`, `locals.tf` when needed, and `versions.tf`.
- `versions.tf` uses `required_version = ">= 1.7.0, < 2.0.0"` and bounded provider ranges such as `>= 4.0, < 5.0`.
- Every module has `examples/basic` and `examples/complete`. Each example has a `README.md` with a `## Usage` heading.
- Every module has a `tests/*.tftest.hcl` file.
- Inputs that accept a secret are `sensitive = true`. Inputs with a non-null default use `nullable = false` unless the module tests for `null`.

See [module documentation standard](docs/20-repository/module-documentation-standard.md) for the README structure.

## Checks Before a Pull Request

```powershell
terraform fmt -check -recursive
pwsh -NoProfile -File scripts/Test-TerraformModules.ps1
python scripts/check_module_standards.py
pwsh -NoProfile -File scripts/New-DocsManifest.ps1
```

Run `terraform validate` in the examples you changed. Commit the regenerated `docs-manifest.json` when you add or remove Markdown files.

## Pre-commit

Install the hooks with `pre-commit install` (see [pre-commit setup](docs/60-security-governance/pre-commit-setup.md)).
