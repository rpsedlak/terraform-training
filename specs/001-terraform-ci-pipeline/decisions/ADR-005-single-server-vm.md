# ADR-005: Create One VM in the Servers Subnet

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The Azure network design in [ADR-003](ADR-003-azure-network-topology.md) includes a dedicated servers subnet. The environment needs an initial compute footprint for the training deployment.

## Decision

Create exactly one virtual machine in the servers subnet of the virtual network.

## Consequences

- Terraform configuration will create one VM and attach its network interface to the servers subnet.
- The VM operating system/image and access method remain to be decided before implementation. Its default size and override rule are defined in [ADR-006](ADR-006-b-series-vm-size.md), and its Premium managed disk requirement is defined in [ADR-007](ADR-007-premium-managed-disk.md).
- The VM must not be placed in `AzureBastionSubnet` or `GatewaySubnet`.