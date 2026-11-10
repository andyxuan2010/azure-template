# Changelog

All notable changes to this repository are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Dedicated `ado_service_connection_acr` and `ado_service_connection_azurerm` bootstrap modules with secretless managed-identity federation, explicit pipeline authorization, executable examples, generated references, and mocked security tests.

- `examples/complete` for every module that lacked one, and a `## Usage` section for every example README.
- `SECURITY.md`, `CONTRIBUTING.md`, and this changelog as the common repository set.
- `.github/actions/setup-terraform` and `.github/actions/terraform-init` composite actions. The pipelines use them in place of repeated setup and init steps.
- actionlint job for workflows, and TFLint in static validation with a `.tflint.hcl` that uses the bundled terraform ruleset.
- Terraform Identifiers section in the naming convention (snake_case identifiers, hyphens in Azure resource names).

### Changed

- Expanded Azure DevOps service connection documentation and all four examples with placeholder variable files, effective trust-name outputs, staged authorization, upgrade guidance, and workload smoke-test instructions. Corrected CI test coverage guidance.

- Azure DevOps connection modules generate distinct default federated credential names and reject duplicate pipeline IDs. Existing users of the original default must explicitly retain `ado-service-connection` to avoid trust replacement; examples now provision RBAC before pipeline authorization and tests verify federation wiring using fully mocked providers.

- Renamed module directories to `snake_case` (for example `keyvault` to `key_vault`, `appservice` to `app_service`). Update module `source` paths in callers. Terraform resource addresses and module labels are unchanged, so existing state is not affected.
- Renamed each module's `terraform.tf` to `versions.tf`, matching the standard module layout.
- Renamed `readme.MD` to `README.md` and `readme.pdf` to `README.pdf`.
- Bounded all provider version constraints to a major-version range and set every `required_version` to `>= 1.7.0, < 2.0.0`.
- Set `nullable = false` on inputs that have a non-null default and are not compared with `null`. Passing `null` falls back to the default.
- Pinned every GitHub action to one version across the repositories (for example `actions/checkout` v7.0.1 and `hashicorp/setup-terraform` v4.0.1).
- Module-standards checker takes `--cloud`. Its workflow passes `--cloud azure`.
- Scripts follow one naming rule: PowerShell uses approved verbs, and shell and Python use snake_case. `Generate-DocsManifest.ps1` is now `New-DocsManifest.ps1`; `stage-docs.py` is now `stage_docs.py`; kebab-case shell scripts are now snake_case (`create_release_tag.sh`, `post_init_script.sh`, `terraform_change_summary.sh`, and the `azure-pipelines/` scripts).
- Root tools renamed: `test.ps1` is now `Test-ChangedFiles.ps1`, and `reload-arm-env.ps1` is now `Update-ArmEnvironment.ps1`.
- Module READMEs use `## Testing` (renamed from `## Tests`).

### Removed

- Duplicate governance docs: `contributor-naming-convention.md` (historical AWS proposal), `pre-commit.md` (stub) and `tagging-convention.md` (historical AWS guidance). The current pages are `naming-convention.md`, `pre-commit-setup.md` and `tagging-standard.md`.
- Duplicate PDFs `references/naming-convention.pdf` and `references/pre-commit.pdf`. Their content is in the Markdown pages.

