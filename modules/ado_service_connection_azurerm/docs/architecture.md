# Architecture and lifecycle

```mermaid
flowchart LR
  P[Explicitly authorized pipeline] --> E[Azure Resource Manager service connection]
  E --> T[Provider-returned issuer and subject]
  T --> F[Federated credential on existing managed identity]
  F --> I[Short-lived Azure token]
  I --> R[Caller-owned scoped Azure RBAC]
  R --> W[Deployment scope and state storage]
```

Provision the identity independently, then the endpoint and its federated trust, then pipeline authorization. This avoids a dependency cycle with identity creation. The module passes Azure DevOps trust values directly to AzureRM, accommodating issuer changes without constructing organization/project-based subjects. The bootstrap runner must authenticate independently of the connection being created.

Keep these modules in a dedicated bootstrap root/state: they administer the CI platform and are deliberately outside the repository's Azure workload root harness. Their standalone examples and mocked tests validate them without adding Azure DevOps credentials or a provider to every workload consumer.

Changes to endpoint names, projects or identities can alter trust and interrupt jobs. Use distinct credential names for parallel migration, validate a nonproduction pipeline, update task references, then retire old trust and privileges. Never manage the same credential or authorization from both this module and another state. Deleting the connection does not revoke other credentials or role assignments on a reused identity.

Apply production service connection checks before granting pipeline access. Review endpoint administrators and manual/inherited grants periodically. Audit Azure DevOps endpoint changes and Azure managed identity credential changes through organization/Azure diagnostic policies. Retain audit records according to policy; this module does not create logging infrastructure.
