# Feature: Azure Network Foundation

**Status:** Draft  
**Owner:** Richard Sedlak
**Last updated:** 2026-10-14

## Problem

The Azure environment needs a single, well-defined virtual network and subnet layout for its gateway, Bastion, and server resources.

## Goals

- Create the network topology accepted in [ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md).
- Reserve the required subnets for the Standard SKU virtual network gateway, Azure Bastion, and server VM.

## Non-goals

- Deploying the Azure Bastion service; see [004 Azure Bastion](../004-azure-bastion/spec.md).
- Configuring the server VM; see [005 Server VM](../005-server-vm/spec.md).
- Choosing CIDR ranges or gateway type before those decisions are approved.

## User stories

- As an infrastructure maintainer, I want the environment's network defined in Terraform so that resource placement is consistent and reviewable.

## Requirements

- Target Azure and use Terraform, as decided in [ADR-001](../001-terraform-ci-pipeline/decisions/ADR-001-azure-deployment.md) and [ADR-002](../001-terraform-ci-pipeline/decisions/ADR-002-terraform-deployment.md).
- Create exactly one virtual network with an address-space size of `/22`.
- Include a `GatewaySubnet` for a Standard SKU virtual network gateway.
- Include an `AzureBastionSubnet` for Azure Bastion.
- Include a dedicated servers subnet with an address-space size of `/24`.
- Select non-overlapping subnet CIDRs that fit within the VNet and meet current Azure requirements.

## Acceptance criteria

- [ ] Terraform defines exactly one Azure virtual network with a `/22` address space.
- [ ] The VNet contains `GatewaySubnet`, `AzureBastionSubnet`, and a dedicated servers subnet.
- [ ] A Standard SKU virtual network gateway is associated with `GatewaySubnet`.
- [ ] The servers subnet has a `/24` address space.
- [ ] All subnet CIDRs are non-overlapping, fit within the VNet, and meet Azure requirements.
- [ ] A plan shows the network foundation without applying it.

## Constraints and assumptions

- The topology is accepted in [ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md).
- The selected network will be used by features [004 Azure Bastion](../004-azure-bastion/spec.md) and [005 Server VM](../005-server-vm/spec.md).
- Azure-required subnet names must remain unchanged.

## Open questions

- [ ] Which VNet base CIDR and subnet CIDR ranges should be assigned?
- [ ] What subnet sizes should be used for the gateway and Bastion, and do they meet current Azure requirements?
- [ ] Should the virtual network gateway be VPN or ExpressRoute?
- [ ] What exact name should be used for the servers subnet, subject to the environment naming requirements in feature 006?