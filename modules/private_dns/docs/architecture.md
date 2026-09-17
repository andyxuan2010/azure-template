# Private DNS Architecture

```text
on-premises / spoke workloads
             |
             v
   linked hub or spoke VNet
             |
             v
      Private DNS zone
             |
     +-------+--------+
     | records        | private endpoint zone group
     v                v
explicit record   endpoint-managed A record
```

## Zone Placement

Private endpoint zones are commonly centralized in a connectivity or shared-services subscription. Create each zone once and pass its ID to service or Private Endpoint modules instead of creating competing copies in workload stacks.

## VNet Links

Link every VNet that must resolve a zone, either directly or through an approved hub DNS architecture. Link ownership should be centralized because duplicate links and overlapping zones can create deployment failures or inconsistent resolution.

Use auto-registration only for private namespaces that intentionally register VM records. Private endpoint zones should normally disable registration.

## Record Ownership

Choose one owner for each record:

- Private Endpoint zone groups for endpoint lifecycle-coupled records
- This module for stable, centrally managed records
- A separate DNS automation process when required by platform operations

Do not manage the same record through more than one owner.

## Hybrid Resolution

Zone links alone do not provide on-premises forwarding. Azure DNS Private Resolver, conditional forwarding, routing, and firewall rules are separate platform dependencies.
