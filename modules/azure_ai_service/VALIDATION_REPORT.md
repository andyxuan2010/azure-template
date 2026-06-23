# Azure AI Service Validation Report

## Summary

The module was standardized with the current repo patterns for naming, tags, identity, private networking, diagnostics, RBAC, docs, and plan-based tests.

## Validation Performed

- `terraform fmt -recursive`
- `git diff --check -- modules/azure_ai_service`
- Temp local-copy `terraform validate`
- Temp local-copy `terraform test`

## Test Coverage

`tests/live.tftest.hcl` covers:

- Named Azure AI Services account and secure defaults
- Deterministic generated names
- Standardized tags and location code outputs
- Managed identity, customer-managed key, RBAC, network ACLs, and diagnostics
- Private endpoint naming and DNS inputs
- AI Foundry project management and network injection
- Responsible AI policies
- Cognitive model deployments

## Environment Note

This workspace is network-backed. If provider startup is slow from the repo path, validate from a local temp copy or rerun after provider cache warm-up. The module itself validates successfully with AzureRM `4.73.0`.
