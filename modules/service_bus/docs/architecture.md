# Service Bus Architecture

```text
senders ---> queue ----------------------> receivers
       \
        \--> topic ---> subscription A --> consumer A
                    \-> subscription B --> consumer B

application network ---> Private Endpoint ---> namespace
                                 |
                                 v
                         Private DNS zone

namespace diagnostics -------------------> Log Analytics
```

## Resource Boundary

The namespace is the security, networking, capacity, and billing boundary. Queues, topics, subscriptions, and namespace authorization rules are owned inside the same module instance.

The module creates subscriptions only when their `topic_name` refers to a topic in the same `topics` map. External topics and subscription filters remain outside its ownership.

## Authentication Boundary

Namespace Contributor and Reader assignments manage Azure resources but do not authorize messaging operations. Applications need Azure Service Bus data-plane roles or SAS policies appropriate to their send and receive paths.

Disabling `local_auth_enabled` prevents SAS use. Coordinate that change with application identity rollout and protect Terraform state whenever authorization rules exist.

## Network Boundary

Public network access, namespace network rules, and Private Endpoint connectivity are separate controls. A Private Endpoint does not configure VNet links or hybrid DNS. Validate private name resolution and client routing before disabling the public endpoint.

## Deployment Sequence

1. Create the resource group, endpoint subnet, Private DNS zone, VNet links, and monitoring workspace.
2. Create the namespace and messaging entities.
3. Create data-plane identities and role assignments.
4. Create and validate the Private Endpoint and DNS resolution.
5. Move clients to Entra authentication.
6. Disable local authentication and public access after validation.

Entity retention, dead-letter handling, retry policy, duplicate detection, and consumer scaling must be designed with the application teams.
