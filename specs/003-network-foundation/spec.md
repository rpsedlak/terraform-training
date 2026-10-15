# Feature: Azure Network Foundation

**Status:** Approved
**Owner:** Richard Sedlak
**Last updated:** 2026-10-15

## Problem

The Azure environment needs a single, well-defined virtual network and subnet layout for the server resources.

## Goals

- Create the network topology in [ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md), as superseded by [ADR-010](../001-terraform-ci-pipeline/decisions/ADR-010-no-virtual-network-gateway.md).
- Retain the servers subnet and remove the retired Bastion subnet under ADR-017.

## Non-goals

- Deploying the Azure Bastion service; see [004 Azure Bastion](../004-azure-bastion/spec.md).
- Configuring the server VM; see [005 Server VM](../005-server-vm/spec.md).
- Deploying a virtual network gateway; ADR-010 excludes it.

## User stories

- As an infrastructure maintainer, I want the environment's network defined in Terraform so that resource placement is consistent and reviewable.

## Requirements

- Target Azure and use Terraform, as decided in [ADR-001](../001-terraform-ci-pipeline/decisions/ADR-001-azure-deployment.md) and [ADR-002](../001-terraform-ci-pipeline/decisions/ADR-002-terraform-deployment.md).
- Deploy in East US (`eastus`), as decided in [ADR-011](../001-terraform-ci-pipeline/decisions/ADR-011-east-us-region.md).
- Create exactly one virtual network with address space `10.20.0.0/22`.
- Do not create an `AzureBastionSubnet`; ADR-017 supersedes this part of ADR-003.
- Retain `10.20.1.0/24` for the dedicated servers subnet; do not renumber it.
- Do not create a gateway subnet or virtual network gateway, as decided in ADR-010.

## Acceptance criteria

- [ ] Terraform defines exactly one Azure virtual network with address space `10.20.0.0/22` in East US.
- [ ] The VNet contains the dedicated servers subnet (`10.20.1.0/24`) and no Bastion subnet.
- [ ] The subnet CIDRs do not overlap and fit within the VNet address space.
- [ ] No `GatewaySubnet` or virtual network gateway is created.
- [ ] The plan shows the network foundation without applying it.

## Constraints and assumptions

- The topology and CIDRs are accepted in [ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md); ADR-010 removes the earlier gateway requirement.
- The selected network is used by [005 Server VM](../005-server-vm/spec.md) and [007 Public VM Access](../007-jit-vm-access/spec.md); feature 004 is historical.
- Azure-required subnet names must remain unchanged.

## Open questions

None. Address ranges and gateway scope are decided in ADR-003 and ADR-010.