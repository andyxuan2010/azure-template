# SQL Managed Instance Architecture and Operations

```text
application / administration network
                  |
                  v
     dedicated delegated subnet
                  |
                  v
       SQL Managed Instance
          |       |       \
          |       |        \--> diagnostics --> Log Analytics
          |       |
          |       +--> managed identity
          |
          +--> managed databases (separate ownership)

optional DNS-zone partner <----> existing Managed Instance
```

## Network Boundary

SQL Managed Instance is injected into a dedicated delegated subnet. The subnet, NSG, route table, DNS, peering, address capacity, and hybrid connectivity must meet the service's network requirements before deployment.

Do not place unrelated resources in the subnet. Treat route and NSG changes as database availability changes.

## Identity Boundary

The SQL administrator credential bootstraps SQL access and remains sensitive Terraform data. The optional Microsoft Entra administrator adds directory-based administration. Managed identity belongs to the Azure resource and needs separate permissions before it can access downstream services.

Azure Contributor and Reader assignments do not grant database access. Database principals and permissions require a SQL deployment process.

## Lifecycle and Cost

Provisioning, scaling, subnet moves, and deletion can take hours. Capacity is billed while the instance exists. Plan changes during an approved window and avoid using integration environments that cannot tolerate long cleanup.

## DNS-Zone Partnership

DNS-zone partnership couples the instance to an existing Managed Instance DNS zone. Create the partner first and coordinate lifecycle ownership; removing or replacing either side can affect cross-instance name resolution.

## Recommended Sequence

1. Confirm quota, SKU support, cost approval, and subnet sizing.
2. Create the resource group, delegated subnet, NSG, routes, DNS, identities, and monitoring workspace.
3. Deploy the Managed Instance.
4. Validate private connectivity, identity, diagnostics, and administration.
5. Add managed databases and database principals through separate modules or pipelines.
6. Test backup recovery and failover procedures before production onboarding.
