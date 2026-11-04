# Changelog

All notable changes to this repository are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- Renamed module directories to `snake_case` (for example `keyvault` to `key_vault`, `appservice` to `app_service`). Update module `source` paths in callers. Terraform resource addresses and module labels are unchanged, so existing state is not affected.
- Renamed each module's `terraform.tf` to `versions.tf`, matching the standard module layout.
- Renamed `readme.MD` to `README.md` and `readme.pdf` to `README.pdf`.
- Bounded all provider version constraints to a major-version range and set every `required_version` to `>= 1.7.0, < 2.0.0`.
- Set `nullable = false` on inputs that have a non-null default and are not compared with `null`. Passing `null` falls back to the default.

### Added

- `examples/complete` for every module that lacked one, and a `## Usage` section for every example README.
- `SECURITY.md`, `CONTRIBUTING.md`, and this changelog as the common repository set.
