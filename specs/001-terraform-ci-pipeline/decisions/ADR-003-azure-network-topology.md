# ADR-003: Use a Single Azure Virtual Network

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The Azure environment needs a defined network layout for gateway access, Azure Bastion access, and servers.

## Decision

The environment will use one virtual network with a `/22` address-space size. It will contain:

- A `GatewaySubnet` for an Azure virtual network gateway using the Standard SKU.
- An `AzureBastionSubnet` for Azure Bastion.
- A subnet for servers with a `/24` address-space size.

## Consequences

- The VNet and subnet CIDR ranges must be non-overlapping and fit within the `/22` VNet address space.
- The VNet base CIDR and the CIDR sizes and ranges for `GatewaySubnet` and `AzureBastionSubnet` remain to be allocated.
- The gateway type (VPN or ExpressRoute) and subnet sizes must be confirmed against Azure requirements before implementation.