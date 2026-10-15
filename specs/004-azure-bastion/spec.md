# Feature: Azure Bastion

**Status:** Draft  
**Owner:** Richard Sedlak
**Last updated:** 2026-10-14

## Problem

The Azure environment requires Azure Bastion for private connectivity within the virtual network.

## Goals

- Deploy Azure Bastion into the `AzureBastionSubnet` defined by feature [003 Network Foundation](../003-network-foundation/spec.md).
- Keep Bastion deployment independently reviewable while integrating it into the environment plan.

## Non-goals

- Defining server VM access policy or operating system; see [005 Server VM](../005-server-vm/spec.md).
- Prohibiting public IPs on Azure Bastion; the no-public-IP decision applies only to the server VM.

## User stories

- As an operator, I want Azure Bastion deployed in the designated subnet so that private VM connectivity can be provided without a public IP on the VM.

## Requirements

- Deploy the Azure Bastion service, as decided in [ADR-004](../001-terraform-ci-pipeline/decisions/ADR-004-azure-bastion.md).
- Place the Bastion resource in the `AzureBastionSubnet` in the VNet from feature 003.
- Keep Bastion SKU and public IP configuration explicit and secure; these choices remain open until approved.

## Acceptance criteria

- [ ] The Terraform plan creates Azure Bastion in the VNet from feature 003.
- [ ] Azure Bastion is associated with the designated `AzureBastionSubnet`.
- [ ] The Bastion SKU and public IP configuration match approved decisions and satisfy Azure requirements.
- [ ] The plan does not attach a public IP to the server VM as covered by feature 005.
- [ ] The Bastion plan is reviewable without applying it.

## Constraints and assumptions

- The deployment decision is accepted in [ADR-004](../001-terraform-ci-pipeline/decisions/ADR-004-azure-bastion.md).
- The Bastion subnet topology comes from [ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md) and feature 003.
- This feature is implemented with Azure Terraform configuration under feature 002.

## Open questions

- [ ] Which Azure Bastion SKU should be used?
- [ ] What public IP SKU, allocation, and naming configuration should be used?
- [ ] What subnet CIDR should be allocated to `AzureBastionSubnet` in feature 003?