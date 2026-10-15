# Plan: Private Server VM

**Related spec:** [spec.md](spec.md)  
**Status:** Draft  
**Last updated:** 2026-10-14

## Technical approach

Create one Azure VM and its network interface in the servers subnet supplied by feature 003. Set the VM-size variable default to `Standard_B2s_v2` and validate overrides against the approved B-series and minimum-vCPU rule. Configure the attached Premium managed disk after its role and SKU are selected. Do not create or associate a public IP with the VM NIC.

## Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| VM count and placement | One VM in the servers subnet ([ADR-005](../001-terraform-ci-pipeline/decisions/ADR-005-single-server-vm.md)) | Approved compute footprint. |
| VM size | Default `Standard_B2s_v2`; B-series override with at least two vCPUs ([ADR-006](../001-terraform-ci-pipeline/decisions/ADR-006-b-series-vm-size.md)) | Approved default and minimum. |
| Disk tier | Premium managed storage ([ADR-007](../001-terraform-ci-pipeline/decisions/ADR-007-premium-managed-disk.md)) | Approved storage tier. |
| Public IP | None on VM or NIC ([ADR-008](../001-terraform-ci-pipeline/decisions/ADR-008-no-server-public-ip.md)) | Prevents direct public IP exposure. |
| Image, disk SKU, access | Unresolved | Require decisions before implementation. |

## Security and operations

- Credentials and permissions: use the environment's approved secure deployment identity.
- State and locking: follow feature 002's backend decision.
- Deployment approvals and rollback: use feature 001's protected apply workflow; do not apply during verification.
- Cost and cleanup: review VM and Premium disk cost, retention, and cleanup before deployment.

## Validation

- Verify the default and allowed/denied VM size overrides.
- Review the plan for VM count, subnet attachment, Premium disk SKU, and absence of VM/NIC public IP association.
- Run Terraform formatting and validation; do not apply.

## Risks

- The selected image or SKU may not be available in the target region; confirm availability before approval.
- No public IP requires an approved private access path and network rules before operational use.
- Disk performance and cost depend on the unresolved disk role and SKU.