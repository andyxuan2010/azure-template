# Security

This repository contains Azure infrastructure-as-code modules and the root stack that composes them. Treat every module default as a starting point that the calling landing zone must review.

## Secrets and State

Never commit secrets, state files, saved plans, `.env` files, credentials, or `terraform.tfvars` files that contain values. Use Key Vault references, protected pipeline variables, or Entra workload identity instead. Mark every input that carries a secret value with `sensitive = true`. `sensitive` hides the value from plan output but does not remove it from state, so protect the state backend.

Run `pre-commit run --all-files` before pushing. The `detect-private-key` hook is a guardrail, not a substitute for review.

## Reporting a Vulnerability

Report suspected vulnerabilities through the organization's approved private channel. Do not open a public issue or pull request that describes an unfixed weakness. Include the module, the input or resource involved, and the Terraform version used.

## Related Guidance

See [DevSecOps and GitOps](docs/60-security-governance/devsecops-gitops.md), [Entra identity and RBAC](docs/60-security-governance/entra-identity-and-rbac.md), and the [code standards](docs/60-security-governance/code-standards.md).
