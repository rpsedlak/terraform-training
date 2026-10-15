# ADR-005: Create One VM in the Servers Subnet

**Status:** Accepted for compute placement and image; Bastion/private-IP access superseded by [ADR-018](ADR-018-source-restricted-rdp.md).
**Date:** 2026-10-14

## Context

The Azure network design in [ADR-003](ADR-003-azure-network-topology.md) includes a dedicated servers subnet. The environment needs an initial compute footprint for the training deployment.

## Decision

Create exactly one virtual machine in the servers subnet of the virtual network.

## Consequences

- Terraform configuration will create one VM and attach its network interface to the servers subnet.
- Use the Windows Server 2022 Datacenter Azure Edition marketplace image: `MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest`.
- Access the server over its private IP using Azure Bastion and RDP; allow RDP only from the Bastion subnet.
- Its default size and override rule are defined in [ADR-006](ADR-006-b-series-vm-size.md), its Premium P10 OS disk is defined in [ADR-007](ADR-007-premium-managed-disk.md), and its public IP restriction is defined in [ADR-008](ADR-008-no-server-public-ip.md).
- The VM must not be placed in `AzureBastionSubnet`.