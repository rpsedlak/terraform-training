# Feature: Private Server VM

**Status:** Draft  
**Owner:** Richard Sedlak
**Last updated:** 2026-10-14

## Problem

The Azure environment needs one server VM with defined placement, minimum size, storage tier, and public network exposure.

## Goals

- Create exactly one VM in the servers subnet from feature [003 Network Foundation](../003-network-foundation/spec.md).
- Use the default size, override constraints, Premium managed disk tier, and no-public-IP rule accepted in ADR-005 through ADR-008.

## Non-goals

- Selecting a VM image, operating system, disk SKU, or access policy without an approved decision.
- Attaching a public IP to the server VM.

## User stories

- As an operator, I want one appropriately sized private VM in the servers subnet so that the environment has a controlled server workload.
- As a reviewer, I want VM size and disk requirements checked in the plan so that deployments stay within the approved architecture.

## Requirements

- Create exactly one VM in the servers subnet and not in `GatewaySubnet` or `AzureBastionSubnet`, as decided in [ADR-005](../001-terraform-ci-pipeline/decisions/ADR-005-single-server-vm.md).
- Default the VM size to `Standard_B2s_v2`. Expose an input variable to override it; any override must be a B-series SKU with at least two vCPUs, as decided in [ADR-006](../001-terraform-ci-pipeline/decisions/ADR-006-b-series-vm-size.md).
- Configure the VM's attached disk as Premium managed storage, as decided in [ADR-007](../001-terraform-ci-pipeline/decisions/ADR-007-premium-managed-disk.md).
- Do not associate a public IP with the server VM or its network interface, as decided in [ADR-008](../001-terraform-ci-pipeline/decisions/ADR-008-no-server-public-ip.md).
- Apply the environment code from feature [006 Environment Naming](../006-environment-naming/spec.md) where Azure naming rules permit.

## Acceptance criteria

- [ ] The plan contains exactly one VM attached to the servers subnet.
- [ ] Without an override, the VM size is `Standard_B2s_v2`.
- [ ] A B-series override with at least two vCPUs is accepted; a non-B-series or undersized override is rejected.
- [ ] The VM's attached disk uses an approved Premium managed disk SKU.
- [ ] No public IP is associated with the VM or its NIC.
- [ ] The VM is not placed in `GatewaySubnet` or `AzureBastionSubnet`.
- [ ] Resource naming follows feature 006 where Azure naming rules permit.
- [ ] The plan is reviewable without applying it.

## Constraints and assumptions

- The VM decisions are recorded in [ADR-005](../001-terraform-ci-pipeline/decisions/ADR-005-single-server-vm.md) through [ADR-008](../001-terraform-ci-pipeline/decisions/ADR-008-no-server-public-ip.md).
- Network resources are provided by feature 003; Azure Bastion is specified by feature 004.
- VM image, operating system, access method, exact disk SKU/performance settings, and disk role remain open.

## Open questions

- [ ] Which VM image and operating system should be used?
- [ ] What private VM access method and network rules are required?
- [ ] Does Premium managed storage apply to the OS disk, a data disk, or both?
- [ ] Which Premium disk SKU, capacity, and performance settings should be used?
- [ ] Which B-series override SKUs should be supported in the target Azure region?