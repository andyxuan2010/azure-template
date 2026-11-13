# Azure OpenAI Architecture

The module composes an Azure OpenAI account, model deployments, optional private connectivity, encryption, monitoring, and access control.

```text
Resource group ───────────────────────────────┐
Managed identity ─────────────────────────────┤
Key Vault key (optional CMK) ─────────────────┼─> Azure OpenAI account
Private endpoint subnet + DNS (optional) ─────┤          │
Monitoring destinations (optional) ───────────┘          ├─> model deployments
Microsoft Entra principals ──────────────────────────────└─> scoped RBAC
```

The account is the security and network boundary; deployments consume its regional quota and expose models through the account endpoint.

## Authentication Boundary

Local key authentication is disabled by default. Applications should authenticate with Microsoft Entra identities and receive the narrowest suitable Azure OpenAI data-plane role.

Access keys still exist as sensitive provider attributes and outputs. Terraform state must be encrypted and access-controlled even when applications do not use those keys.

## Network Boundary

Public network access is disabled by default. Production access normally requires:

1. a private endpoint on the `account` subresource;
2. `privatelink.openai.azure.com` private DNS;
3. VNet links and client DNS forwarding;
4. routes and firewalls that permit HTTPS to the private IP.

The module attaches existing DNS zones but does not create zones, VNet links, or client connectivity.

## Encryption Boundary

Customer-managed encryption requires an existing Key Vault key and user-assigned identity. The identity must have the required Key Vault permissions before Azure can configure the account. Key rotation and Key Vault lifecycle remain outside this module.

## Deployment Boundary

Each entry in `deployments` creates one Azure OpenAI deployment. Deployment capacity is quota-backed and model availability is regional. Stable map keys preserve Terraform addresses even when Azure-facing deployment names or model versions change.

Version upgrade policy defines whether Azure can move a deployment to a newer model version. Application compatibility and evaluation remain caller responsibilities.

## Monitoring and Governance

The optional diagnostic setting sends account logs and metrics to existing destinations. It does not create alerts, budgets, content safety policies, evaluation pipelines, or prompt telemetry. Those controls should be composed around the account according to the workload risk classification.
