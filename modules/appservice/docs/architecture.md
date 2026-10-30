# App Service Architecture

```mermaid
flowchart LR
  Plan[Existing App Service Plan] --> App[Web App created by module]
  Client[Inbound client] --> PE[Optional private endpoint]
  PE --> App
  PE --> DNS[Optional private DNS zone]
  App --> VNet[Optional VNet integration for outbound traffic]
  App --> Identity[Optional managed identity]
  Identity --> Dependencies[Key Vault, storage, registry, or APIs]
  App --> Auth[Optional Entra authentication]
  App --> Monitor[Optional Application Insights and diagnostics]
```

The module creates one Linux or Windows Web App and selected optional resources. The App Service Plan is an existing dependency. VNet integration supports outbound access; a private endpoint and DNS handle private inbound access. These are separate network paths. The module does not grant downstream identity permissions merely by attaching an identity. The caller provides the resource group, plan, delegated subnet, private endpoint subnet/DNS, and dependency resources. See the [module README](../README.md).
