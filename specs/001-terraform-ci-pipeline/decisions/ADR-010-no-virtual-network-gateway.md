# ADR-010: Do Not Deploy a Virtual Network Gateway

**Status:** Accepted; supersedes the gateway portion of [ADR-003](ADR-003-azure-network-topology.md)  
**Date:** 2026-10-14

## Context

ADR-003 originally included a Standard SKU virtual network gateway and `GatewaySubnet`. The environment does not require VPN or ExpressRoute connectivity.

## Decision

Do not deploy an Azure virtual network gateway and do not create a `GatewaySubnet`.

## Consequences

- The VNet remains a standalone network for Azure Bastion and the server VM.
- Gateway-specific resources, costs, subnet allocation, and implementation tasks are removed from the environment scope.
- Remote network connectivity is not provided by this environment.