# Feature: Server VM

**Status:** Approved
**Owner:** Richard Sedlak
**Last updated:** 2026-10-15

## Problem

The Azure environment needs one server VM with defined placement, minimum size, storage tier, and public network exposure.

## Goals

- Create exactly one VM in the servers subnet from feature [003 Network Foundation](../003-network-foundation/spec.md).
- Use the shared VM-size default and override constraints from ADR-019, Premium disk tier from ADR-007, and source-restricted public-IP access under ADR-018.

## Non-goals

- Selecting a VM image, operating system, disk SKU, or access policy without an approved decision.
- Managing subscription pricing or permitting RDP from any source other than `69.244.159.36/32`.

## User stories

- As an operator, I want one appropriately sized VM in the servers subnet with direct RDP restricted to my approved public IP.
- As a reviewer, I want VM size and disk requirements checked in the plan so that deployments stay within the approved architecture.

## Requirements

- Create exactly one VM in the servers subnet and not in `AzureBastionSubnet`, as decided in [ADR-005](../001-terraform-ci-pipeline/decisions/ADR-005-single-server-vm.md).
- Default the VM size to `Standard_D2ds_v6` for development, testing and production under [ADR-019](../001-terraform-ci-pipeline/decisions/ADR-019-shared-d2ds-v6-vm-size.md). Expose an input variable; also accept B-series overrides with at least two vCPUs. Reject other non-B-series and undersized sizes. ADR-019 supersedes the earlier B2s_v2 default and development-only exception.
- Configure the VM's attached disk as Premium managed storage, as decided in [ADR-007](../001-terraform-ci-pipeline/decisions/ADR-007-premium-managed-disk.md).
- Associate a Standard static IPv4 public IP with the existing server NIC under [ADR-018](../001-terraform-ci-pipeline/decisions/ADR-018-source-restricted-rdp.md), superseding ADR-008 and the JIT portion of ADR-017.
- Use the Windows Server 2022 Datacenter Azure Edition image: `MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest`.
- Access the VM directly through public-IP RDP using [feature 007](../007-jit-vm-access/spec.md): allow inbound TCP 3389 only from `69.244.159.36/32` at priority 100, then explicitly deny it from all other sources at priority 110. No JIT request, time limit or paid-plan prerequisite applies.
- Use a Premium SSD P10 managed OS disk only; do not create a separate data disk.
- Retrieve the VM administrator username and password from Azure Key Vault after OIDC authentication. Use secret names `adminuser` and `adminpassword`, respectively. See [ADR-015](../001-terraform-ci-pipeline/decisions/ADR-015-vm-credentials-from-key-vault.md).
- Do not store VM credentials in GitHub secrets/variables or print their values in workflow logs. Restrict Terraform state access because the VM password is persisted in state.
- Apply the environment code from feature [006 Environment Naming](../006-environment-naming/spec.md) where Azure naming rules permit.

## Acceptance criteria

- [ ] The plan contains exactly one VM attached to the servers subnet.
- [x] Without an override, the VM size is `Standard_D2ds_v6` in development, testing and production (mocked plan tests).
- [x] A B-series override with at least two vCPUs is accepted; other non-B-series or undersized overrides are rejected, except the approved `Standard_D2ds_v6` SKU (mocked plan tests).
- [x] Explicit `Standard_D2ds_v6` inputs are accepted for development, testing and production (mocked plan tests).
- [ ] The VM's attached disk uses an approved Premium managed disk SKU.
- [ ] The VM uses the approved Windows Server 2022 Datacenter Azure Edition image.
- [ ] Public-IP RDP is allowed only from `69.244.159.36/32` and explicitly denied from every other source under feature 007.
- [ ] The VM has a Premium SSD P10 OS disk and no additional data disk.
- [ ] The username is retrieved from Key Vault secret `adminuser`, and the password is retrieved from `adminpassword`.
- [ ] The VM credentials are not stored in GitHub secrets/variables or emitted in workflow logs.
- [ ] The existing NIC has a Standard static IPv4 public IP; the VM is not replaced to change access.
- [ ] The VM is not placed in `AzureBastionSubnet`.
- [ ] Resource naming follows feature 006 where Azure naming rules permit.
- [ ] The plan is reviewable without applying it.

## Constraints and assumptions

- The VM decisions are recorded in ADR-005 through ADR-008, with current size requirements in [ADR-019](../001-terraform-ci-pipeline/decisions/ADR-019-shared-d2ds-v6-vm-size.md), superseding ADR-016's development-only scope.
- Network resources are provided by feature 003; source-restricted public access is specified by feature 007, superseding feature 004.
- The VM image and P10 OS disk are defined by ADR-005 through ADR-007. Public-IP access and the trusted RDP source are defined by ADR-018; credential sourcing is defined by ADR-015.
- Terraform state contains the VM password and must be restricted to the approved deployment identities.

## Open questions

None. VM image and disk follow ADR-005 and ADR-007; sizing follows ADR-019 and direct RDP follows ADR-018.