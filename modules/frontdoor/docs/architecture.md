# Azure Front Door architecture

The module creates an Azure Front Door Standard or Premium profile, one endpoint, one origin group, one origin, and one route. A route receives requests on the Front Door endpoint and forwards them to the origin group. Health probes and load balancing evaluate origin availability. Optional Premium Private Link requests connect the origin through Azure Private Link.

```mermaid
flowchart LR
  Client[Client] --> Edge[Front Door endpoint]
  Edge --> Route[HTTPS-first route]
  Route --> Group[Origin group and health probe]
  Group --> Origin[Configured origin]
  Origin -->|Public HTTPS| Backend[Application origin]
  Origin -. Premium option .->|Private Link request| PrivateBackend[Supported private Azure origin]
```

## Boundaries

- The caller owns the resource group, provider configuration, custom domains, DNS records, WAF policy, and diagnostics.
- The module creates a single origin and route. For multi-origin failover or multi-route setups, use multiple modules or extend the design with shared-profile composition.
- Private Link requires Premium, supported origin types and regions, and manual approval on the origin.
- Protect the origin from direct internet traffic so callers cannot bypass Front Door routing and WAF controls.

See [Azure Front Door security guidance](https://learn.microsoft.com/azure/frontdoor/secure-front-door), [origin security](https://learn.microsoft.com/azure/frontdoor/origin-security), and [origin group concepts](https://learn.microsoft.com/azure/frontdoor/front-door-backend-pool).
