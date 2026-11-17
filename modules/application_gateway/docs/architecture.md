# Application Gateway Architecture

```mermaid
flowchart LR
  Client[Client] --> PublicIP[Public IP and public frontend]
  PublicIP --> Listener[HTTP or HTTPS listener]
  Listener --> Rule[Routing rule or path map]
  Rule --> Backend[Backend pool and settings]
  Backend --> Workload[Reachable backend]
  Gateway[Application Gateway v2] --- Subnet[Dedicated gateway subnet]
  Gateway -. optional .-> Private[Private frontend]
  Gateway -. optional WAF .-> Protect[WAF configuration or policy]
  Gateway -. optional .-> Identity[Managed identity for certificate access]
  Gateway -. optional .-> Monitor[Diagnostics and Log Analytics]
```

The module always creates an Application Gateway v2 and a Standard static public IP. A private frontend is additional; it does not replace the public frontend. The caller supplies the resource group, dedicated gateway subnet, reachable backends, and any WAF policy, identity, or Log Analytics workspace. HTTPS certificate PFX data and passwords can enter Terraform state, so protect state and plan artifacts. See the [module README](../README.md).
