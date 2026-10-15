# ADR-008: Do Not Attach a Public IP to the Server VM

**Status:** Superseded by [ADR-017](ADR-017-jit-vm-access.md) and [ADR-018](ADR-018-source-restricted-rdp.md).
**Date:** 2026-10-14

## Context

The environment contains one VM in the servers subnet and Azure Bastion, as recorded in [ADR-005](ADR-005-single-server-vm.md) and [ADR-004](ADR-004-azure-bastion.md). The server VM should not be directly exposed through a public IP address.

## Decision

Do not attach a public IP address to the server VM or its network interface.

## Consequences

- Terraform configuration must not create or associate a public IP resource with the server VM's network interface.
- Any public IP required by another service, such as Azure Bastion or the virtual network gateway, is outside the scope of this decision.
- The server's access method and required network rules remain to be defined before implementation.