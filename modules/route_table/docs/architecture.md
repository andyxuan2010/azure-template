# Route Table Architecture

```text
Azure Firewall / NVA / gateway
              ^
              | user-defined next hop
              |
        Azure route table
          /           \
         v             v
 application subnet   data subnet
```

## Ownership Boundary

The module owns one route table, its inline routes, and the associations listed in `subnet_ids`. Virtual networks, subnets, gateways, firewalls, and appliances remain caller-owned dependencies.

Association ownership must be exclusive. A subnet cannot simultaneously be associated with different route tables, and two Terraform states must not manage the same association.

## Route Evaluation

Azure combines user-defined, BGP-learned, and system routes and selects routes by prefix specificity and route-source precedence. This module declares user-defined routes but does not model the final effective route table.

Use `disable_bgp_route_propagation` only when learned gateway routes should not reach the associated subnets. Suppressing BGP routes can interrupt hybrid connectivity.

## Change Sequence

1. Establish and test the next-hop firewall, appliance, or gateway.
2. Create the route table without production associations.
3. Review effective routes and return paths.
4. Associate a non-production subnet and validate connectivity.
5. Roll out associations in controlled stages.

Treat changes to `0.0.0.0/0`, management prefixes, or hybrid routes as production network changes with a rollback plan.
