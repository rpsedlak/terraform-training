# Feature: Azure Environment

**Status:** Draft  
**Owner:** <name or team>  
**Last updated:** 2026-10-14

## Problem

The project has accepted architecture decisions for its Azure environment, but those decisions need to be expressed as implementable requirements and verifiable acceptance criteria before Terraform resources are written.

## Goals

- Provision the Azure environment described by ADR-001 through ADR-009 using Terraform.
- Make the environment's network, Bastion, server VM, disk, public-IP, and naming requirements testable.
- Keep unresolved implementation choices explicit and block implementation when they affect safe deployment.

## Non-goals

- Defining the CI platform and pipeline workflow; see [001 Terraform CI Pipeline](../001-terraform-ci-pipeline/spec.md).
- Running `terraform apply` or deploying real infrastructure as part of specification work.
- Selecting Azure resource details not established by an accepted ADR unless recorded as a follow-up decision.

## User stories

- As an infrastructure maintainer, I want Terraform to create the approved Azure network and server topology so that the environment is consistent across deployments.
- As an operator, I want the server VM private and reachable through an approved access path so that it is not directly exposed by a public IP.
- As a reviewer, I want Terraform plans to be checked against these requirements so that unapproved infrastructure changes are caught before apply.

## Requirements

- The environment targets Microsoft Azure and is provisioned using Terraform. See [ADR-001](../001-terraform-ci-pipeline/decisions/ADR-001-azure-deployment.md) and [ADR-002](../001-terraform-ci-pipeline/decisions/ADR-002-terraform-deployment.md).
- Create one virtual network with an address-space size of `/22`. It contains a `GatewaySubnet` for a Standard SKU virtual network gateway, an `AzureBastionSubnet` for Azure Bastion, and a servers subnet with a `/24` address-space size. See [ADR-003](../001-terraform-ci-pipeline/decisions/ADR-003-azure-network-topology.md).
- Deploy Azure Bastion into `AzureBastionSubnet`. See [ADR-004](../001-terraform-ci-pipeline/decisions/ADR-004-azure-bastion.md).
- Create exactly one virtual machine in the servers subnet. See [ADR-005](../001-terraform-ci-pipeline/decisions/ADR-005-single-server-vm.md).
- Default the VM size to `Standard_B2s_v2`. Expose the size as a Terraform input variable; any override must be a B-series SKU with at least two vCPUs. See [ADR-006](../001-terraform-ci-pipeline/decisions/ADR-006-b-series-vm-size.md).
- Configure the VM's attached disk as Azure Premium managed storage. See [ADR-007](../001-terraform-ci-pipeline/decisions/ADR-007-premium-managed-disk.md).
- Do not attach a public IP to the server VM or its network interface. This restriction does not prohibit public IPs required by other resources. See [ADR-008](../001-terraform-ci-pipeline/decisions/ADR-008-no-server-public-ip.md).
- Include one environment code in resource names wherever Azure naming rules permit: `d` for development, `t` for testing, and `p` for production. Preserve service-mandated names. See [ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md).
- Do not commit credentials or Terraform state to the repository. Do not apply infrastructure without explicit user authorization.

## Acceptance criteria

- [ ] The Terraform configuration targets Azure and creates exactly one virtual network with a `/22` address space.
- [ ] The virtual network contains the required gateway, Bastion, and servers subnets; the servers subnet has a `/24` address space.
- [ ] A Standard SKU virtual network gateway is deployed into `GatewaySubnet`.
- [ ] Azure Bastion is deployed into `AzureBastionSubnet`.
- [ ] Exactly one VM is attached to the servers subnet and none is attached to `GatewaySubnet` or `AzureBastionSubnet`.
- [ ] With no size override, the VM uses `Standard_B2s_v2`.
- [ ] A valid size override uses a B-series SKU with at least two vCPUs; an invalid family or undersized SKU is rejected.
- [ ] The VM's attached disk is configured as Premium managed storage.
- [ ] The server VM's network interface has no associated public IP.
- [ ] Resource names include the selected environment code wherever Azure naming rules permit, and service-mandated names remain valid.
- [ ] Terraform formatting and validation pass for the completed configuration.
- [ ] A plan can be reviewed against these criteria without applying it.
- [ ] No credentials, state files, or sensitive generated plan artifacts are committed to the repository.

## Constraints and assumptions

- The accepted decisions are recorded in [ADR-001](../001-terraform-ci-pipeline/decisions/ADR-001-azure-deployment.md) through [ADR-009](../001-terraform-ci-pipeline/decisions/ADR-009-environment-naming-codes.md).
- Azure-required subnet names and naming constraints must be preserved.
- The CI workflow and its protected apply approval are specified separately in feature 001.
- No real deployment occurs while this feature is in Draft or without explicit user authorization.

## Open questions

- [ ] Which VNet base CIDR and non-overlapping CIDR ranges should be assigned to each subnet, and what sizes should the gateway and Bastion subnets use?
- [ ] Should the virtual network gateway be VPN or ExpressRoute?
- [ ] Which Azure Bastion SKU and public IP configuration should be used?
- [ ] Which VM image, operating system, and private access method should be used?
- [ ] Does the Premium managed disk decision apply to the OS disk, a data disk, or both; what exact disk SKU, capacity, and performance settings are required?
- [ ] What complete resource naming pattern should surround the environment code?
- [ ] Which Terraform version, remote state backend/locking, and deployment identity should be used?