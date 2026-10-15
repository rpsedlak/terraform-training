# ADR-003: Use a Single Azure Virtual Network

**Status:** Accepted; gateway requirement superseded by [ADR-010](ADR-010-no-virtual-network-gateway.md)
**Date:** 2026-10-14

## Context

The Azure environment needs a defined network layout for Azure Bastion access and servers. The earlier gateway requirement is superseded by ADR-010.

## Decision

The environment will use one virtual network with a `/22` address-space size. It will contain:

- An `AzureBastionSubnet` for Azure Bastion.
- A subnet for servers with a `/24` address-space size.

## Consequences

- The selected VNet is `10.20.0.0/22`; `AzureBastionSubnet` uses `10.20.0.0/26`, and the servers subnet uses `10.20.1.0/24`.
- The CIDRs are non-overlapping and fit within the VNet address space.
- No `GatewaySubnet` is created, as decided in ADR-010.