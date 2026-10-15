# Feature: Azure Bastion

**Status:** Superseded by [feature 007](../007-jit-vm-access/spec.md) and ADR-018; retained as historical requirements.
**Owner:** Richard Sedlak
**Last updated:** 2026-10-14

## Problem

The Azure environment requires Azure Bastion for private connectivity within the virtual network.

## Goals

- Deploy Azure Bastion Basic in East US into the `AzureBastionSubnet` defined by feature [003 Network Foundation](../003-network-foundation/spec.md).
- Keep Bastion deployment independently reviewable while integrating it into the environment plan.

## Non-goals

- Defining server VM access policy or operating system; see [005 Server VM](../005-server-vm/spec.md).
- Prohibiting public IPs on Azure Bastion; the no-public-IP decision applies only to the server VM.

## User stories

- As an operator, I want Azure Bastion deployed in the designated subnet so that private VM connectivity can be provided without a public IP on the VM.

## Requirements

- Deploy the Azure Bastion service, as decided in [ADR-004](../001-terraform-ci-pipeline/decisions/ADR-004-azure-bastion.md).
- Place the Bastion resource in the `AzureBastionSubnet` in the VNet from feature 003.
- Deploy the Basic SKU, the lowest-cost dedicated SKU available in East US; Developer is not available in East US. See [ADR-004](../001-terraform-ci-pipeline/decisions/ADR-004-azure-bastion.md).
- Use a Standard SKU static IPv4 public IP for Bastion. This does not add a public IP to the server VM.

## Acceptance criteria

- [ ] The Terraform plan creates Azure Bastion in the VNet from feature 003.
- [ ] Azure Bastion is associated with the designated `AzureBastionSubnet`.
- [ ] The Bastion uses the Basic SKU and a Standard static IPv4 public IP.
- [ ] `AzureBastionSubnet` is `10.20.0.0/26` and meets Azure requirements.
- [ ] The plan does not attach a public IP to the server VM as covered by feature 005.
- [ ] The Bastion plan is reviewable without applying it.

## Constraints and assumptions

- The deployment decision is accepted in [ADR-004](../001-terraform-ci-pipeline/decisions/ADR-004-azure-bastion.md).
- The Bastion subnet topology comes from [ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md) and feature 003.
- This feature is implemented with Azure Terraform configuration under feature 002.

## Open questions

None. SKU, region, public IP configuration, and subnet allocation are decided in ADR-004 and feature 003.