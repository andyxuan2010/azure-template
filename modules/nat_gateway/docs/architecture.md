# NAT Gateway Architecture

```text
Private workload resources
           |
           v
   One or more VNet subnets
           |
           v
    Azure NAT Gateway
           |
           v
   Static public IP address(es)
           |
           v
        Internet
```

## Ownership Boundary

The module owns one NAT Gateway and its public IP and subnet associations. It creates public IP resources when no `public_ip_address_ids` are supplied; otherwise it only manages the associations to caller-owned public IPs. Virtual networks, subnets, public IP prefixes, NSGs, route tables, and workload resources remain caller-owned.

## Egress Behavior

The NAT Gateway provides source NAT for internet-bound connections from associated subnet resources. It permits return packets for those outbound flows and does not accept unsolicited inbound connections. It becomes the default outbound next hop for internet traffic from the associated subnets, subject to effective routes and network controls.

All associated subnets must be in the same VNet. Each subnet can have one NAT Gateway association. Keep the association under one Terraform state owner and plan changes to egress paths as network changes.

## SKU, IP, and Zone Compatibility

Standard NAT Gateways use Standard public IPs. StandardV2 gateways require StandardV2 public IPs and are zone-redundant; omit the `zones` setting for the gateway. Standard NAT Gateways support no-zone or single-zone deployment. Public IP zones must be compatible with the selected Standard gateway zone.

The module creates static IPv4 public IPs matching the selected gateway SKU. Caller-owned IPs must also be static and SKU compatible. Public IP prefixes and IPv6 are not managed by this module.

## Cost and Operations

NAT Gateway and associated public IPs are billed resources. Each public IP contributes additional SNAT port capacity. Track outbound flow and SNAT connection metrics, and add addresses when demand approaches capacity. A public IP or subnet association change can reset active connections, so schedule changes with workload owners.
