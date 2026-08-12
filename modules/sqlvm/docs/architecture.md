# SQL VM Architecture

## Scope

The module owns the Azure compute resources for a SQL Server VM tier and the optional SQL IaaS Agent configuration. The caller owns the surrounding network, access controls, high-availability topology, data protection, and workload database lifecycle.

## Resource Flow

```text
existing resource group + subnet
              |
              v
        network interface
              |
              v
      Windows SQL Server VM
        /       |        \
 managed    optional     optional
  disks     domain/run   SQL IaaS
    |        command      agent
    +------ attachments
```

Every item in the resolved VM map creates one NIC and VM. Every configured disk is expanded across every VM. Domain join and Run Command depend on the VM; Run Command also waits for domain join. SQL IaaS registration manages SQL-specific configuration after the VM exists.

## Availability and Lifecycle

Zones and an Availability Set are mutually exclusive. Zone selection rotates through `zones` when multiple instances are requested. An Availability Set, SQL VM group, Windows Failover Cluster, load balancer/listener, and SQL availability group must be composed separately.

Changing a VM name, placement model, image, OS-disk properties, or subnet can replace compute resources. Disk key/LUN changes can replace or reattach data disks. Treat changes to production SQL storage layouts as migration operations.

## Trust Boundaries

Administrator, domain-join, SQL connectivity, backup, and WSFC credentials are secrets even when provider schemas do not mark every nested field sensitive. Supply them from an approved secret path and prevent them from entering logs or committed variable files.

The module creates no NSG or route controls. The subnet must restrict management and SQL traffic and provide only the outbound/domain paths needed by the workload.
